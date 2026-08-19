#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TOK_EOF 0
#define TOK_INDENT 258
#define TOK_DEDENT 259
#define TOK_NEWLINE 260
#define TOK_IDENTIFIER 261
#define TOK_KEYWORD 262
#define TOK_COLON 263
#define TOK_OTHER 264

extern int yylex(void);
extern char *yytext;
extern void *yy_scan_string(const char *);
extern void yy_delete_buffer(void *);

const char *tok_to_str(int tok) {
    switch (tok) {
        case TOK_EOF: return "EOF";
        case TOK_INDENT: return "INDENT (Inicio de bloque)";
        case TOK_DEDENT: return "DEDENT (Fin de bloque)";
        case TOK_NEWLINE: return "NEWLINE";
        case TOK_IDENTIFIER: return "IDENTIFIER";
        case TOK_KEYWORD: return "KEYWORD";
        case TOK_COLON: return "COLON (:)";
        case TOK_OTHER: return "OTHER";
        default: return "UNKNOWN";
    }
}

int main(int argc, char **argv) {
    const char *codigo_python = 
        "def calcular():\n"
        "    if activo:\n"
        "        procesar()\n"
        "    else:\n"
        "        detener()\n"
        "finalizar()\n";

    printf("==============================================================\n");
    printf("DEMOSTRACION: LIMITACIONES DE FLEX CON LENGUAJES INDENTADOS\n");
    printf("==============================================================\n");
    printf("Codigo fuente a analizar (Python):\n\n%s\n", codigo_python);
    printf("--------------------------------------------------------------\n");
    printf("Tokens generados (con pila de indentacion manual requerida):\n");
    printf("--------------------------------------------------------------\n");

    void *buf = yy_scan_string(codigo_python);
    int tok;
    while ((tok = yylex()) != TOK_EOF) {
        if (tok == TOK_IDENTIFIER || tok == TOK_KEYWORD || tok == TOK_OTHER) {
            printf("  [%s] -> '%s'\n", tok_to_str(tok), yytext);
        } else {
            printf("  [%s]\n", tok_to_str(tok));
        }
    }
    printf("  [EOF]\n");
    yy_delete_buffer(buf);

    printf("==============================================================\n");
    return 0;
}
