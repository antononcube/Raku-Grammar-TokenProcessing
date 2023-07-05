use v6.d;

use lib '.';
use lib './lib';

use Grammar::TokenProcessing;
use DSL::English::LatentSemanticAnalysisWorkflows::Grammar;
use DSL::English::ClassificationWorkflows::Grammar;
use DSL::English::DataQueryWorkflows::Grammarish;


##===========================================================
## Data
##===========================================================

my $grSpec = q:to/EOI/;
grammar Simple
        does DSL::English::DataQueryWorkflows::Grammarish
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

#note DSL::English::DataQueryWorkflows::Grammarish.^methods;
#note DSL::English::DataQueryWorkflows::Grammarish.^methods.map({ $_.name });

#.say for $gr.^method_table;
# One way
#my grammar Dummy does DSL::English::DataQueryWorkflows::Grammarish {};
#my @exclusions = Dummy.^method_table.keys;
#say grammar-source-code($gr, :@exclusions);

# Second way
#my @exclusions = DSL::English::DataQueryWorkflows::Grammarish.^methods.map({ $_.name });
#my @exclusions = Empty;
#say grammar-source-code($gr, :@exclusions);

# Print out grammar source code
say grammar-source-code($gr, roles => [DSL::English::DataQueryWorkflows::Grammarish, ]);

# Print out grammar top rule
say grammar-top-rule($gr);

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
