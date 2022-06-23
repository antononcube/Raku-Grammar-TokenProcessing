# Raku Grammar::TokenProcessing

## In brief

Raku package for processing (gathering, enhancing, etc.) of token specs in grammar and role classes.

Installation:

```shell
zef install https://github.com/antononcube/Raku-Grammar-TokenProcessing.git
```

-------

## Examples 


### Gather tokens

Usage via the Command Line Interface (CLI) of UNIX-like operating systems:

```shell
> GetTokens  --help                                                                                     
Usage:
  GetTokens [--token-names] <inputFileName> -- Get tokens from token lines in grammar roles.
  GetTokens [--token-names] [--per-file] [<args> ...]
  
    <inputFileName>    Input file name.
    --token-names      Should the tokens name gathered or the token literals? [default: False]
    [<args> ...]       Input file names.
    --per-file         Should the tokens be printed out per file or not? [default: False]
```

### Add fuzzy matching to token specs

```shell
> AddFuzzyMatching --help
Usage:
  AddFuzzyMatching [-o|--output[=Any]] [--add-protos] [--sym-name=<Str>] [--add-exclusions] [--method=<Str>] [--func-name=<Str>] <inputFileName> -- Transform a token lines in a grammar role into token lines with fuzzy matching.
  
    <inputFileName>      Input file name.
    -o|--output[=Any]    Output file; if not given the output is STDOUT.
    --add-protos         Should proto tokens/rules/regexes be added or not. [default: False]
    --sym-name=<Str>     Sym name. I and empty string ('') then no sym is put in. [default: '']
    --add-exclusions     Should exclusions be added to token extensions or not? [default: True]
    --method=<Str>       Method to find the word exclusions; one of 'nearest-neighbors' and 'stem-rules'. [default: 'nearest-neighbors']
    --func-name=<Str>    Function name to do fuzzy matching with. [default: 'is-fuzzy-match']
```
