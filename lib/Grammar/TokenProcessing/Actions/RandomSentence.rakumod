use v6.d;

use Grammar::TokenProcessing::ComprehensiveGrammar;
use Grammar::TokenProcessing::Actions::Tokens;

sub reallyflat (+@list) {
    gather @list.deepmap: *.take
}

sub to-single-qouted(Str $s) { '\'' ~ $s ~ '\'' }

class Grammar::TokenProcessing::Actions::RandomSentence
        is Grammar::TokenProcessing::Actions::Tokens {

    has $.max-random-list-elements = 12;

    method TOP($/) {
        self.gathered-tokens = $/.values>>.made.grep({ $_ ~~ Pair && $_.key.defined && $_.key.chars > 0 });
        make self.gathered-tokens;
    }

    method token-spec($/) { make $/.Str; }

    method token-name-spec($/) { make $/.Str; }

    method white-space-regex($/) {
        make do given $/.Str {
            when $_ ∈ ['\\h*', '\\s*'] { ' ' x (^4).pick }
            when $_ ∈ ['\\h+', '\\s+'] { ' ' x (1..4).pick }
            default { $/.Str }
        };
    }

    method alnumd($/) { make $/.Str; }

    method var-name($/) { make $/.Str; }

    method token-renamed-spec($/) { make '<' ~ $<var-name>.made ~ '>'; }

    method token-spec-element($/) { make $/.values[0].made; }

    method repeat-spec-delim($/) {
        # The repetitions delimiter matcher is not comprehensive.
        # Hence, we just stringify it.
        my $sep = $/.Str;
        # Initially this was hard-coded.
        # It seems better to move it to the generation rules hash.
        # See %randomTokenGenerators in ../TokenProcessing.rakumod .
        #given $sep.trim {
        #    when '<list-separator>' {
        #        $sep = to-single-qouted( [', ', 'and'].pick );
        #    }
        #when $_ ~~ / '<list-separator>' \h* '?' / {
        #        $sep = to-single-qouted( [', ', 'and', ' '].pick );
        #    }
        #}
        make $sep;
    }

    method repetition($/) {
        my $rep = $<repeat-spec> ?? $<repeat-spec>.Str !! '';
        make do given $rep {
            when so $<repeat-spec><repeat-spec-for-lists> {
                my @res = (1...(1..$!max-random-list-elements).pick).map({ $<element>.made });
                my $sep = $<repeat-spec><repeat-spec-for-lists><repeat-spec-delim>.made;
                $sep = $sep.trim eq 'ws' ?? ' ' !! $sep;
                ((@res Z ($sep xx @res.elems)).flat)[^(*-1)]
            }
            when $_ eq '?' { rand > 0.5 ?? $<element>.made !! '' }
            when $_ eq '+' { (1...(1..$!max-random-list-elements).pick).map({ $<element>.made }).unique.Array }
            when $_ eq '*' { (0...(1..$!max-random-list-elements).pick).map({ $<element>.made }).unique.Array }
            default { $<element>.made }
         }
    }

    method concatenation($/) { make $<repetition>>>.made; }

    method alternation($/) { make $<concatenation>>>.made.pick; }

    method group($/) { make $/.values[0].made; }

    method element($/) { make $/.values[0].made;}

    method token-comprehensive-body($/) {
        make reallyflat($/.values>>.made)>>.trim;
    }

}
