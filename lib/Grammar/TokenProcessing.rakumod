=begin pod

=head1 TokenProcessing

C<TokenProcessing> package has grammar classes and action classes for the parsing
Raku Perl 6 grammar files and making a file with token grammar rules that are
extended to have fuzzy matching function calls.

=head1 Synopsis

    use TokenProcessing;
    enhance-token-specs( $fileName, output, :add-protos, sym-name => 'English', :add-exclusions);

=end pod

use v6.d;

unit module Grammar::TokenProcessing;

use Grammar::TokenProcessing::Grammar;
use Grammar::TokenProcessing::ComprehensiveGrammar;
use Grammar::TokenProcessing::Actions::EBNF;
use Grammar::TokenProcessing::Actions::EnhancedTokens;
use Grammar::TokenProcessing::Actions::RandomSentence;
use Grammar::TokenProcessing::Actions::Tokens;
use Grammar::TokenProcessing::Actions::TokenNames;
use Grammar::TokenProcessing::Actions::TokensHash;

use Lingua::EN::Stem::Porter;
use Text::Levenshtein::Damerau;
use Data::Generators;

##===========================================================
## Utilities
##===========================================================
our sub reallyflat (+@list) {
    gather @list.deepmap: *.take
}

our sub tree($dir, $extension = Whatever) {

    my @files = gather for dir($dir) -> $f {

        if ($f.IO.f) {

            if $extension.isa(Whatever) {
                take $f
            } elsif so $f.Str.match(rx/ ^^ .* <{ $extension }> $$ /) {
                take $f
            }
        } else {
            take tree($f, $extension);
        }
    }

    return @files;
}

our sub to-single-quoted(Str $s) {
    '\'' ~ $s ~ '\''
}

our sub to-unquoted(Str $ss is copy) {
    if $ss ~~ / ^ '\'' (.*) '\'' $ / { return ~$0; }
    if $ss ~~ / ^ '"' (.*) '"' $ / { return ~$0; }
    return $ss;
}

##===========================================================
## Get dictionary words
##===========================================================
proto get-resource-words(Str $lang) is export {*};

multi get-resource-words('English') {
    my $txt = slurp %?RESOURCES<dictionary-words-English.txt>;
    return $txt.split("\n");
}

##===========================================================
## Convert rule to regex
##===========================================================

#| Converts a rule into a regex.
proto sub rule-to-regex($body) is export {*}

multi sub rule-to-regex(@bodies, Str $sep = ' | ') {
    if ! @bodies.all ~~ Str {
        die 'The first argument is expected to be a string or a Positional of strings.';
    }
    return @bodies.map({ rule-to-regex($_) }).join($sep);
}

multi sub rule-to-regex(Str $body is copy) {
    # This ad hoc implementation should be refactored
    # to use Grammar::TokenProcessing::ComprehensiveGrammar.
    $body = $body
            .subst(/ <wb> '-' <wb> /, ' <:Pd> ')
            .subst( / ('\'' <.alnum>+ '\'') \h* '?' /, { '[' ~ $0.Str ~ ' \h+ ]?' }, :g)
            .subst( / \s+ (<.alnum>+) \h* '?' /, { ' \h* [\h+ ' ~ $0.Str ~ ']?' }, :g)
            .subst( / <?after ['?' | <.alnum> | '\'' | ']']> \s+ <?before [ <.alnum> | '\'' | '\w' | '\d' | '[']> /, ' \h+ ', :g)
            .subst( / <?after ['\w' | '\d'] ['+' | '*']> \s+ <?before [ '\w' | '\d' | '<' ]> /, ' \h+ ', :g);

    return $body;
}

##===========================================================
## Grammar source code
##===========================================================

#| Gives the source of a grammar.
proto sub grammar-source-code(Grammar $gr, |) is export {*}

