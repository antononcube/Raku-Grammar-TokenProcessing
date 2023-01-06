#!/usr/bin/env raku
use v6.d;

use Data::Generators;
use Data::Reshapers;
use Data::Summarizers;

use DSL::Shared::Utilities::ComprehensiveTranslation;

use Text::CSV;

use Grammar::TokenProcessing;
use Data::Reshapers;

my @grammars = [DSL::English::ClassificationWorkflows::Grammar,
                DSL::English::DataQueryWorkflows::Grammar,
                DSL::English::LatentSemanticAnalysisWorkflows::Grammar,
                DSL::English::QuantileRegressionWorkflows::Grammar,
                DSL::English::RecommenderWorkflows::Grammar];

.say for @grammars.map({ .^name });

my %randomTokenGenerators = default-random-token-generators;
%randomTokenGenerators{'<yield-symbol>'} = -> { ['=', '->'].pick };
%randomTokenGenerators{'<white-space-regex>'} = '';
%randomTokenGenerators{'<entity-data-type-name>'} = -> { 'ENTITY_DATA_TYPE_NAME("' ~ random-string(1) ~ '")' };
%randomTokenGenerators{'<entity-name>'} = -> { 'ENTITY_NAME("' ~ random-string(1) ~ '")' };
%randomTokenGenerators{'<entity-metadata-name>'} = -> { 'ENTITY_METADATA_NAME("' ~ random-string(1) ~ '")' };
%randomTokenGenerators{'<entity-dataset-name>'} = %randomTokenGenerators{'<dataset-name>'};
%randomTokenGenerators{'<word-value>'} = -> { 'WORD("' ~ random-string(1) ~ '")' };
%randomTokenGenerators{'<numeric-word-form>'} = %randomTokenGenerators{'<integer-value>'};

my $nSentences = 100;
my @tblRes;

my $tstart = now;
for @grammars -> $focusGrammar {
    my %focusRules = $focusGrammar.^method_table;

    my @commandRules = %focusRules.keys.grep({ $_ ~~ / .* '-command' $ / });

    if $focusGrammar.^name ne "DSL::English::DataQueryWorkflows::Grammar" {
        @commandRules .= grep({ $_ !~~ / ^ [ dsl | user | setup | workflow | pipeline ] '-' .* / });
    }

    my $gname = $focusGrammar.^name.subst("DSL::English::","").subst("::Grammar","");

    say '-' x 120;
    say $gname, " : ";
    .say for @commandRules;

    for @commandRules.sort -> $cr {
        my @randSentences = (^$nSentences).map({ random-sentence-generation(
                '<' ~ $cr ~ '>',
                %focusRules,
                max-iterations => 100,
                random-token-generators => Whatever,
                sep => ' ') }).sort.unique;

        @tblRes = @tblRes.append( (@randSentences Z ^@randSentences.elems ).map({ %(Grammar => $gname, Rule => $cr, Command => $_[0], Index => $_[1]) }) );
    }

    say $gname, " : ", dimensions(@tblRes);
}

say "Total time: {now - $tstart}.";

# Show summary
records-summary(@tblRes, field-names=><Grammar Rule Index Command>);

# Show sample
say to-pretty-table(@tblRes.pick(12), field-names=><Grammar Rule Index Command>, align=>'l');

# Export
csv( in => @tblRes, out => "./Random-DSL-commands-$nSentences.csv");


