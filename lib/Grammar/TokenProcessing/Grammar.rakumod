use v6;

unit module Grammar::TokenProcessing::Grammar;

##===========================================================
## Grammar
##===========================================================

grammar Grammar::TokenProcessing::Grammar  {

  regex TOP { [ <token-rule-definition> | <empty-line> | <comment-line> | <code-line> ]+ }

  regex token-rule-definition-list { <token-rule-definition>+ }

  token empty-line { \h* \n }

  token code-line { \h* \N* \n | \h* '}' \h* $$ }

  token comment-line { '#' \N* \n }

  token alnumd { <alpha> | '-' }

  token var-name { <.alpha> <.alnumd>* }

  token sym-spec { 'sym<' <var-name> '>' }

  token sigil-char { '%' | '*'  | '$' | '\\' | '@' }

  token token-name-spec { [\w | '.' | '<'  ] [\w | '-' | ':' | '.' | '<' | '>' ]* }

  token white-space-regex { '\\h' [ '*' | '+' ] }

  token token-renamed-spec { '<' \h* <.var-name> \h* '=' \h* \.? <var-name> \h* '>' }

  # This more comprehensive regex works, but it is not needed (for now.)
  #regex token-variable { [ ':my' | ':our' ] \s+ <var-name> \s+ \S+ \s* ['=' \s* \S+ \s* ]? ';' }
  regex token-variable { [ ':my' | ':our' ] \s+ <-[;]>+ ';' }

  regex token-variables-list { \s* <token-variable>+ % \s* }

  regex token-code-block { '{' <-[{}]>* '}' | '<' . '{' <-[{}]>* '}>' }

  token token { 'token' | 'rule' | 'regex' }

  token token-spec { '\'' <-[']>*  '\'' }

  token token-spec-list { <token-spec>+ % \s+ }

  token delim { \s* '|' | '||' \s* }

  regex token-quoted-list-body { \s* '<' \s+ [ [\S+]+ % \s* ] \s+ '>' \s* }

  regex token-simple-body { \s* [ <token-spec-list>+ % <.delim> ] \s* }

  regex token-phrase-body { \s* [ <token-name-spec>+ % <.delim> ] \s* }

  regex token-complex-body { [ <token-spec> | <token-name-spec> | '.' | '|' | '||' | ']' | '[' | '?' | '+' | '*' | \s | '\\' ]* }

  regex token-body { <token-quoted-list-body> | <token-simple-body> | <token-phrase-body> | <token-complex-body> }

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