multi sub grammar-source-code(Grammar $gr,
                              :@exclusions is copy = Empty,
                              :@roles = Empty
        --> Str) {

    for @roles -> $r {
        @exclusions.append($r.^methods.map({ $_.name }).grep({ $_ ne 'TOP' }));
    }

    my $parents = $gr.^parents.map({ $_.^name }).grep({ $_ ∉ <Grammar Match Capture> });

    my @grLines;
    for $gr.^method_table.kv -> $name, $body {
        if $name ∉ @exclusions {
            @grLines.append: "\t{ $body.^name.lc } $name { $body.raku.subst(/ ^ .*? '{'/, '{') }";
        }
    }
    @grLines = @grLines.sort;
    my $indent = "\n{' ' x 'grammar'.chars}";
    @grLines.prepend: "grammar {$gr.^name} {@roles.map({"$indent does {$_.^name}"}).join} {$parents.map({"$indent is $_"}).join} \{";
    @grLines.append: '}';

    return @grLines.join("\n");
}

##===========================================================
## EBNF grammar
##===========================================================
#| Convert the corresponding EBNF grammar
proto sub to-ebnf-grammar($gr, |) is export {*}

multi sub to-ebnf-grammar(Grammar $gr, *%args) {
    my %args2 = %args.grep({ $_.key ne 'ws-marker' });
    my $focusGrammar = grammar-source-code($gr, |%args2);
    return to-ebnf-grammar($focusGrammar, |%args);
}

