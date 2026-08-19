#ifndef TOKENS_H
#define TOKENS_H

enum yytokentype {
    TOK_EOF = 0,
    NUMBER = 258,
    ADD = 259,
    SUB = 260,
    MUL = 261,
    DIV = 262,
    ABS = 263,
    EOL = 264,
    OP = 265,
    CP = 266
};

extern int yylval;

#endif
