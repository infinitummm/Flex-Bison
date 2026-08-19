CC = gcc
CFLAGS = -Wall

all: programa

programa: lex.yy.c main.c
	$(CC) $(CFLAGS) -o programa main.c lex.yy.c

lex.yy.c: python_indent.l
	flex python_indent.l

clean:
	rm -f programa lex.yy.c
