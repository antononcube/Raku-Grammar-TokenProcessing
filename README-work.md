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

### Gather tokens

```shell
get-tokens --help                                                                                     
```

### Gather tokens into a hash

```shell
get-tokens-hash --help                                                                                     
```

### Replace token names

```shell
replace-token-names --help                                                                                     
```

### Random sentence generation

```shell
random-sentence-generation --help
```

Here is example of random sentence generation based on the grammar of the package 
["DSL::English::QuantileRegressionWorkflows"](https://raku.land/zef:antononcube/DSL::English::QuantileRegressionWorkflows), [AAp5]:

```shell
random-sentence-generation DSL::English::QuantileRegressionWorkflows::Grammar
```

Here is another example using the Bulgarian localization of [AAp5] in [AAp7]:

```shell
random-sentence-generation DSL::Bulgarian::QuantileRegressionWorkflows::Grammar  -n=10 --syms='Bulgarian English'
```

Here we generate sentences with a grammar string (that is a valid Raku definition of a grammar):

```shell
random-sentence-generation -n=5 "
grammar Parser {
    rule  TOP  { I <love> <lang> }
    token love { '♥' ** 1..3 | love }
    token lang { < Raku Perl Rust Go Python Ruby > }
}"
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
