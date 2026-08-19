CC = gcc
CFLAGS = -O2 -Wall

all: wc_flex wc_c

wc_flex: lex.yy.c
	$(CC) $(CFLAGS) -o wc_flex lex.yy.c

lex.yy.c: wc_flex.l
	flex wc_flex.l

wc_c: wc_c.c
	$(CC) $(CFLAGS) -o wc_c wc_c.c

clean:
	rm -f wc_flex wc_c lex.yy.c test_large.txt
