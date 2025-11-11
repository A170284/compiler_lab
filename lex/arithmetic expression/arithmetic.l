%{
#include "y.tab.h"
#include <stdlib.h>
%}

%%
[0-9]+          { yylval = atoi(yytext); return NUMBER; }
[ \t\n]         ; // Ignore whitespace
.               { return yytext[0]; }
%%

int yywrap() {
    return 1;
}
