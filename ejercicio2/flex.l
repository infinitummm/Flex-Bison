%{
#include "bison.tab.h"
#include <stdio.h>
#include <stdlib.h>
%}

%option noyywrap

%%

"+"                 { return ADD; }
"-"                 { return SUB; }
"*"                 { return MUL; }
"/"                 { return DIV; }
"|"                 { return ABS; }
"("                 { return OP; }
")"                 { return CP; }
0[xX][0-9a-fA-F]+   { yylval = (int)strtol(yytext, NULL, 16); return NUMBER; }
[0-9]+              { yylval = (int)strtol(yytext, NULL, 10); return NUMBER; }
\n                  { return EOL; }
"//".*              { /* Ignorar comentarios */ }
[ \t]               { /* Ignorar espacios y tabuladores */ }
.                   { printf("Caracter no reconocido: %c\n", *yytext); }

%%
