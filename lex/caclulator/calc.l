%{
#include <stdio.h>
#include <string.h>
%}

DIGIT    [0-9]
NUMBER   {DIGIT}+
LETTER   [a-zA-Z]
FUNCTION (sin|cos|tan|log|exp|sqrt)

%%
{NUMBER}        { printf("Number: %s\n", yytext); }
{FUNCTION}      { printf("Function: %s\n", yytext); }
"+"             { printf("Operator: +\n"); }
"-"             { printf("Operator: -\n"); }
"*"             { printf("Operator: *\n"); }
"/"             { printf("Operator: /\n"); }
"("             { printf("Left Parenthesis: (\n"); }
")"             { printf("Right Parenthesis: )\n"); }
[ \t\n]         ; // Ignore whitespace
.               { printf("Unknown character: %s\n", yytext); }
%%

int yywrap() {
    return 1;
}

int main() {
    printf("Enter calculator expression: ");
    yylex();
    return 0;
}

