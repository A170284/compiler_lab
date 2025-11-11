%{
#include <stdio.h>
#include <string.h>
%}

%%

"</"[a-z]+[0-9]*">"     { 
    printf("Tag Close: %s\n", yytext); 
}

"<"[a-z]+[0-9]*         { 
    printf("Tag Open: %s", yytext); 
}

[a-z]+=\"[^\"]*\"       { 
    printf("Attribute: %s\n", yytext); 
}

">"                     { 
    printf(">\n"); 
}

[a-zA-Z0-9 ]+           { 
    if (strlen(yytext) > 0 && yytext[0] != ' ')
        printf("Text: %s\n", yytext); 
}

[ \t\n]                 { /* ignore whitespace */ }

.                       { /* ignore other chars */ }

%% 

int yywrap() {
    return 1;
}

int main() {
    printf("Enter HTML:\n");
    yylex();
    return 0;
}
