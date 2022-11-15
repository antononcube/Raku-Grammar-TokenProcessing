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
