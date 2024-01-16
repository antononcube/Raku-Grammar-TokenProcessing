use v6.d;

use Grammar::TokenProcessing::ComprehensiveGrammar;
use Grammar::TokenProcessing::Actions::Tokens;

class Grammar::TokenProcessing::Actions::EBNF
        is Grammar::TokenProcessing::Actions::Tokens {

    has $.ws-marker = Whatever;

    method TOP($/) {
        self.gathered-tokens = $/.values>>.made;
        make self.gathered-tokens.join("\n");
    }

    method token-spec($/) {
        make $/.Str;
    }

    method token-name-spec($/) {
        make $/.Str;
    }

    method white-space-regex($/) {
        make self.ws-marker.isa(Whatever) ?? $/.Str !! self.ws-marker.Str;
    }

    method alnumd($/) {
        make $/.Str;
    }

    method var-name($/) {
        make $/.Str;
    }

    method token-renamed-spec($/) {
        make '<' ~ $<var-name>.made ~ '>';
    }

    method token-spec-element($/) {
        make $/.values[0].made;
    }

    method backslashed-char-class($/) {
        given $/.Str.trim {
            when '\w' { make '<alnum>'; }
            when '\d' { make '<digit>'; }
            default { make ' '; }
        };
    }

    method repeat-spec-delim($/) {
        my $sep = $/.Str;
        make $sep;
    }

    method repetition($/) {
        my $rep = $<repeat-spec> ?? $<repeat-spec>.Str !! '';

        if $<element><token-spec-element><white-space-regex> {
            make $<element><token-spec-element><white-space-regex>.made;
        } elsif $rep && $<repeat-spec>.Str.trim eq '?' {
            make "[{ $<element>.made }]";
        } elsif $rep && $<repeat-spec>.Str.trim ∈ <* +> {
            make "\{{ $<element>.made }\}";
        } else {
            make $/.Str;
        }
    }

    method concatenation($/) {
        make $<repetition>>>.made.join(' , ');
    }

    method alternation($/) {
        #note $/.Str;
        if $<token-quoted-list-body> {
            #note '1: ', $<token-quoted-list-body>.made;
            make $<token-quoted-list-body>.made.join(' | ');
        } else {
            #note '2: ', $<concatenation>>>.made;
            make $<concatenation>>>.made.join(' | ');
        }
    }

    method group($/) {
        make $/.values[0].made;
    }

    method element($/) {
        make $/.values[0].made;
    }

    method token-comprehensive-body($/) {
        make $/.values>>.made.join(' ');
    }

    method token-rule-definition($/) {
        my $res = "<{$<token-name-spec>.Str}> = {$<token-comprehensive-body>.made} ;";
        make $res;
    }
}
