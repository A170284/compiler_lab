%{
#include <stdio.h>
#include <stdlib.h>
int yylex();
void yyerror(const char *s);

int valid = 1;
%}

%token LPAREN RPAREN

%%
input:
    /* empty */         { printf("Balanced\n"); }
    | input expr
    ;

expr:
    LPAREN expr RPAREN expr
    | LPAREN RPAREN expr
    | /* empty */
    ;

%%

void yyerror(const char *s) {
    valid = 0;
}

int main() {
    printf("Enter expression with parentheses: ");
    if(yyparse() == 0 && valid) {
        printf("Parentheses are balanced!\n");
    } else {
        printf("Parentheses are NOT balanced!\n");
    }
    return 0;
}
