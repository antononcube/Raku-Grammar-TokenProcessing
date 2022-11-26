use v6.d;

class Grammar::TokenProcessing::Actions::TokensHash {

    has %.gathered-tokens = {};

    method TOP($/) {
        self.gathered-tokens = $/.values>>.made.grep({ $_ ~~ Pair && $_.key.defined && $_.key.chars > 0 });
        make self.gathered-tokens;
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
        make $/.Str;
    }

    method token-quoted-list-body($/) {
        make $/.Str.words[1,*-1];
    }

    method token-simple-body($/) {
        make $/.values>>.made;
    }

    method token-phrase-body($/) {
        make $/.values>>.made.join(' ');
    }

    method token-complex-body($/) {
        make $/.values>>.made;
    }

    method token-body($/) {
        make $/.values[0].made;
    }

    method token-spec($/) {
        my Str $term = substr($/.Str, 1, $/.Str.chars - 2);
        make $term;
    }

    method token-spec-list($/) {
        make $/.values>>.made.join(' ');
    }

    method token-rule-definition($/) {
        make $<token-name-spec>.made => $<token-body>.made;
    }
}
