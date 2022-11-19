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

our sub single-qouted(Str $s) {
    '\'' ~ $s ~ '\''
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

    return enhance-token-specs($program, $output, :$add-protos, :$sym-name, :$add-exclusions, :$stem-rules,
            :$nearest-neighbors-rules, :$method, :$func-name)
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
        '<integer-value>' => -> { single-qouted 'INTEGER(' ~ random-real(300).round.Str ~ ')' },
        '<integer>' => -> { single-qouted 'INTEGER(' ~ random-real(300).round.Str ~ ')' },
        '<number-value>' => -> { single-qouted ' NUMBER(' ~ random-real(300).round.Str ~ ')' },
        '<number>' => -> { single-qouted ' NUMBER(' ~ random-real(300).round.Str ~ ')' },
        '<query-text>' => -> { single-qouted 'QUERY_TEXT("' ~ random-word(4).join(' ') ~ '")' },
        '<mixed-quoted-variable-name>' => -> { single-qouted 'VAR_NAME("' ~ random-string(chars => 5, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ '")' },
        '<quoted-variable-name>' => -> { single-qouted 'VAR_NAME("' ~ random-string(chars => 5, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ '")' },
        '<variable-name>' => -> { single-qouted 'VAR_NAME("' ~ random-string(chars => 5, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ '")' },
        '<dataset-name>' => -> { single-qouted 'DATASET_NAME("' ~ random-string(chars => 5, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ '")' },
        '<function-name>' => -> { single-qouted 'FUNC_NAME("' ~ random-string(chars => 5, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ '")' },
        '<raku-module-name>' => -> { single-qouted 'MODULE_NAME("' ~ random-string(chars => 8, ranges => ['a' ..'z', 'A' .. 'Z', "0" .. "9"]) ~ '")' };

sub default-random-token-generators(-->Hash) is export { %randomTokenGenerators }

##------------------------------------------------------------
proto take-rule-body(|) {*}

multi sub take-rule-body(Str $ruleKey is copy,
                         %rules,
                         %tokenGenerators) {

    if not so $ruleKey.trim ~~ / ^ '<' .*  '>' $ / {
        return $ruleKey;
    }

    if $ruleKey && %tokenGenerators.elems > 0 {
        if %tokenGenerators{$ruleKey.trim}:exists {
            return %tokenGenerators{$ruleKey}.();
        }
    }

    $ruleKey = $ruleKey.Str.trim.substr(1, *- 1).subst(/ ^ \. /, '');

    if %rules{$ruleKey}:exists {
        if %rules{$ruleKey ~ ':sym<English>'}:exists {
            $ruleKey = $ruleKey ~ ':sym<English>';
        }
        my $ruleVal = %rules{$ruleKey}.gist;
        if not so $ruleVal ~~ Str {
            warn "Cannot get a rule body for $ruleKey.";
        }
        return take-rule-body($ruleVal);
    }
    return $ruleKey;
}

multi sub take-rule-body(Str $definition is copy) {

    #note $definition;
    #note $definition.raku;
    $definition = $definition.subst(/ '|' \h* '([\w]+) <?{' .* '}>' /, '').subst(':i', '');
    #note $definition.raku;
    $definition ~~ s/ ^ (.*) '{' \h* (.*) \h* '}' (.*) $ / $1 /;
    $definition = $definition.subst("\n", ''):g;
    #note 'take-rule-body : '.uc, $definition.raku;
    return $definition.trim;
}

##------------------------------------------------------------
sub replace-definitions(Str $ruleBody, %rules, $actObj, %tokenGenerators ) {

    my @resBodies = |random-part($ruleBody, $actObj);
    @resBodies = |@resBodies.map({ $_ ~~ Str ?? take-rule-body($_, %rules, %tokenGenerators) !! '' });

    return @resBodies;
}

##------------------------------------------------------------
proto sub generate-random-sentence(Str $ruleBody, %rules, |) is export {*}

multi sub generate-random-sentence(Str $ruleBody,
                                   %rules,
                                   UInt :$max-iterations = 40,
                                   UInt :$max-random-list-elements = 6,
                                   :$random-token-generators) is export {

    my Grammar::TokenProcessing::Actions::RandomSentence $actObj .= new(:$max-random-list-elements);

    return generate-random-sentence($ruleBody, %rules, $actObj, :$max-iterations, :$random-token-generators);
}

multi sub generate-random-sentence(Str $ruleBody,
                                   %rules,
                                   $actObj,
                                   UInt :$max-iterations = 40,
                                   :$random-token-generators is copy = Whatever
                                   ) is export {

    # Process $random-token-generators
    if $random-token-generators.isa(Whatever) || $random-token-generators.isa(WhateverCode) {
        $random-token-generators = default-random-token-generators();
    }

    die "The argument random-token-generators is expected to be Whatever, WhateverCode, or a Map of token names to functions."
    unless $random-token-generators ~~ Map;

    # Main loop
    my @res = random-part($ruleBody, $actObj);
    @res = |replace-definitions($ruleBody, %rules, $actObj, $random-token-generators);
    @res = reallyflat(@res);
    my UInt $k = 0;
    while so @res.join(' ') ~~ / '<' <-[<>]>+ '>' | .+ '|' .+ / && $k++ < $max-iterations {
        #note 'generate-random-sentence : '.uc, $k, ' : ', @res.raku;
        @res = @res.map({ random-part($_, $actObj) });
        @res = reallyflat(@res).map({ $_ ~~ Str ?? replace-definitions($_, %rules, $actObj, $random-token-generators) !! '' });
        @res = reallyflat(@res);
    }
    #note 'generate-random-sentence : '.uc, 'END : ', @res.raku;
    return @res.grep({ $_.trim.chars > 0 }).join(' ').trim;
}