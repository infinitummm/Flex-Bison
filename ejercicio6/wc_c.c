#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>

#define BUFFER_SIZE 16384 /* 16KB de buffer */

int main(int argc, char **argv) {
    FILE *f = stdin;
    if (argc > 1) {
        f = fopen(argv[1], "r");
        if (!f) {
            perror(argv[1]);
            return 1;
        }
    }

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    int chars = 0;
    int words = 0;
    int lines = 0;
    int in_word = 0;

    char buffer[BUFFER_SIZE];
    size_t bytes_read;

    while ((bytes_read = fread(buffer, 1, BUFFER_SIZE, f)) > 0) {
        for (size_t i = 0; i < bytes_read; i++) {
            unsigned char c = buffer[i];
            chars++;
            if (c == '\n') {
                lines++;
            }
            if (isalpha(c)) {
                if (!in_word) {
                    in_word = 1;
                    words++;
                }
            } else {
                in_word = 0;
            }
        }
    }

    clock_gettime(CLOCK_MONOTONIC, &end);

    if (f != stdin) {
        fclose(f);
    }

    double tiempo = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;

    printf("Lineas contadas: %d\n", lines);
    printf("Palabras contadas: %d\n", words);
    printf("Caracteres contados: %d\n", chars);
    printf("Tiempo de ejecucion: %.6f segundos\n", tiempo);

    return 0;
}
