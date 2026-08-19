CC = gcc
CFLAGS = -Wall

all: programa

programa: bison.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o programa bison.tab.c lex.yy.c

bison.tab.c bison.tab.h: bison.y
	bison -d bison.y

lex.yy.c: flex.l bison.tab.h
	flex flex.l

clean:
	rm -f programa bison.tab.c bison.tab.h lex.yy.c
