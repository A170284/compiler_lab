%{
#include "tac.tab.h"
#include <string.h>
%}

/* skip spaces */
WS      [ \t\r]+
ID      [A-Za-z_][A-Za-z0-9_]*
NUM     [0-9]+(\.[0-9]+)?

%%

{WS}            ;
"return"        { return (int)strdup("return"); } /* we treat as token string in parser */
"if"            { return (int)strdup("if"); }
"else"          { return (int)strdup("else"); }
"while"         { return (int)strdup("while"); }
"for"           { return (int)strdup("for"); }

"=="            { return EQ; }
"!="            { return NE; }
"<="            { return LE; }
">="            { return GE; }

"("             { return '('; }
")"             { return ')'; }
"["             { return '['; }
"]"             { return ']'; }
"{"             { return '{'; }
"}"             { return '}'; }
";"             { return ';'; }
","             { return ','; }

"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"<"             { return '<'; }
">"             { return '>'; }
"="             { return '='; }

{NUM}           { yylval.s = strdup(yytext); return NUM; }
{ID}            { yylval.s = strdup(yytext); return IDENT; }

\n              { /* treat newline as whitespace (no token) */ ; }

.               { /* unknown char - return it to let parser handle or error */ return yytext[0]; }

%%

int yywrap(void) { return 1; }
