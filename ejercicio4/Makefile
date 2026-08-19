CC = gcc
CFLAGS = -Wall -D_POSIX_C_SOURCE=200809L

all: programa

programa: flex_scanner.c manual_scanner.c main.c
	$(CC) $(CFLAGS) -o programa main.c manual_scanner.c flex_scanner.c

flex_scanner.c: flex_scanner.l
	flex -o flex_scanner.c flex_scanner.l

clean:
	rm -f programa flex_scanner.c
