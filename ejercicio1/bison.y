%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex(void);
extern void yyerror(const char *s);

int chars = 0;
int words = 0;
int lines = 0;
%}

%token WORD NEWLINE CHAR_TOK

%%
input:
    /* vacio */
    | input item
    ;

item:
    WORD       { words++; }
    | NEWLINE  { lines++; chars++; }
    | CHAR_TOK { chars++; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char **argv) {
    yyparse();
    printf("%8d%8d%8d\n", lines, words, chars);
    return 0;
}
