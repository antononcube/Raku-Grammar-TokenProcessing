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
  regex token-spec-element { <token-spec> | <token-name-spec> | <token-renamed-spec> }
  regex repeat-spec-delim { .* }
  token quantifier { '+' | '*' }
  regex repeat-spec-for-lists { <quantifier> \h* '%' \h* <repeat-spec-delim> }
  regex repeat-spec { <repeat-spec-for-lists> || '?' | '*' | '+' }
  regex repetition { <element> \h* <repeat-spec>? }
  regex concatenation { \s* [ <repetition>+ % \s+ ] \s* }
  regex alternation { \s* [ <concatenation>+ % <.delim> ] \s* }
  regex group { '[' \s* <alternation> \s* ']' }
  regex element { <token-spec-element> || <group> }

  regex token-comprehensive-body { <alternation>+ % \h+ }
  #--------------------------------------------------------------------

  regex token-rule-definition {
    <leading-space>
    <token> \s* <token-name-spec> \s*
    [ '{' || <error( "cannot find \{" )> ]
    \s* <token-comprehensive-body> \s*
    [ <token-definition-end> || <error( "cannot find <token-definition-end>" )> ] }

}
