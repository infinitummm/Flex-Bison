%{
#include "bison.tab.h"
extern int chars;
%}

%option noyywrap

%%
[a-zA-Z]+ { chars += yyleng; return WORD; }
\n        { return NEWLINE; }
.         { return CHAR_TOK; }
%%
