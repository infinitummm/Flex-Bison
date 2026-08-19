%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
%}

/* Declaracion de tokens */
%token NUMBER
%token ADD SUB MUL DIV ABS
%token OP CP
%token EOL

%%

/* 
 * calclist admite:
 * 1) Lineas vacias o con solo comentarios (calclist EOL) -> Solucion al Ejercicio 1
 * 2) Lineas con expresiones aritmeticas (calclist exp EOL)
 */
calclist: /* vacio */
    | calclist exp EOL { printf("= %d\n", $2); }
    | calclist EOL     { /* Linea vacia o solo con comentario: no hace nada */ }
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
