%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
%}

%token NUMBER
%token ADD SUB MUL DIV ABS
%token OP CP
%token EOL

%%

calclist: /* vacio */
    | calclist exp EOL { printf("= %d (0x%X)\n", $2, $2); }
    | calclist EOL     { /* Linea vacia / comentario */ }
    ;

exp: factor
    | exp ADD factor { $$ = $1 + $3; }
    | exp SUB factor { $$ = $1 - $3; }
    ;

factor: term
    | factor MUL term { $$ = $1 * $3; }
    | factor DIV term {
        if ($3 == 0) {
            yyerror("division por cero");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
    ;

term: NUMBER
    | ABS term   { $$ = $2 >= 0 ? $2 : -$2; }
    | OP exp CP  { $$ = $2; }
    ;

%%

int main(int argc, char **argv) {
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "error: %s\n", s);
}
