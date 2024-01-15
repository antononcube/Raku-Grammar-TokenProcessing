use v6.d;

use Grammar::TokenProcessing::ComprehensiveGrammar;
use Grammar::TokenProcessing::Actions::Tokens;

sub reallyflat (+@list) {
    gather @list.deepmap: *.take
}

sub to-unquoted(Str $ss is copy) {
    if $ss ~~ / ^ '\'' (.*) '\'' $ / { return ~$0; }
    if $ss ~~ / ^ '"' (.*) '"' $ / { return ~$0; }
    return $ss;
}

sub to-unbracketed($ss is copy) {
    if $ss ~~ Str:D && $ss ~~ / ^ '<' (.*) '>' $ / { return ~$0; }
    return $ss;
}

sub to-single-quoted(Str $s) { '\'' ~ $s ~ '\'' }

class Grammar::TokenProcessing::Actions::RandomSentence
        is Grammar::TokenProcessing::Actions::Tokens {

    has $.max-random-list-elements is rw = 12;
    has %.generators is rw;

    method TOP($/) {
        self.gathered-tokens = $/.values>>.made.grep({ $_ ~~ Pair && $_.key.defined && $_.key.chars > 0 });

        my %h = self.gathered-tokens.clone.Hash;

        #.note for |%h.pairs.sort(*.key);

        my @res = |%h<TOP>;

        loop {
            my $changes = 0;
            for @res.kv -> $i, $element is copy {

                $element .= subst(/ ^ '<' \./, '<');

                my $uElement = to-unbracketed($element);

                # If the element is a non-terminal look for rules to replace it with
                if $element ~~ / ^ '<' .*? '>' $ / {
                    if %h{$element} // %h{$uElement} // False {
                        @res[$i] = %h{$element} // %h{$uElement};
                        $changes++;
                    } elsif %!generators{$element} // %!generators{$uElement} // False {
                        @res[$i] = self.apply-generators-rule($element);
                        $changes++;
                    }
                }
            }
            @res = @res.&reallyflat;
            last if $changes == 0;
        }

        make @res;
    }

    method token-spec($/) { make to-unquoted($/.Str); }

    method token-name-spec($/) {
        my $tokenName = $/.Str.trim;

        my $genRes = self.apply-generators-rule($tokenName);

        with $genRes {
            make $genRes;
        } else {
            make $/.Str;
        }
    }

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

    method backslashed-char-class($/) {
        given $/.Str.trim {
            when '\w' { make '<alnum>'; }
            when '\d' { make '<digit>'; }
            default { make ' '; }
        };
    }

    method repeat-spec-delim($/) {
        my $sep = $/.Str.trim;
        $sep = self.apply-generators-rule($sep);
        with $sep {
            make $sep;
        } else {
            make $/.Str;
        }
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
            when so $<repeat-spec><repeat-range> {
                my $from = $<repeat-spec><repeat-range><from> // 0;
                my $to = $<repeat-spec><repeat-range><to> // 0;
                if so $<repeat-spec><repeat-range><count> {
                    $from = $<repeat-spec><repeat-range><count>.Str.Int;
                    $to = $<repeat-spec><repeat-range><count>.Str.Int;
                }
                my @res = (1...($from..$to).pick).map({ $<element>.made });
                @res
            }
            when $_ eq '?' { rand > 0.5 ?? $<element>.made !! '' }
            when $_ eq '+' { (1...(1..$!max-random-list-elements).pick).map({ $<element>.made }).unique.Array }
            when $_ eq '*' { (0...(1..$!max-random-list-elements).pick).map({ $<element>.made }).unique.Array }
            default { $<element>.made }
         }
    }

    method concatenation($/) { make $<repetition>>>.made; }

    method alternation($/) {
        if $<token-quoted-list-body> {
            make $<token-quoted-list-body>.made.pick;
        } else {
            make $<concatenation>>>.made.pick;
        }
    }

    method group($/) { make $/.values[0].made; }

    method element($/) { make $/.values[0].made;}

    method token-code-regex-body($/) {
        #with $<arg> { $!regex-arg = $<arg>.Str; }
        make $/.Str.subst(/ ^ \s* '<{' | '}>' \s* $ /):g;
    }

    method token-comprehensive-body($/) {
        make reallyflat($/.values>>.made).Array;
    }

    method token-rule-definition($/) {

        my $tokenName = $<token-name-spec>.Str.trim;

        my $genRes = self.apply-generators-rule($tokenName);

        with $genRes {

            make $genRes;

        } else {

            my @res;
            if $<token-variables-list> {
                @res.push($<token-variables-list>.made);
            }

            if $<token-code-block> {
                @res.push("CODE-BLOCK");
            }
            @res.push($<token-comprehensive-body>.made);
            make Pair.new($<token-name-spec>.Str, @res.elems > 1 ?? @res !! @res[0]);
        }
    }

    #------------------------------------------------------
    method apply-generators-rule(Str $tokenName is copy, %rules = %!generators) {
        $tokenName = $tokenName.subst(/ ^ '<' \./, '<');
        my $uTokenName = to-unbracketed($tokenName);
        $tokenName = "<$uTokenName>";

        if %rules{$tokenName} // %rules{$uTokenName} // False {
            my $rg = %rules{$tokenName} // %rules{$uTokenName};
            return to-unquoted($rg.());
        }
        return Nil;
    }
}
