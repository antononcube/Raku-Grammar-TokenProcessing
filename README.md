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
  ./bin/GetTokens <inputFileName> -- Get tokens from token lines in a grammar role.
  ./bin/GetTokens [<args> ...]
  
    <inputFileName>    Input file name.
    [<args> ...]       Input file names.
```

### Add fuzzy matching to toke specs

```shell
> AddFuzzyMatching --help
Usage:
  ./bin/AddFuzzyMatching [-o|--output[=Any]] [--add-proto-token] [--sym-name=<Str>] [--add-exclusions] <inputFileName> -- Transform a token lines in a grammar role into token lines with fuzzy matching.
  
    <inputFileName>      Input file name.
    -o|--output[=Any]    Output file; if not given the output is STDOUT.
    --add-proto-token    Should a proto token be added or not. [default: False]
    --sym-name=<Str>     Sym name. I and empty string ('') then no sym is put in. [default: '']
    --add-exclusions     Should exclusions be added to token extensions or not? [default: True]
```
