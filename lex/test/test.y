%{
    #include <stdio.h>
    #include <stdlib.h>
    int yylex();
    void yyerror(const char *s);
%}

%token NUMBER
%left '+' '-'
%left '*' '/' '%'
%right UMINUS

%%
input:
    | input line
    ;
line:'\n'
    | expr '\n' {printf("Result: %d\n",$1);}
    ;
expr: NUMBER
    | expr 
%%