multi sub to-ebnf-grammar(Str $gr, *%args) {
    my Grammar::TokenProcessing::Actions::EBNF $actions .= new(ws-marker => %args<ws-marker> // Whatever);
    return Grammar::TokenProcessing::ComprehensiveGrammar.parse($gr, :$actions).made.trim;
}

##===========================================================
## Automatic top rule
##===========================================================
#| Gives the top rule of a grammar.
proto sub grammar-top-rule($gr) is export {*};

multi sub grammar-top-rule(Grammar $gr) {
    return grammar-top-rule(grammar-source-code($gr));
}

multi sub grammar-top-rule(Str $grCode) {
    my $rule = 'TOP';
    if !$grCode.contains(/ [rule | regex | token] \h+ TOP <wb> /) {
        if $grCode ~~ / [rule | regex | token] \h+ (<alnum>+) <wb> / {
            $rule = $0.Str;
        }
    }
    return $rule;
}

##===========================================================
## Get tokens
##===========================================================
proto get-tokens(Str $spec) is export {*}

multi get-tokens(Str $fileName where $fileName.IO.e) {
    die "The file given as first argument does not exist: $fileName ." if not $fileName.IO.e;

    #| Ingest file content
    my $program = slurp($fileName);

    return get-tokens($program)
}

multi get-tokens(Str $program where not $program.IO.e) {

    my $TokenGatherer = Grammar::TokenProcessing::Actions::Tokens.new;
    my $allTokens = Grammar::TokenProcessing::Grammar.parse($program, actions => $TokenGatherer).made;

    # say ' $allTokens : ', $allTokens;
    # say ' $TokenGatherer.gathered-tokens : ', $TokenGatherer.gathered-tokens;
    $allTokens = $TokenGatherer.gathered-tokens;

    return reallyflat($allTokens);
}

##===========================================================
## Get token names
##===========================================================
proto get-token-names(Str $spec) is export {*}

multi get-token-names(Str $fileName where $fileName.IO.e) {
    die "The file given as first argument does not exist: $fileName ." if not $fileName.IO.e;

    #| Ingest file content
    my $program = slurp($fileName);

    return get-token-names($program)
}

multi get-token-names(Str $program where not $program.IO.e) {

    my $TokenGatherer = Grammar::TokenProcessing::Actions::TokenNames.new;
    my $allTokens = Grammar::TokenProcessing::Grammar.parse($program, actions => $TokenGatherer).made;

    $allTokens = $TokenGatherer.gathered-tokens;

    return reallyflat($allTokens);
}

##===========================================================
## Get token names
##===========================================================
proto get-tokens-hash(Str $spec) is export {*}

multi get-tokens-hash(Str $fileName where $fileName.IO.e) {
    die "The file given as first argument does not exist: $fileName ." if not $fileName.IO.e;

    #| Ingest file content
    my $program = slurp($fileName);

    return get-tokens-hash($program)
}

multi get-tokens-hash(Str $program where not $program.IO.e) {

    my $TokenGatherer = Grammar::TokenProcessing::Actions::TokensHash.new;
    my %allTokens = Grammar::TokenProcessing::Grammar.parse($program, actions => $TokenGatherer).made;

    %allTokens = $TokenGatherer.gathered-tokens;
    # .map({ $_.key => [|reallyflat($_.value)] });

    return %allTokens;
}

##===========================================================
## Enhance token specs
##===========================================================
proto enhance-token-specs(Str $spec,
                          $output = Whatever,
                          Bool :$add-protos= False,
                          Str :$sym-name = '',
                          Bool :$add-exclusions = True,
                          :$stem-rules = Whatever,
                          :$nearest-neighbors-rules = Whatever,
                          :$method = 'nearest-neighbors',
                          :$func-name = Whatever) is export {*}

multi enhance-token-specs(Str $fileName where $fileName.IO.e,
                          $output = Whatever,
                          Bool :$add-protos= False,
                          Str :$sym-name = '',
                          Bool :$add-exclusions = True,
                          :$stem-rules = Whatever,
                          :$nearest-neighbors-rules = Whatever,
                          :$method = 'nearest-neighbors',
                          :$func-name = Whatever) is export {
    die "The file given as first argument does not exist: $fileName ." if not $fileName.IO.e;

    #| Ingest file content
    my $program = slurp($fileName);

    return enhance-token-specs($program, $output, :$add-protos, :$sym-name, :$add-exclusions, :$stem-rules, :$nearest-neighbors-rules, :$method, :$func-name)
}

multi enhance-token-specs(Str $program where not $program.IO.e,
                          $output = Whatever,
                          Bool :$add-protos = False,
                          Str :$sym-name = '',
                          Bool :$add-exclusions = True,
                          :$stem-rules = Whatever,
                          :$nearest-neighbors-rules = Whatever,
                          :$method is copy = 'nearest-neighbors',
                          :$func-name is copy = Whatever) {

    $method = $method.isa(Whatever) ?? 'nearest-neighbors' !! $method;
    die 'The argument $method is expected to be one of Whatever, \'nearest-neighbors\', or \'stem-rules\'.'
    unless $method.isa(Str);

    $func-name = $func-name.isa(Whatever) ?? 'is-fuzzy-match' !! $func-name;
    die 'The argument $func-name is expected to be a string or Whatever.' unless $func-name.isa(Str);

    #| Split the program into lines
    my @lines = $program.split("\n");

    #| Make the actions object
    my $ActObj;
    if $add-exclusions && $method.lc (elem) <stem stem-rules steming steming-rules> {
        #| Find all tokens in the grammar
        my $allTokens = get-tokens($program).unique;

        #| Make stem-to-tokens rules
        my $stemRulesLocal = $stem-rules;

        if $stem-rules.isa(Whatever) or not $stem-rules.isa(Map) {
            $stemRulesLocal = $allTokens.grep({ $_.isa(Str) and $_.chars > 0 }).classify({ porter($_.lc) });
        }

        note 'The value of the argument $stem-rules is not a Map object or Whatever. Using automatic stem-to-tokens rules.'
        when not $stem-rules.isa(Whatever) and not $stem-rules.isa(Map);

        $ActObj = Grammar::TokenProcessing::Actions::EnhancedTokens.new(:$add-protos, :$sym-name,
                stem-rules => $stemRulesLocal, :$func-name);

    } elsif $add-exclusions && $method.lc (elem) <nns nearest nearest-neighbors> {

        #| Find all tokens in the grammar
        my @allTokens = get-tokens($program).unique;

        #| For each word find its nearest neighbors
        my $nns = $nearest-neighbors-rules;
        if $nearest-neighbors-rules.isa(Whatever) or not $nearest-neighbors-rules.isa(Map) {
            $nns = @allTokens.map(-> $w { $w => @allTokens.map(-> $c { $c => dld($w, $c, 2) }).grep({ $_.value
                    .defined && $_.key ne $w })>>.key });
            $nns = $nns.grep({ $_.value })
        }

        note 'The value of the argument $nearest-neighbors-rules is not a Map object or Whatever. Using automatic stem-to-tokens rules.'
        when not $nearest-neighbors-rules.isa(Whatever) and not $nearest-neighbors-rules.isa(Map);

        $ActObj = Grammar::TokenProcessing::Actions::EnhancedTokens.new(:$add-protos, :$sym-name,
                nearest-neighbors-rules => $nns, :$func-name);

    } else {
        $ActObj = Grammar::TokenProcessing::Actions::EnhancedTokens.new(:$add-protos, :$sym-name, :$func-name);
    }

    #| Enhance tokens
    my @parseRes = map({ Grammar::TokenProcessing::Grammar.parse($_ ~ "\n", actions => $ActObj).made }, @lines);

    #| New program
    my $newProgram = @parseRes.join();

    # Output
    if so $output ~~ Str {
        spurt $output, $newProgram;
    } elsif $output.isa(Whatever) {
        say $newProgram;
    }

    return 0;
}


##===========================================================
## Random sentence generation
##===========================================================

sub random-part(Str $ruleBody is copy, $actObj) {

    my $res =
            Grammar::TokenProcessing::ComprehensiveGrammar.parse(
                    $ruleBody,
                    rule => 'token-comprehensive-body',
                    actions => $actObj,
                    ).made;

    return $res;
}

##------------------------------------------------------------
my %randomTokenGenerators =
        '<ws>' => -> { ' ' },
        '<.ws>' => -> { ' ' },
        '<.ws>?' => -> { [' ', ''].pick },
        '<alnum>' => -> { 'ALNUM(' ~ random-string(chars => 1, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ ')'},
        '<.alnum>' => -> { 'ALNUM(' ~ random-string(chars => 1, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ ')'},
        '<digit>' => -> { 'DIGIT(' ~ random-string(chars => 1, ranges => "0" .. "9") ~ ')'},
        '<.digit>' => -> { 'DIGIT(' ~ random-string(chars => 1, ranges => "0" .. "9") ~ ')'},
        '<:Pd>' => -> { '-' },
        '<punct>' => -> { 'PUNCT(' ~ random-string(chars=>1, ranges=><. ? ! ...>) ~ ')'},
        '<.punct>' => -> { 'PUNCT(' ~ random-string(chars=>1, ranges=><. ? ! ...>) ~ ')'},
        '<wl-expr>' => -> { 'WL_EXPR("Sqrt[3]")' },
        '<code-expr>' => -> { 'CODE_EXPR("1+1")' },
        '<shell-expr>' => -> { 'SHELL_EXPR("ls")' },
        '<regex-pattern>' => -> { 'REGEX("\w+")' },
        '<integer-value>' => -> { to-single-quoted 'INTEGER(' ~ random-real(300).round.Str ~ ')' },
        '<integer>' => -> { to-single-quoted 'INTEGER(' ~ random-real(300).round.Str ~ ')' },
        '<number-value>' => -> { to-single-quoted 'NUMBER(' ~ random-real(300).round(0.01).Str ~ ')' },
        '<number>' => -> { to-single-quoted 'NUMBER(' ~ random-real(300).round(0.01).Str ~ ')' },
        '<query-text>' => -> { to-single-quoted 'QUERY_TEXT("' ~ random-word(4).join(' ') ~ '")' },
        '<mixed-quoted-variable-name>' => -> { to-single-quoted 'VAR_NAME("' ~ random-string(chars => 5, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ '")' },
        '<quoted-variable-name>' => -> { to-single-quoted 'VAR_NAME("' ~ random-string(chars => 5, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ '")' },
        '<variable-name>' => -> { to-single-quoted 'VAR_NAME("' ~ random-string(chars => 5, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ '")' },
        '<dataset-name>' => -> { to-single-quoted 'DATASET_NAME("' ~ random-string(chars => 5, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ '")' },
        '<function-name>' => -> { to-single-quoted 'FUNC_NAME("' ~ random-string(chars => 5, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ '")' },
        '<raku-module-name>' => -> { to-single-quoted 'MODULE_NAME("' ~ random-string(chars => 8, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ '")' },
        '<list-separator>' => -> { to-single-quoted [',', 'and'].pick },
        '<list-separator>?' => -> { to-single-quoted [',', 'and', ' '].pick };

sub default-random-token-generators(-->Hash) is export { %randomTokenGenerators }

##------------------------------------------------------------
proto take-rule-body(|) {*}

multi sub take-rule-body(Str $ruleKey is copy,
                         %rules,
                         %tokenGenerators,
                         Str $sym = 'English') {

    return take-rule-body($ruleKey, %rules, %tokenGenerators, [$sym,]);
}

multi sub take-rule-body(Str $ruleKey is copy,
                         %rules,
                         %tokenGenerators,
                         @syms = ['English', ]) {

    if (! so $ruleKey.trim ~~ / ^ '<' .*  '>' $ /) && $ruleKey.trim ne 'TOP' {
        return $ruleKey;
    }

    if $ruleKey && %tokenGenerators.elems > 0 {
        if %tokenGenerators{$ruleKey.trim}:exists {
            return %tokenGenerators{$ruleKey}.();
        }
    }

    if $ruleKey.trim eq 'TOP' {
        $ruleKey = $ruleKey.trim;
    } else {
        $ruleKey = $ruleKey.Str.trim.substr(1, *- 1).subst(/ ^ \. /, '');
    }

    if %rules{$ruleKey}:exists {

        # Get a sym definition if found.
        for @syms -> $sym {
            if %rules{$ruleKey ~ ':sym<' ~ $sym ~ '>'}:exists {
                $ruleKey = $ruleKey ~ ':sym<' ~  $sym  ~ '>';
                last;
            }
        }

        # Get the gist of rule's body
        my $ruleVal = %rules{$ruleKey}.gist;
        if not so $ruleVal ~~ Str {
            warn "Cannot get a rule body for $ruleKey.";
        }
        return take-rule-body($ruleVal);
    } else {
        warn "Cannot find a rule body for $ruleKey.";
    }
    return $ruleKey;
}

multi sub take-rule-body(Str $definition is copy) {

    # DSL specific: Here we remove the rule parts that allow fuzzy matching
    $definition = $definition.subst(/ '|' \h* '([\w]+) <?{' .* '}>' /, '').subst(':i', '');

    # Take the rule definition (e.g. remove `token some-name {`).
    if $definition ~~ / ^ (<-[{]>*) '{' \h* (.*) \h* '}' (.*) $ / {
        $definition = ~$1
    };

    # Replicate / unfold simple quantifier specs.
    # For example, `token tenner { [<digit> <:Pd>?] ** 3 }`:
    # 1) Is changed above as `[<digit> <:Pd>?] ** 3`,
    # 2) Then here it is changed into `[<digit> <:Pd>?] [<digit> <:Pd>?] [<digit> <:Pd>?]`
    if $definition ~~ / ^ \h* '[' \h* (.*) \h* ']' \h* '**' \h* (\d+) \h* $ / {
        $definition = ( ('[' ~ $0 ~ ']') xx +$1).join(' ')
    };

    # Removing bracketed in-rule code
    $definition = $definition.subst( / [ '\{' | '{' ] <-[{}]>* '}' | '<' . '{' <-[{}]>* '}>' /, ''):g;

    # Remove in-rule variables
    $definition = $definition.subst( / [ ':my' | ':our' ] \s+ <-[;]>+ ';' /, ''):g;

    # Removing new lines
    $definition = $definition.subst("\n", ''):g;

    # (The trim is probably not needed)
    return $definition.trim;
}

##------------------------------------------------------------
sub replace-definitions(Str $ruleBody, %rules, $actObj, %tokenGenerators, $syms = 'English' ) {

    my @resBodies = |random-part($ruleBody, $actObj);
    @resBodies = |@resBodies.map({ $_ ~~ Str ?? take-rule-body($_, %rules, %tokenGenerators, $syms) !! '' });

    return @resBodies;
}

##------------------------------------------------------------
#| Generate random sentence.
#| C<$grammar> : A grammar. (Using 'TOP' as C<$ruleBody>.)
#| C<$ruleBody> : The body of the rule to start generating with.
#| C<%rules> : Rule-to-definition pairs.
#| C<$max-iterations> : Max iterations to recursively replace rule definitions.
#| C<$max-random-list-elements> : Max number of elements in lists (to pick with.)
#| C<$random-token-generators> : Rule-to-function pairs used to generate leaf literals.
#| C<$sep> : Separator of the join literals; if not a string no joining is done.
#| C<$sym> : Sym string to concretize proto rules with.
proto sub random-sentence-generation(|) is export {*}

multi sub random-sentence-generation(Grammar $grammar, Str $ruleBody = '<TOP>', *%args) {
    return random-sentence-generation($ruleBody, $grammar.^method_table, |%args);
}

multi sub random-sentence-generation(Str $ruleBody,
                                     %rules,
                                     UInt :$max-iterations = 40,
                                     UInt :$max-random-list-elements = 6,
                                     :$random-token-generators = Whatever,
                                     :$sep = ' ',
                                     :$syms = 'English') is export {

    my Grammar::TokenProcessing::Actions::RandomSentence $actObj .= new(:$max-random-list-elements);

    return random-sentence-generation($ruleBody, %rules, $actObj, :$max-iterations, :$random-token-generators, :$sep, :$syms);
}

multi sub random-sentence-generation(Str $ruleBody,
                                     %rules,
                                     $actObj,
                                     UInt :$max-iterations = 40,
                                     :$random-token-generators is copy = Whatever,
                                     :$sep = ' ',
                                     :$syms is copy = 'English'
                                   ) is export {

    # Process $random-token-generators
    if $random-token-generators.isa(Whatever) || $random-token-generators.isa(WhateverCode) {
        $random-token-generators = default-random-token-generators();
    }

    die "The argument random-token-generators is expected to be Whatever, WhateverCode, or a Map of token names to functions."
    unless $random-token-generators ~~ Map;

    if $syms.isa(Whatever) { $syms = 'English'; }

    # Main loop
    my @res = random-part($ruleBody, $actObj);
    @res = |replace-definitions($ruleBody, %rules, $actObj, $random-token-generators, $syms);
    @res = reallyflat(@res);
    my UInt $k = 0;
    while so @res.join(' ') ~~ / '<' <-[<>]>+ '>' | .+ '|' .+ / && $k++ < $max-iterations {
        #note 'random-sentence-generation : '.uc, $k, ' : ', @res.raku;
        @res = @res.map({ random-part($_, $actObj) });
        @res = reallyflat(@res).map({ $_ ~~ Str ?? replace-definitions($_, %rules, $actObj, $random-token-generators, $syms) !! '' });
        @res = reallyflat(@res);
    }

    #note 'random-sentence-generation : '.uc, 'END : ', @res.raku;
    # Post-process
    @res = @res.grep({ $_.trim.chars > 0 })>>.&to-unquoted;

    # Result
    return $sep ~~ Str ?? @res.join($sep).trim !! @res;
}