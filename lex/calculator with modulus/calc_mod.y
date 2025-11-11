%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(const char *s);
%}

/* tokens */
%token NUMBER

/* precedence and associativity */
%left '+' '-'
%left '*' '/' '%'
%right UMINUS   /* unary minus has higher precedence, right-associative */

%%

input:
      /* empty */
    | input line
    ;

line:
      '\n'
    | expr '\n'     { printf("Result: %d\n", $1); }
    ;

expr:
      NUMBER              { $$ = $1; }
    | expr '+' expr       { $$ = $1 + $3; }
    | expr '-' expr       { $$ = $1 - $3; }
    | expr '*' expr       { $$ = $1 * $3; }
    | expr '/' expr       {
                              if ($3 == 0) {
                                  yyerror("Division by zero");
                                  $$ = 0;
                              } else {
                                  $$ = $1 / $3;
                              }
                          }
    | expr '%' expr       {
                              if ($3 == 0) {
                                  yyerror("Modulus by zero");
                                  $$ = 0;
                              } else {
                                  $$ = $1 % $3;
                              }
                          }
    | '-' expr %prec UMINUS   { $$ = -$2; }  /* unary minus rule */
    | '(' expr ')'        { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    printf("Calculator (supports +, -, *, /, %%, and unary minus)\n");
    printf("Enter expressions:\n");
    yyparse();
    return 0;
}
