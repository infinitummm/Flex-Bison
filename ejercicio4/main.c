#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokens.h"

int yylval;

/* Declaraciones de los dos escaneres */
extern int flex_lex(void);
extern void flex__switch_to_buffer(void *buf);
extern void *flex__scan_string(const char *str);
extern void flex__delete_buffer(void *buf);

extern int manual_yylex(void);
extern void manual_set_input(FILE *f);

const char *token_name(int tok) {
    switch (tok) {
        case 0: return "EOF";
        case NUMBER: return "NUMBER";
        case ADD: return "ADD (+)";
        case SUB: return "SUB (-)";
        case MUL: return "MUL (*)";
        case DIV: return "DIV (/)";
        case ABS: return "ABS (|)";
        case OP: return "OP (";
        case CP: return "CP )";
        case EOL: return "EOL (\\n)";
        default: return "DESCONOCIDO";
    }
}

void probar_escaneres(const char *titulo, const char *input_text) {
    printf("====================================================\n");
    printf("PRUEBA: %s\n", titulo);
    printf("Entrada:\n\"%s\"\n", input_text);
    printf("----------------------------------------------------\n");

    /* 1. Ejecutar scanner de Flex */
    printf("[1] Tokens generados por FLEX:\n");
    void *buf = flex__scan_string(input_text);
    int tok;
    while ((tok = flex_lex()) != 0) {
        if (tok == NUMBER) {
            printf("  -> %s = %d\n", token_name(tok), yylval);
        } else {
            printf("  -> %s\n", token_name(tok));
        }
    }
    printf("  -> EOF (0)\n");
    flex__delete_buffer(buf);

    /* 2. Ejecutar scanner MANUAL */
    printf("\n[2] Tokens generados por SCANNER MANUAL (C):\n");
    FILE *mem_file = fmemopen((void *)input_text, strlen(input_text), "r");
    manual_set_input(mem_file);
    while ((tok = manual_yylex()) != 0) {
        if (tok == NUMBER) {
            printf("  -> %s = %d\n", token_name(tok), yylval);
        } else {
            printf("  -> %s\n", token_name(tok));
        }
    }
    printf("  -> EOF (0)\n");
    fclose(mem_file);
    printf("====================================================\n\n");
}

int main(int argc, char **argv) {
    printf("COMPARATIVA DE ESCANER FLEX VS ESCANER MANUAL EN C\n\n");

    /* Caso 1: Operaciones basicas */
    probar_escaneres("Operacion simple", "12 + 34\n");

    /* Caso 2: Manejo de comentarios (DIFERENCIA CLAVE) */
    probar_escaneres("Linea con comentario y siguiente operacion", "// Comentario\n50 * 2\n");

    /* Caso 3: Division frente a comentario */
    probar_escaneres("Division simple", "100 / 25\n");

    return 0;
}
