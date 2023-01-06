#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Grammar::TokenProcessing;
use Grammar::TokenProcessing::ComprehensiveGrammar;

use DSL::English::ClassificationWorkflows::Grammar;
use DSL::English::DataAcquisitionWorkflows::Grammar;
use DSL::English::DataQueryWorkflows::Grammar;
use DSL::English::LatentSemanticAnalysisWorkflows::Grammar;
use DSL::English::QuantileRegressionWorkflows::Grammar;
use DSL::English::RecommenderWorkflows::Grammar;
use DSL::Shared::Roles::CommonStructures;

use Mathematica::Grammar;
use Chemistry::Stoichiometry::Grammar;
use Markdown::Grammar;

use Data::Generators;
use Data::Reshapers;

#say Grammar::TokenProcessing::Grammar.parse('<table-noun>?', rule => 'repetition');
#say Grammar::TokenProcessing::Grammar.parse(' <rows> | <records>', rule => 'alternation');
#say Grammar::TokenProcessing::Grammar.parse('[ <rows> | <records> ]', rule => 'group');
#say Grammar::TokenProcessing::ComprehensiveGrammar.parse('<table-noun>? [ <rows> | <records> ]', rule => 'token-comprehensive-body');


#my $focusGrammar = DSL::English::ClassificationWorkflows::Grammar;
#my $focusGrammar = DSL::English::DataAcquisitionWorkflows::Grammar;
#my $focusGrammar = DSL::English::DataQueryWorkflows::Grammar;
#my $focusGrammar = DSL::English::LatentSemanticAnalysisWorkflows::Grammar;
#my $focusGrammar = DSL::English::QuantileRegressionWorkflows::Grammar;
#my $focusGrammar = DSL::English::RecommenderWorkflows::Grammar;

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
.say for %focusRules.keys.grep({ $_.contains('random') }).sort;
#.say for %focusRules.sort;

#say '-' x 120;
#say %focusRules<topics-parameters-spec>;
#say '-' x 120;
#say %focusRules<topics-parameters-list>;

say '=' x 120;

#my $ruleBody = '<workflow-command>';
#my $ruleBody = '<random-tabular-data-generation-command>';
#my $ruleBody = '<random-tabular-dataset-arguments-list>';
#my $ruleBody = '<random-tabular-dataset-argument>';
#my $ruleBody = '<moving-func-command>';
#my $ruleBody = '<topics-extraction-command>';
#my $ruleBody = '<make-classifier-command>';
my $ruleBody = '<chemical-equation>';


my Grammar::TokenProcessing::Actions::RandomSentence $actObj .= new(max-random-list-elements => 3);

#$actObj = $actObj but DSL::Shared::Roles::CommonStructures.new;

my %randomTokenGenerators = default-random-token-generators();
%randomTokenGenerators{'<number-value>'} = -> { random-real(10).round.Str };
%randomTokenGenerators{'<number>'} = %randomTokenGenerators{'<number-value>'};
%randomTokenGenerators{'<integer-value>'} =  -> { random-real(10).round.Str };
%randomTokenGenerators{'<integer>'} = %randomTokenGenerators{'<integer-value>'};
%randomTokenGenerators{'<yield-symbol>'} = -> { ['=', '->'].pick };
%randomTokenGenerators{'<white-space-regex>'} = '';
%randomTokenGenerators{'<entity-data-type-name>'} = -> { 'ENTITY_DATA_TYPE_NAME("' ~ random-string(1) ~ '")' };
%randomTokenGenerators{'<entity-name>'} = -> { 'ENTITY_NAME("' ~ random-string(1) ~ '")' };
%randomTokenGenerators{'<entity-metadata-name>'} = -> { 'ENTITY_METADATA_NAME("' ~ random-string(1) ~ '")' };
%randomTokenGenerators{'<entity-dataset-name>'} = %randomTokenGenerators{'<dataset-name>'};

# Note that if the separator is not a string a list is returned.
# The lists can be seen with the .deepmap line print-out.
# In that case unique has to be called with the as => { $_.join(' ') } .
my @randSentences = (^40).map({ random-sentence-generation(
        $ruleBody,
        %focusRules,
        $actObj,
        max-iterations => 100,
        random-token-generators => %randomTokenGenerators,
        sep => Whatever) }).sort.unique(as => { $_.join(' ') });

#say to-pretty-table(@randSentences.map({ Sentence => $_ }));
#say to-pretty-table(transpose(@randSentences.kv));
#say to-pretty-table(@randSentences.deepmap(*.raku).pairs, align=>'l', field-names=><Key Value>);
say to-pretty-table(@randSentences.pairs, align=>'l', field-names=><Key Value>);
