use v6.d;

##===========================================================
## Comprehensive Grammar
##===========================================================

use Grammar::TokenProcessing::Grammar;

grammar Grammar::TokenProcessing::ComprehensiveGrammar
        is Grammar::TokenProcessing::Grammar {

  #--------------------------------------------------------------------
  # Comprehensive body definitions
  #--------------------------------------------------------------------
  regex token-spec-element { <token-spec> | <token-name-spec> | <token-renamed-spec> | <white-space-regex> | <backslashed-char-class> }
  regex backslashed-char-class { '\w' | '\W' | '\d' | '\D' | '\s' | '\S' | '\t' | '\T' | '\n' | '\N' | '\h' | '\H' | '\v' | '\V' };
  regex repeat-spec-delim { <-[{}]>* }
  token quantifier { '+' | '*' }
  token repeat-range { $<count>=(\d+) | $<from>=(\d+) [ '..' | '...' ] $<to>=(\d+ | '*') }
  regex repeat-spec-for-lists { <quantifier> \h* '%' \h* <repeat-spec-delim> }
  regex repeat-spec { <repeat-spec-for-lists> || '**' \h* <repeat-range> || '?' | '*' | '+' }
  regex repetition { <element> \h* <repeat-spec>? }
  regex concatenation { \s* [ <repetition>+ % \s+ ] \s* }
  regex alternation { \s* [ <concatenation>+ % <.delim> ] | <token-quoted-list-body> \s* }
  regex group { '[' \s* <alternation> \s* ']' }
  regex element { <token-spec-element> || <group> }

  regex token-comprehensive-body { \s* <alternation>+ % \s+ }
  #--------------------------------------------------------------------

  regex token-rule-definition {
    <leading-space>
    <token> \s* <token-name-spec> \s*
    '{'
    [ \s* <token-variables-list> ]?
    [ \s* <token-code-block> ]?
    \s* <token-comprehensive-body> \s*
    [ <token-code-block> \s*]?
    <token-definition-end>
  }

#  regex token-rule-definition {
#    <leading-space>
#    <token> \s* <token-name-spec> \s*
#    '{'
#    \s* <token-comprehensive-body> \s*
#    <token-definition-end>
#  }

}
