use v6.d;

use Grammar::TokenProcessing::ComprehensiveGrammar;
use Grammar::TokenProcessing::Actions::Tokens;

sub reallyflat (+@list) {
    gather @list.deepmap: *.take
}

sub to-single-qouted(Str $s) { '\'' ~ $s ~ '\'' }

class Grammar::TokenProcessing::Actions::EBNF
        is Grammar::TokenProcessing::Actions::Tokens {

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
        make "{ $/.Str }";
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

        make $rep ?? "\{{ $/.Str }\}" !! $/.Str;
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
