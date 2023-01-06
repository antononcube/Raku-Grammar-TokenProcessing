
use Grammar::TokenProcessing;
use Grammar::TokenProcessing::Grammar;
use Grammar::TokenProcessing::Actions::EnhancedTokens;
use Grammar::TokenProcessing::Actions::Tokens;
use Grammar::TokenProcessing::Actions::TokenNames;
use Lingua::EN::Stem::Porter;


##===========================================================
## Data
##===========================================================

my $rfile0 = q:to/EOI/;
role Simple {

  token top { 'top' }
  token ar { 'ar' }
  token recommend { 'recommend' | 'suggest' }
  token recommender { 'recommender' | 'suggester' }
  token suggest { 'suggest' | 'recommend' | 'propose' }
  token nearest-neighbors { 'nearest' 'neighbours' }
  token nearest-neighbors-phrase { [ 'closest' | 'nearest' ] 'neighbours' }
  rule recommend-nns { <recommend> <nearest-neighbors> }

}
EOI

# say $rfile0;

my $rfile1 = q:to/EOI/;
# Simple grammar role.

role Simple::Role {

  token history:sym<English> { 'history'  }
  token accuracies-noun:sym<English> { 'accuracies' }
  token recommend { 'recommend' | 'suggest'  }
  token recommender { 'recommender' | 'suggester' }
  token suggest { 'suggest' | 'recommend' | 'propose' }
  token with-preposition { 'with' | 'using' | 'by' }
  token nearest-neighbors { 'nearest' 'neighbours' }
  token items-slot:sym<items> { 'items' }
  rule recommend-nns { <recommend> <nearest-neighbors> }

}
EOI

my $rfile2 = q:to/EOI/;
role CommonTerms {
    token weight { <weight-noun> }
    token weight-adjective { 'весовой' | 'весовая' | 'весовое' | 'весовые' }
    token weight-noun { 'вес'  }
}
EOI

##===========================================================
## Examples
##===========================================================

#say Grammar::TokenProcessing::Grammar.subparse($rfile2);
#say Grammar::TokenProcessing::Grammar.subparse($rfile2, rule => 'token-rule-definition');

#say '-' x 120;
#say get-token-names($rfile1);
#say get-tokens($rfile1).raku;
#say get-tokens-hash($rfile1).raku;
#
#say to-json(get-tokens-hash($rfile1));

#enhance-token-specs($rfile0, Whatever, :add-exclusions, stem-rules => Whatever);
#
enhance-token-specs(
        $rfile2,
        Whatever,
        :add-exclusions,
        :add-protos,
        sym-name => 'Russian',
        stem-rules => Whatever,
        func-name => Whatever);
