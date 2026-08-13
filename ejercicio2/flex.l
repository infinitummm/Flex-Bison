%{
#include <string.h>
#include "bison.tab.h"
%}

%option noyywrap

%%
"colour"       { yylval.str = strdup("color"); return WORD_TOK; }
"flavour"      { yylval.str = strdup("flavor"); return WORD_TOK; }
"clever"       { yylval.str = strdup("smart"); return WORD_TOK; }
"smart"        { yylval.str = strdup("elegant"); return WORD_TOK; }
"conservative" { yylval.str = strdup("liberal"); return WORD_TOK; }
[a-zA-Z]+      { yylval.str = strdup(yytext); return WORD_TOK; }
.|\n           { yylval.str = strdup(yytext); return OTHER_TOK; }
%%
