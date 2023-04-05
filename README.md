# Raku Grammar::TokenProcessing

## In brief

Raku package for processing grammar files in order to:

- Extract tokens

- Replace token names

- Add fuzzy matching expressions in token definitions

- Random sentence generation

**Remark:** This package is made mostly to automate tasks for the DSL system of packages, see:
[Raku-DSL-*](https://github.com/search?q=user%3Aantononcube+Raku-DSL).
Hence, the package is tested "just" over files written with a particular style and goal.

------

## Installation

Installation from [Zef ecosystem](https://raku.land):

```
zef install Grammar::TokenProcessing
```

Installation from GitHub:

```
zef install https://github.com/antononcube/Raku-Grammar-TokenProcessing.git
```

-------

## Examples 

Below are shown usages via the Command Line Interface (CLI) of UNIX-like operating systems.


### Add fuzzy matching to token specs

```shell
add-token-fuzzy-matching --help
```
```
# Usage:
#   add-token-fuzzy-matching <inputFileName> [-o|--output[=Any]] [--add-protos] [--sym-name=<Str>] [--add-exclusions] [--method=<Str>] [--func-name=<Str>] -- Transform a token lines in a grammar role into token lines with fuzzy matching.
#   
#     <inputFileName>      Input file name.
#     -o|--output[=Any]    Output file; if not given the output is STDOUT.
#     --add-protos         Should proto tokens/rules/regexes be added or not. [default: False]
#     --sym-name=<Str>     Sym name. I and empty string ('') then no sym is put in. [default: '']
#     --add-exclusions     Should exclusions be added to token extensions or not? [default: True]
#     --method=<Str>       Method to find the word exclusions; one of 'nearest-neighbors' and 'stem-rules'. [default: 'nearest-neighbors']
#     --func-name=<Str>    Function name to do fuzzy matching with. [default: 'is-fuzzy-match']
```

### Gather tokens

```shell
get-tokens --help                                                                                     
```
```
# Usage:
#   get-tokens <inputFileName> [--token-names] -- Get tokens from token lines in grammar roles.
#   get-tokens [<args> ...] [--token-names] [--per-file]
#   
#     <inputFileName>    Input file name.
#     --token-names      Should the token names be gathered or the token literals? [default: False]
#     [<args> ...]       Input file names.
#     --per-file         Should the tokens be printed out per file or not? [default: False]
```

### Gather tokens into a hash

```shell
get-tokens-hash --help                                                                                     
```
```
# Usage:
#   get-tokens-hash <inputFileName> [--format=<Str>] -- Get tokens from token lines in grammar roles.
#   get-tokens-hash [<args> ...] [--format=<Str>] [--per-file]
#   
#     <inputFileName>    Input file name.
#     --format=<Str>     Format of the output. One of 'hash', 'raku', or 'json'. [default: 'json']
#     [<args> ...]       Input file names.
#     --per-file         Should the tokens be printed out per file or not? [default: False]
```

### Replace token names

```shell
replace-token-names --help                                                                                     
```
```
# Usage:
#   replace-token-names <dirName> <pairs> [--file-ext=<Str>] [--file-new-ext=<Str>] -- Replaces token names in files.
#   
#     <dirName>               Directory with files to be processed.
#     <pairs>                 CSV file with replacement pairs. The first column has the original token names; the second column has the new names.
#     --file-ext=<Str>        Extension(s) pattern of the files to be processed. [default: '.rakumod']
#     --file-new-ext=<Str>    Extension to be added to newly obtained files. If NONE the file content is overwritten. [default: '.new']
```

### Random sentence generation

```shell
random-sentence-generation --help
```
```
# Usage:
#   random-sentence-generation <grammar> [--rule-body=<Str>] [-n[=UInt]] [--max-iterations[=UInt]] [--max-random-list-elements[=UInt]] [--sep=<Str>] [--syms=<Str>] -- Generates random sentences for a given grammar.
#   
#     <grammar>                            Grammar name or definition.
#     --rule-body=<Str>                    Rule body (to start generation with.) [default: 'TOP']
#     -n[=UInt]                            Number of sentences. [default: 10]
#     --max-iterations[=UInt]              Max number of recursive rule replacement iterations. [default: 40]
#     --max-random-list-elements[=UInt]    Max number of elements to use generate random lists. [default: 6]
#     --sep=<Str>                          Separator of the join literals; if 'NONE' Raku code lists are returned. [default: ' ']
#     --syms=<Str>                         A string that is a sym or a space separated syms to concretize proto rules with. [default: 'English']
```

Here is example of random sentence generation based on the grammar of the package 
["DSL::English::QuantileRegressionWorkflows"](https://raku.land/zef:antononcube/DSL::English::QuantileRegressionWorkflows), [AAp5]:

```shell
random-sentence-generation DSL::English::QuantileRegressionWorkflows::Grammar
```
```
# compute anomalies with residuals using the threshold NUMBER(12.44)
# resample
# echo plot the error plot
# compute and show bottom the time series data outliers
# take utilize using DATASET_NAME("RMwQ9")
# rescale axes
# show outliers
# compute anomalies using residuals by threshold NUMBER(270.37)
# moving map WL_EXPR("Sqrt[3]") using the NUMBER(76.54) NUMBER(94.92) NUMBER(215.75) and NUMBER(9.17) , NUMBER(57.94) weights
# show date list diagram by date origin DIGIT(9) DIGIT(8) DIGIT(8) DIGIT(9) - DIGIT(4) DIGIT(6) - DIGIT(8) DIGIT(5)
```

Here is another example using the Bulgarian localization of [AAp5] in [AAp7]:

```shell
random-sentence-generation DSL::Bulgarian::QuantileRegressionWorkflows::Grammar  -n=10 --syms='Bulgarian English'
```
```
# изчисли и покажи  дейта сет извънредности чрез Range [ NUMBER(92.56) , NUMBER(245.24) and NUMBER(136.3) NUMBER(225.38) ] вероятност
# прави квантила регресия пасване
# присвои канален обект до VAR_NAME("z5TbI")
# изчисли QuantileRegression пасване със от NUMBER(16.9) до NUMBER(173.46) стъпка NUMBER(27.55) възли
# рекапитулирай данни
# ползвай  дейта сет VAR_NAME("RZRo7")
# премащабирай  оси
# вземи ползвай от DATASET_NAME("3SKQm")
# изчисли и покажи  извънредности чрез  от NUMBER(172.37) към NUMBER(91.13) чрез стъпка NUMBER(193.01)
# изчисли времеви серия данни извънредности чрез  Range[ NUMBER(70.13) NUMBER(177.74) and NUMBER(169.68) NUMBER(222.75) ]
```

Here we generate sentences with a grammar string (that is a valid Raku definition of a grammar):

```shell
random-sentence-generation -n=5 "
grammar Parser {
    rule  TOP  { I [ <love> | <hate> ] <lang> }
    token love { '♥' ** 1..3 | love }
    token hate { '🖕' ** 1..2 | hate }
    token lang { < Raku Perl Rust Go Python Ruby > }
}"
```
```
# I ♥ ♥ Go
# I love Perl
# I love Perl
# I love Raku
# I 🖕 Perl
```

### Converting rules to regexes

Here are examples of converting rules to regexes:

```perl6
use Grammar::TokenProcessing;

my %ruleBodies =
        cookie => 'generic? chocolate cookie \w+ \d+',
        cookie-limited => 'crunch bar \d ** 1..2';

for %ruleBodies.kv -> $k, $v {
    say "rule   : $v";
    say "regex  : {rule-to-regex($v)}\n";
}
```
```
# rule   : generic? chocolate cookie \w+ \d+
# regex  : generic? \h+ chocolate \h+ cookie \h+ \w+ \h+ \d+
# 
# rule   : crunch bar \d ** 1..2
# regex  : crunch \h+ bar \h+ \d ** 1..2
```

More detailed examples -- with grammar creation for regex verification -- can be found in the test file 
["06-rule-to-regex-conversion.rakutest"](./t/06-rule-to-regex-conversion.rakutest).

--------

## References

### Packages

[AAp1] Anton Antonov,
[DSL::Shared, Raku package](https://github.com/antononcube/Raku-DSL-Shared),
(2018-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[DSL::English::ClassificationWorkflows, Raku package](https://github.com/antononcube/Raku-DSL-General-ClassificationWorkflows),
(2018-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[DSL::English::DataQueryWorkflows, Raku package](https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows),
(2020-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[DSL::English::LatentSemanticAnalysisWorkflows, Raku package](https://github.com/antononcube/Raku-DSL-General-LatentSemanticAnalysisWorkflows),
(2018-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[DSL::English::QuantileRegressionWorkflows, Raku package](https://github.com/antononcube/Raku-DSL-General-QuantileRegressionWorkflows),
(2018-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp6] Anton Antonov,
[DSL::English::RecommenderWorkflows, Raku package](https://github.com/antononcube/Raku-DSL-General-RecommenderWorkflows),
(2018-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp7] Anton Antonov,
[DSL::Bulgarian, Raku package](https://github.com/antononcube/Raku-DSL-Bulgarian),
(2022),
[GitHub/antononcube](https://github.com/antononcube).
