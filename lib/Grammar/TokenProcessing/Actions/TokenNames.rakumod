use v6.d;

class Grammar::TokenProcessing::Actions::TokenNames {

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
        make $/.Str;
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
        make '';
    }

    method token-rule-definition($/) {
        make $<token-name-spec>.made;
    }
}
