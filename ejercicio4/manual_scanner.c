#include <stdio.h>
#include <ctype.h>
#include "tokens.h"

FILE *manual_yyin;
static int manual_seeneof = 0;

void manual_set_input(FILE *f) {
    manual_yyin = f;
    manual_seeneof = 0;
}

int manual_yylex(void) {
    if (!manual_yyin) manual_yyin = stdin;
    if (manual_seeneof) return 0; /* EOF previo */

    while (1) {
        int c = getc(manual_yyin);
        if (isdigit(c)) {
            int i = c - '0';
            while (isdigit(c = getc(manual_yyin))) {
                i = (10 * i) + c - '0';
            }
            yylval = i;
            if (c == EOF) manual_seeneof = 1;
            else ungetc(c, manual_yyin);
            return NUMBER;
        }

        switch (c) {
            case '+': return ADD;
            case '-': return SUB;
            case '*': return MUL;
            case '|': return ABS;
            case '(': return OP;
            case ')': return CP;
            case '\n': return EOL;
            case ' ':
            case '\t':
                break; /* Ignorar espacios */
            case EOF:
                return 0;
            case '/':
                c = getc(manual_yyin);
                if (c == '/') {
                    /* Comentario: se lee hasta el salto de linea y se consume dicho \n */
                    while ((c = getc(manual_yyin)) != '\n') {
                        if (c == EOF) return 0;
                    }
                    break; /* Continua el bucle sin retornar token EOL */
                }
                if (c == EOF) manual_seeneof = 1;
                else ungetc(c, manual_yyin);
                return DIV;
            default:
                printf("[Manual] Caracter no reconocido: %c\n", c);
                break;
        }
    }
}
