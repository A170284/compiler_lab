%{
    #include <stdio.h>
    #include <stdlib.h>
%}

DIGITS [0-9]
NUMBER {DIGIT}+
FUNCTION (sin|cos|tan|exp|log)
%%
{NUMBER} {printf("Number: %s",yytext);}
{FUNCTION} {printf("Function: %s",yytext);}
"+" {printf("Operator: %s",yytext);}
"-" {printf("Operator: %s",yytext);}
"/" {printf("Operator: %s",yytext);}
"*" {printf("Operator: %s",yytext);}
[ \t\n] ;
. {printf("Unknown Text: %s"),yytext;}
%%

int yywrap(){
    return 1;
}
int main(){
    printf("Enter)
}

