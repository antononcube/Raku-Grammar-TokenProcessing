use v6.d;

use Grammar::TokenProcessing;
use DSL::English::LatentSemanticAnalysisWorkflows::Grammar;
use DSL::English::ClassificationWorkflows::Grammar;


##===========================================================
## Data
##===========================================================

my $grSpec = q:to/EOI/;
grammar Simple
        is DSL::English::LatentSemanticAnalysisWorkflows::Grammar
        is DSL::English::ClassificationWorkflows::Grammar
{

  token TOP { <recommend-nns> |
              <DSL::English::LatentSemanticAnalysisWorkflows::Grammar::workflow-command> |
              <DSL::English::ClassificationWorkflows::Grammar::workflow-command> }
  token ar { 'ar' }
  token recommend {[ 'recommend' | 'suggest' ] { make 'RECS'; }}
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

#.say for $gr.^method_table;

# Print out grammar source code
say grammar-source-code($gr);

#------------------------------------------------------------------------------------------------------------------------
say '-' x 120;

my $gr2 = EVAL grammar-source-code($gr).subst('Simple', 'Simple2');

# Example parsing
say ::('Simple2').parse('recommend nearest neighbours');

say '-' x 120;

# Example parsing with the LSA grammar
say ::('Simple2').parse('extract 20 topics');

say '-' x 120;

# Example parsing with the ClCon grammar
say ::('Simple2').parse('split the data with ratio 0.8');
