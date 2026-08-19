%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
%}

%token NUMBER
%token ADD SUB MUL DIV ABS AND
%token OP CP
%token EOL

%%

calclist: /* vacio */
    | calclist exp EOL { printf("= %d (0x%X)\n", $2, $2); }
    | calclist EOL     { /* Linea vacia */ }
    ;

/* exp maneja suma (+), resta (-) y OR bitwise (|) a nivel binario */
exp: factor
    | exp ADD factor { $$ = $1 + $3; }
    | exp SUB factor { $$ = $1 - $3; }
    | exp ABS factor { $$ = $1 | $3; /* OR binario bit a bit */ }
    ;

/* factor maneja multiplicacion (*) y division (/) */
factor: bit_and
    | factor MUL bit_and { $$ = $1 * $3; }
    | factor DIV bit_and {
        if ($3 == 0) {
            yyerror("division por cero");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
    ;

/* bit_and maneja AND bitwise (&) */
bit_and: term
    | bit_and AND term { $$ = $1 & $3; /* AND binario bit a bit */ }
    ;

/* term maneja numeros, ABS unario (|), menos unario (-) y parentesis */
term: NUMBER
    | ABS term   { $$ = $2 >= 0 ? $2 : -$2; /* ABS unario */ }
    | SUB term   { $$ = -$2;               /* Menos unario */ }
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
