%{
#include "paren.tab.h"
%}

%%
"("             { return LPAREN; }
")"             { return RPAREN; }
[ \t\n]         ; // Ignore whitespace
.               { return yytext[0]; }
%%

int yywrap() {
    return 1;
}
