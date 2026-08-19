%{
#include "tokens.h"
#include <stdio.h>
#include <stdlib.h>
%}

%option noyywrap
%option prefix="flex_"

%%

"+"     { return ADD; }
"-"     { return SUB; }
"*"     { return MUL; }
"/"     { return DIV; }
"|"     { return ABS; }
"("     { return OP; }
")"     { return CP; }
[0-9]+  { yylval = atoi(yytext); return NUMBER; }
\n      { return EOL; }
"//".*  { /* Flex ignora el comentario pero NO el \n */ }
[ \t]   { /* Ignora espacios y tabs */ }
.       { printf("[Flex] Caracter no reconocido: %c\n", *yytext); }

%%
