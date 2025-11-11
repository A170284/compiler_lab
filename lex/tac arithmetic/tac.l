%{
#include "tac.tab.h"
#include <string.h>
%}

%%

[ \t\r]+               ;            /* skip spaces and tabs */
[0-9]+(\.[0-9]+)?      { yylval.s = strdup(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.s = strdup(yytext); return IDENT; }

"\n"                   { return '\n'; }
"+"                    { return '+'; }
"-"                    { return '-'; }
"*"                    { return '*'; }
"/"                    { return '/'; }
"("                    { return '('; }
")"                    { return ')'; }

.                      { return yytext[0]; } /* catch-all (shouldn't be needed) */

%%

int yywrap(void) { return 1; }
