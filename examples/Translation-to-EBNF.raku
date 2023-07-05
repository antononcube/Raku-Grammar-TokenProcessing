#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Grammar::TokenProcessing;
use Grammar::TokenProcessing::ComprehensiveGrammar;
use Chemistry::Stoichiometry::Grammar;
use Grammar::TokenProcessing::Actions::EBNF;

#say Grammar::TokenProcessing::Grammar.parse('<table-noun>?', rule => 'repetition');
#say Grammar::TokenProcessing::Grammar.parse(' <rows> | <records>', rule => 'alternation');
#say Grammar::TokenProcessing::Grammar.parse('[ <rows> | <records> ]', rule => 'group');
#say Grammar::TokenProcessing::ComprehensiveGrammar.parse('<table-noun>? [ <rows> | <records> ]', rule => 'token-comprehensive-body');

#my $focusGrammar = Chemistry::Stoichiometry::Grammar;

#$focusGrammar = grammar-source-code($focusGrammar);


my $focusGrammar = q:to/END/;
grammar LLoveParser {
    rule TOP  { <workflow-command> }
    rule workflow-command  { 'I' <love> <lang> }
    token love { '♥' | 'love' }
    token lang { 'Raku' | 'Perl' | 'Rust' | 'Go' | 'Python' | 'Ruby' }
}
END



say '=' x 120;

#say Grammar::TokenProcessing::ComprehensiveGrammar.parse($focusGrammar);

say '=' x 120;

#my Grammar::TokenProcessing::Actions::EBNF $actions .= new;
#say Grammar::TokenProcessing::ComprehensiveGrammar.parse($focusGrammar, :$actions).made;

say to-ebnf-grammar($focusGrammar);