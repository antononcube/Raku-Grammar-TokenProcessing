#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Grammar::TokenProcessing;
use Grammar::TokenProcessing::ComprehensiveGrammar;

use DSL::English::LatentSemanticAnalysisWorkflows::Grammar;

#say Grammar::TokenProcessing::Grammar.parse('<table-noun>?', rule => 'repetition');
#say Grammar::TokenProcessing::Grammar.parse(' <rows> | <records>', rule => 'alternation');
#say Grammar::TokenProcessing::Grammar.parse('[ <rows> | <records> ]', rule => 'group');
#say Grammar::TokenProcessing::ComprehensiveGrammar.parse('<table-noun>? [ <rows> | <records> ]', rule => 'token-comprehensive-body');


my $focusGrammar = DSL::English::LatentSemanticAnalysisWorkflows::Grammar;

my %focusRules = $focusGrammar.^method_table;

.say for %focusRules.keys.grep({ $_.contains('command') }).sort;

say '-' x 120;
say %focusRules<topics-parameters-spec>;
say '-' x 120;
say %focusRules<topics-parameters-list>;
say '-' x 120;

say '=' x 120;

#say generate-random-sentence('<table-noun>? [ <rows> | <records> ]');

#my $ruleBody = '<table-noun>? [ <rows> | <records> ]';
#my $ruleBody = '<statistics-command>';
#my $ruleBody = '<topics-extraction-command>';
#my $ruleBody = '<show-thesaurus-command>';
#my $ruleBody = '<make-doc-term-matrix-command>';
my $ruleBody = '<workflow-command>';
#my $ruleBody = '<trivial-parameter-none>';

#say Grammar::TokenProcessing::ComprehensiveGrammar.parse("'none' | 'no' | 'NA'", rule => 'token-comprehensive-body');
#
#say random-part("[ <compute-directive> | <extract-directive> ] <topics-spec> [ <topics-parameters-spec> ]?").raku;

#say generate-random-sentence($ruleBody, %focusRules);

my @randSentences = (^10).map({ generate-random-sentence($ruleBody, %focusRules, max-iterations => 40).subst("' '", " "):g }).sort.unique;

.say for @randSentences;
