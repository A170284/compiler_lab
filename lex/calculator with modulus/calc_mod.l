%{
#include "y.tab.h"
#include <stdlib.h>
%}

%%

[0-9]+          { yylval = atoi(yytext); return NUMBER; }
[ \t]           ;   /* ignore spaces and tabs */
\n              { return '\n'; }
.               { return yytext[0]; }   /* return operators and parentheses */

%%

int yywrap(void) { return 1; }
