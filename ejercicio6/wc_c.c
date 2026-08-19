#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#define BUFFER_SIZE 16384 /* 16KB de buffer, similar al de Flex */

int main(int argc, char **argv) {
    FILE *f = stdin;
    if (argc > 1) {
        f = fopen(argv[1], "r");
        if (!f) {
            perror(argv[1]);
            return 1;
        }
    }

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

    if (f != stdin) {
        fclose(f);
    }

    printf("%8d%8d%8d\n", lines, words, chars);
    return 0;
}
