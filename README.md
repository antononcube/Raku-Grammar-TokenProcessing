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
# utilize the object VAR_NAME("g3ksl")
# compute anomalies with threshold
# simple object creation DATASET_NAME("4Lchj")
# make an object directly DATASET_NAME("cXqJA")
# compute the data bottom outliers
# compute and display outliers by the probabilities Range [  NUMBER(212) ,  NUMBER(251)  NUMBER(204) ]
# compute anomalies by residuals by the threshold
# utilize quantile regression object VAR_NAME("PiSsm")
# show date list diagram date origin
# show QuantileRegression , fitted QuantileRegressionFit and outliers
```

Here is another example using the Bulgarian localization of [AAp5] in [AAp7]:

```shell
random-sentence-generation DSL::Bulgarian::QuantileRegressionWorkflows::Grammar  -n=10 --syms='Bulgarian English'
```
```
# ехо чертежи за относителен грешка чертежи
# ехо дата списък чертеж чрез дата нула
# присвои на VAR_NAME("9wPWH") обект
# покажи масив от данни and дейтасет , времеви серия дата списък чертежи
# рекапитулирай данни
# изчисли аномалии от остатъци чрез праг
# изтрий липсващи
# движещ Median чрез
# рекапитулирай  данни
# изчисли квантила регресия пасване чрез  вероятност Range [  NUMBER(272) ,  NUMBER(116) ,  NUMBER(127) ] , чрез and , and  възли , INTEGER(158) възли , INTEGER(116) интерполация степен , чрез интерполация порядък INTEGER(131) , INTEGER(30) възли
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
# I ♥ ♥ ♥ Python
# I love Rust
# I love Perl
# I hate Ruby
# I 🖕 Python
```


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
