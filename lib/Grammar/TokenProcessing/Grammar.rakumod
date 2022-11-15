use v6;

unit module Grammar::TokenProcessing::Grammar;

##===========================================================
## Grammar
##===========================================================

grammar Grammar::TokenProcessing::Grammar  {

  regex TOP { [ <token-rule-definition> | <empty-line> | <comment-line> | <code-line> ]+ }

  token empty-line { \h* \n }

  token code-line { \h* \N* \n | \h* '}' \h* $$ }

  token comment-line { '#' \N* \n }

  token token-name-spec { [\w | '-' | ':' | '.' | '<' | '>' ]+ }

  token token { 'token' | 'rule' | 'regex' }

  token token-spec { '\'' <-['\'']>*  '\'' }

  token token-spec-list { <token-spec>+ % \s+ }

  token delim { \s* '|' \s* }

  regex token-simple-body { \s* [ <token-spec-list>+ % <.delim> ] \s* }

  regex token-phrase-body { \s* [ <token-name-spec>+ % <.delim> ] \s* }

  regex token-complex-body { [ <token-spec> | <token-name-spec> | '.' | '|' | '||' | ']' | '[' | '?' | '+' | '*' | \s | '\\' ]* }

  regex token-body { <token-simple-body> | <token-phrase-body> | <token-complex-body> }

  token token-definition-end { '}' \h* ';'? \h* \n }

  token leading-space { \h* }

  regex token-rule-definition {
    <leading-space>
    <token> \s* <token-name-spec> \s*
    [ '{' || <error( "cannot find \{" )> ]
    <token-body>
    [ <token-definition-end> || <error( "cannot find <token-definition-end>" )> ] }

  method error($msg) {
    my $parsed = self.target.substr(0, self.pos).trim-trailing;
    my $context = $parsed.substr($parsed.chars - 25 max 0) ~ '⏏' ~ self.target.substr($parsed.chars, 15);
    my $line-no = $parsed.lines.elems;
    die "Cannot parse code: $msg\n" ~ "at line $line-no, around " ~ $context.perl ~ "\n(error location indicated by ⏏)\n";
  }
}
