use lib '.';

use Grammar::TokenProcessing;
use Grammar::TokenProcessing::Grammar;
use Grammar::TokenProcessing::Actions::EnhancedTokens;
use Grammar::TokenProcessing::Actions::Tokens;
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
  rule recommend-nns { <recommend> <nearest-neighbors> }

}
EOI

# say $rfile0;

my $rfile1 = q:to/EOI/;
# Simple grammar role.

role Simple::Role {

  token history { 'history'  }
  token recommend { 'recommend' | 'suggest'  }
  token recommender { 'recommender' | 'suggester' }
  token suggest { 'suggest' | 'recommend' | 'propose' }
  token with-preposition { 'with' | 'using' | 'by' }
  token nearest-neighbors { 'nearest' 'neighbours' }
  token items-slot:sym<items> { 'items' }
  rule recommend-nns { <recommend> <nearest-neighbors> }

}
EOI


##===========================================================
## Examples
##===========================================================


enhance-token-specs($rfile0, Whatever, :add-exclusions, stem-rules => Whatever);

enhance-token-specs(
        $rfile1,
        Whatever,
        :add-exclusions,
        :add-protos,
        sym-name => 'English',
        stem-rules => Whatever,
        func-name => Whatever);
