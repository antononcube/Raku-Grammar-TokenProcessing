 use v6.d;

use Lingua::EN::Stem::Porter;

class Grammar::TokenProcessing::Actions::EnhancedTokens {

    has @.do-not-enhance = <a an and by do for from get load of per set that the to use with>;

    has Bool $.add-protos = False;
    has Str $.sym-name = 'General';
    has %.stem-rules = %();
    has %.nearest-neighbors-rules = %();
    has Str $.func-name = 'is-fuzzy-match';

    # method reduce($op, @list) {
    #   return @list[0] if @list.elems == 1;
    #   return [$op, |@list];
    # }

    # method TOP($/) { make self.reduce('\n', $/.values».made); }

    method TOP($/) {
        make $/.values>>.made.flat.join()
    }

    method empty-line($/) {
        make $/.Str;
    }

    method comment-line($/) {
        make $/.Str;
    }

    method leading-space($/) {
        make $/.Str;
    }

    method code-line($/) {
        make $/.Str;
    }

    method token-definition-end($/) {
        make $/.Str;
    }

    method token($/) {
        make $/.Str;
    }

    method token-name-spec($/) {
        make $/.Str;
    }

    method token-spec($/) {

        #| Get the token string
        my Str $term = $/.Str;
        if $term ~~ / ^ [ '\'' .* '\'' | '"' .* '"' ] $ / {
            $term .= substr(1, $/.Str.chars - 2);
        }

        if $term (elem) self.do-not-enhance {
            make $/.Str;
        } else {

            #| Make the "not one of" condition
            my Str $notoneof = '';

            if $term.chars > 0 {

                my @words;

                if self.stem-rules {
                    # Stem rules
                    my Str $stem = porter($term);
                    if self.stem-rules{$stem}:exists {
                        @words = (self.stem-rules{$stem} (-) $term).keys;
                    }

                } elsif self.nearest-neighbors-rules {
                    # Nearest-neighbors riles
                    if self.nearest-neighbors-rules{$term}:exists {
                        @words = |self.nearest-neighbors-rules{$term};
                    }
                }

                if @words.defined && @words.elems > 0 {
                    given @words.elems {
                        when $_ == 1 { $notoneof = '$0.Str ne \'' ~ @words.join(' ') ~ '\' and ' }
                        when $_ > 1 { $notoneof = '$0.Str !(elem) <' ~ @words.join(' ') ~ '> and ' }
                    }
                }
            }

            #| Levenshtein distance
            my $wlenExt =
                    do given $term.chars {
                        when $_ == 3 { ', 1' }
                        when $_ > 3 { ', 2' }
                        default { '' }
                    }

            #| Enhance the token
            if $term.chars > 2 {
                make $/.Str ~ ' | ' ~ '([\w]+) <?{ ' ~ $notoneof ~ self.func-name ~ '($0.Str, ' ~ $/
                        .Str ~ $wlenExt ~ ') }>';
            } else {
                make $/.Str;
            }
        }
    }

    method token-quoted-list-body($/) {
        warn 'No token enhancement is done for quoted list bodies.';
        make $/.Str;
    }

    method token-simple-body($/) {
        make ($/.values>>.made).join(' | ');
    }

    method token-phrase-body($/) {
        if $/.values.elems > 3 {
            make "\n" ~ (' ' x 8) ~ ($/.values>>.made).join(" |\n" ~ (' ' x 8))
        } else {
            make ($/.values>>.made).join(' | ')
        }
    }

    method token-complex-body($/) {
        make $/.Str;
    }

    method token-code-regex-body($/) {
        make $/.Str;
    }

    method token-body($/) {
        make $/.values[0].made;
    }

    method token-spec-list($/) {
        make $/.values>>.made.join(' ');
    }

    method token-rule-definition($/) {
        my Str $res = '';
        if self.add-protos {
            $res = "\n" ~ $res ~ $<leading-space>.made ~ 'proto ' ~ $<token>.made ~ ' ' ~ $<token-name-spec>
                    .made ~ ' {*}' ~ "\n";
        }

        my $sym = self.sym-name.chars == 0 ?? '' !! ":sym<{ self.sym-name }>";
        my $tokenBody = $<token-body>.made;
        my $opts = $<token>.made eq 'token' ?? ' :i' !! '';
        $res = $res ~ $<leading-space>.made ~ $<token>.made ~ ' ' ~ $<token-name-spec>
                .made ~ $sym ~ ' {' ~ $opts ~ ' ' ~ $tokenBody ~ ' }' ~ "\n";

        make $res;
    }

}
