%{
#include <stdio.h>
#include <stdlib.h>

#define TOK_EOF 0
#define TOK_INDENT 258
#define TOK_DEDENT 259
#define TOK_NEWLINE 260
#define TOK_IDENTIFIER 261
#define TOK_KEYWORD 262
#define TOK_COLON 263
#define TOK_OTHER 264

/* Pila de indentacion para emular la estructura de bloques de Python */
#define MAX_DEPTH 100
static int indent_stack[MAX_DEPTH] = {0};
static int stack_top = 0;
static int pending_dedents = 0;

int push_indent(int cols) {
    if (stack_top < MAX_DEPTH - 1) {
        indent_stack[++stack_top] = cols;
        return 1;
    }
    return 0;
}

int pop_indent() {
    if (stack_top > 0) {
        return indent_stack[--stack_top];
    }
    return 0;
}

int current_indent() {
    return indent_stack[stack_top];
}
%}

%option noyywrap
%x INDENT_STATE

%%

    /* Si hay DEDENTs pendientes por emitir, emitirlos antes de continuar */
%{
    if (pending_dedents > 0) {
        pending_dedents--;
        return TOK_DEDENT;
    }
%}

^[ \t]*\n           { /* Lineas vacias o de solo espacios se ignoran */ }
^[ \t]*#.*          { /* Lineas de comentarios se ignoran */ }

^[ \t]+             {
                        /* Al inicio de linea, calcular el nivel de indentacion */
                        int cols = yyleng;
                        if (cols > current_indent()) {
                            push_indent(cols);
                            return TOK_INDENT;
                        } else if (cols < current_indent()) {
                            while (stack_top > 0 && cols < current_indent()) {
                                pop_indent();
                                pending_dedents++;
                            }
                            if (cols != current_indent()) {
                                printf("Error: Indentacion inconsistente en columna %d\n", cols);
                            }
                            if (pending_dedents > 0) {
                                pending_dedents--;
                                return TOK_DEDENT;
                            }
                        }
                    }

^[^ \t\n]           {
                        /* Linea que comienza en columna 0 (sin indentacion) */
                        yyless(0); /* Devolver el caracter para procesarlo como token normal */
                        if (current_indent() > 0) {
                            while (stack_top > 0) {
                                pop_indent();
                                pending_dedents++;
                            }
                            if (pending_dedents > 0) {
                                pending_dedents--;
                                return TOK_DEDENT;
                            }
                        }
                        BEGIN(INITIAL);
                    }

"def"|"if"|"else"|"elif"|"while"|"for"|"return"   { return TOK_KEYWORD; }
[a-zA-Z_][a-zA-Z0-9_]*                          { return TOK_IDENTIFIER; }
":"                                             { return TOK_COLON; }
\n                                              { return TOK_NEWLINE; }
[ \t]                                           { /* Ignorar espacios intermedios */ }
#.*                                             { /* Comentarios de fin de linea */ }
.                                               { return TOK_OTHER; }

<<EOF>>                                         {
                                                    if (stack_top > 0) {
                                                        pop_indent();
                                                        return TOK_DEDENT;
                                                    }
                                                    return TOK_EOF;
                                                }

%%
