%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern void yyerror(const char *s);
%}

%union {
    char *str;
}

%token <str> WORD_TOK OTHER_TOK

%%
text:
    /* vacio */
    | text item
    ;

item:
    WORD_TOK {
        printf("%s", $1);
        free($1);
    }
    | OTHER_TOK {
        printf("%s", $1);
        free($1);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
