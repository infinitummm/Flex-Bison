%option noyywrap
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

int chars = 0;
int words = 0;
int lines = 0;
%}

%%

[a-zA-Z]+   { words++; chars += yyleng; }
\n          { chars++; lines++; }
.           { chars++; }

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        if (!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return 1;
        }
    }

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    yylex();

    clock_gettime(CLOCK_MONOTONIC, &end);

    if (yyin && yyin != stdin) {
        fclose(yyin);
    }

    double tiempo = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;

    printf("Lineas contadas: %d\n", lines);
    printf("Palabras contadas: %d\n", words);
    printf("Caracteres contados: %d\n", chars);
    printf("Tiempo de ejecucion: %.6f segundos\n", tiempo);

    return 0;
}
