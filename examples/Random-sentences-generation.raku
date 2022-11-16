#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Grammar::TokenProcessing;
use Grammar::TokenProcessing::ComprehensiveGrammar;

use DSL::English::LatentSemanticAnalysisWorkflows::Grammar;
use DSL::English::RecommenderWorkflows::Grammar;
use DSL::English::ClassificationWorkflows::Grammar;
use DSL::English::QuantileRegressionWorkflows::Grammar;
use DSL::English::DataQueryWorkflows::Grammar;
use DSL::Shared::Roles::CommonStructures;

use Mathematica::Grammar;
use Chemistry::Stoichiometry::Grammar;
use Markdown::Grammar;

#say Grammar::TokenProcessing::Grammar.parse('<table-noun>?', rule => 'repetition');
#say Grammar::TokenProcessing::Grammar.parse(' <rows> | <records>', rule => 'alternation');
#say Grammar::TokenProcessing::Grammar.parse('[ <rows> | <records> ]', rule => 'group');
#say Grammar::TokenProcessing::ComprehensiveGrammar.parse('<table-noun>? [ <rows> | <records> ]', rule => 'token-comprehensive-body');


#my $focusGrammar = DSL::English::LatentSemanticAnalysisWorkflows::Grammar;
#my $focusGrammar = DSL::English::DataQueryWorkflows::Grammar;
#my $focusGrammar = DSL::English::RecommenderWorkflows::Grammar;
#my $focusGrammar = DSL::English::ClassificationWorkflows::Grammar;
#my $focusGrammar = DSL::English::QuantileRegressionWorkflows::Grammar;
#my $focusGrammar = Mathematica::Grammar;
#my $focusGrammar = Markdown::Grammar;
my $focusGrammar = Chemistry::Stoichiometry::Grammar;

#my $focusGrammar = grammar LLoveParser {
#    rule  TOP  { <workflow-command> }
#    rule  workflow-command  { I <love> <lang> }
#    token love { '♥' | love }
#    token lang { Raku | Perl | Rust | Go | Python | Ruby }
#}

my %focusRules = $focusGrammar.^method_table;

#.say for %focusRules.keys.sort;
#.say for %focusRules.keys.grep({ $_.contains('command') }).sort;
#.say for %focusRules.sort;

say '-' x 120;
say %focusRules<topics-parameters-spec>;
say '-' x 120;
say %focusRules<topics-parameters-list>;
say '-' x 120;

say '=' x 120;

#say generate-random-sentence('<table-noun>? [ <rows> | <records> ]');

#my $ruleBody = '<workflow-command>';
#my $ruleBody = '<expr>';
#my $ruleBody = '<md-block>+';
my $ruleBody = '<mixture>';

#say Grammar::TokenProcessing::ComprehensiveGrammar.parse("'none' | 'no' | 'NA'", rule => 'token-comprehensive-body');
#
#say random-part("[ <compute-directive> | <extract-directive> ] <topics-spec> [ <topics-parameters-spec> ]?").raku;

#say generate-random-sentence($ruleBody, %focusRules);

my Grammar::TokenProcessing::Actions::RandomSentence $actObj .= new(max-random-list-elements => 6);

#$actObj = $actObj but DSL::Shared::Roles::CommonStructures.new;
my @randSentences = (^10).map({ generate-random-sentence($ruleBody, %focusRules, $actObj, max-iterations => 40).subst("' '", " "):g }).sort.unique;

.say for @randSentences;
