use v6.d;

class Grammar::TokenProcessing::Actions::Tokens {

    has @.gathered-tokens = [];

    method TOP($/) {
        my $arr = $/.values>>.made.flat>>.Str.grep({ $_.defined and $_.chars > 0 }).unique.Array;
        self.gathered-tokens = |$arr;
        make $arr;
    }

    method empty-line($/) {
        make '';
    }

    method comment-line($/) {
        make '';
    }

    method leading-space($/) {
        make '';
    }

    method code-line($/) {
        make '';
    }

    method token-definition-end($/) {
        make '';
    }

    method token($/) {
        make '';
    }

    method token-name-spec($/) {
        make '';
    }

    method token-quoted-list-body($/) {
        make $/.Str.words[1,*-1];
    }

    method token-simple-body($/) {
        make $/.values>>.made;
    }

    method token-phrase-body($/) {
        make '';
    }

    method token-complex-body($/) {
        make '';
    }

    method token-body($/) {
        make $/.values[0].made;
    }

    method token-spec($/) {
        my Str $term = substr($/.Str, 1, $/.Str.chars - 2);
        make $term;
    }

    method token-spec-list($/) {
        make $/.values>>.made;
    }

    method token-rule-definition($/) {
        make $<token-body>.made;
    }
}
