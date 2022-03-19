use v6.d;

use Lingua::EN::Stem::Porter;

class Grammar::TokenProcessing::Actions::EnhancedTokens {

    has @.do-not-enhance = <a an and by do for from get load of per set that the to use with>;

    has Bool $.add-protos = False;
    has Str $.sym-name = 'General';
    has %.stem-rules = %();

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
        my Str $term = substr($/.Str, 1, $/.Str.chars - 2);

        if $term (elem) self.do-not-enhance {
            make $/.Str;
        } else {

            #| Make the "not one of" condition
            my Str $notoneof = '';
            if $term.chars > 0 {
                my Str $stem = porter($term);
                if self.stem-rules and self.stem-rules{$stem}:exists {
                    my @words = (self.stem-rules{$stem} (-) $term).keys;
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
                        when $_ > 3 { ', 2'}
                        default { '' }
                    }

            #| Enhance the token
            if $term.chars > 2 {
                make $/.Str ~ ' | ' ~ '([\w]+) <?{ ' ~ $notoneof ~ 'is-fuzzy-match($0.Str, ' ~ $/.Str ~ $wlenExt ~ ') }>';
            } else {
                make $/.Str;
            }
        }
    }

    method token-simple-body($/) {
        make ($/.values>>.made).join(' | ');
    }

    method token-complex-body($/) {
        make $/.Str;
    }

    method token-rule-definition($/) {
        my Str $res = '';
        if self.add-protos {
            $res = "\n" ~ $res ~ $<leading-space>.made ~ 'proto ' ~ $<token>.made ~ ' ' ~ $<token-name-spec>.made ~ ' {*}' ~ "\n";
        }

        my $sym = self.sym-name.chars == 0 ?? '' !! ":sym<{self.sym-name}>";
        my $tokenBody = $<token-complex-body> ?? $<token-complex-body>.made !! $<token-simple-body>.made;
        my $opts = $<token>.made eq 'token' ?? ' :i' !! '';
        $res = $res ~ $<leading-space>.made ~ $<token>.made ~ ' ' ~ $<token-name-spec>.made ~ $sym ~' {' ~ $opts ~ ' ' ~ $tokenBody ~ ' }' ~ "\n";

        make $res;
    }

}
