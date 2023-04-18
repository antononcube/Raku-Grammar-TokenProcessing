
use Grammar::TokenProcessing;


##===========================================================
## Data
##===========================================================

my $grSpec = q:to/EOI/;
grammar Simple {

  token TOP { <recommend-nns> }
  token ar { 'ar' }
  token recommend { 'recommend' | 'suggest' }
  token recommender { 'recommender' | 'suggester' }
  token suggest { 'suggest' | 'recommend' | 'propose' }
  token nearest-neighbors { 'nearest' \h+ [ neighbours | neighbors ] }
  token nearest-neighbors-phrase { [ 'closest' | 'nearest' ] 'neighbours' }
  rule recommend-nns { <recommend> \h+ <nearest-neighbors> }

}
EOI

#------------------------------------------------------------------------------------------------------------------------
use MONKEY-SEE-NO-EVAL;
my $gr = EVAL($grSpec);

#------------------------------------------------------------------------------------------------------------------------
say '-' x 120;

# Print out grammar source code
say grammar-source-code($gr);

#------------------------------------------------------------------------------------------------------------------------
say '-' x 120;

my $gr2 = EVAL grammar-source-code($gr).subst('Simple', 'Simple2');

# Example parsing
say ::('Simple2').parse('recommend nearest neighbours');

