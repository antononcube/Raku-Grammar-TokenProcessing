=begin pod

=head1 AddFuzzMatching

C<AddFuzzMatching> package has grammar classes and action classes for the parsing
Raku Perl 6 grammar files and making a file with token grammar rules that are
extended to have fuzzy matching function calls.

=head1 Synopsis

    use AddFuzzMatching;
    enhance-token-specs( $fileName, output, :add-protos, sym-name => 'English', :add-exclusions);

=end pod
use v6.d;

unit module Grammar::TokenProcessing;

use Grammar::TokenProcessing::Grammar;
use Grammar::TokenProcessing::Actions::EnhancedTokens;
use Grammar::TokenProcessing::Actions::Tokens;
use Grammar::TokenProcessing::Actions::TokenNames;

use Lingua::EN::Stem::Porter;

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

    return $allTokens;
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

    return $allTokens;
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
                          :$func-name = Whatever) is export {*}

multi enhance-token-specs(Str $fileName where $fileName.IO.e,
                          $output = Whatever,
                          Bool :$add-protos= False,
                          Str :$sym-name = '',
                          Bool :$add-exclusions = True,
                          :$stem-rules = Whatever,
                          :$func-name = Whatever) is export {
    die "The file given as first argument does not exist: $fileName ." if not $fileName.IO.e;

    #| Ingest file content
    my $program = slurp($fileName);

    return enhance-token-specs($program, $output, :$add-protos, :$sym-name, :$add-exclusions, :$stem-rules, :$func-name)
}

multi enhance-token-specs(Str $program where not $program.IO.e,
                          $output = Whatever,
                          Bool :$add-protos = False,
                          Str :$sym-name = '',
                          Bool :$add-exclusions = True,
                          :$stem-rules = Whatever,
                          :$func-name is copy = Whatever) {

    $func-name = $func-name.isa(Whatever) ?? 'is-fuzzy-match' !! $func-name;
    die 'The arugment $func-name is expected to be a string or Whatever.' unless $func-name.isa(Str);

    #| Split the program into lines
    my @lines = $program.split("\n");

    #| Make the actions object
    my $ActObj;
    if $add-exclusions {
        #| Find all tokens in the grammar
        my $allTokens = get-tokens($program);

        #| Make stem-to-tokens rules
        my $stemRulesLocal = $stem-rules;

        if $stem-rules.isa(Whatever) or not $stem-rules.isa(Map) {
            $stemRulesLocal = $allTokens.grep({ $_.isa(Str) and $_.chars > 0 }).classify({ porter($_.lc) });
        }

        note 'The value of the argument $stem-rules is not a Map object or Whatver. Using automatic stem-to-tokens rules.'
        when not $stem-rules.isa(Whatever) and not $stem-rules.isa(Map);

        $ActObj = Grammar::TokenProcessing::Actions::EnhancedTokens.new(:$add-protos, :$sym-name, stem-rules => $stemRulesLocal, :$func-name);

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