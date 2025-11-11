%{
    #include "test.tab.h"
    #include <stdlib.h>
%}

%%
[0-9]+ {yyval=atoi(yytext);return NUMBER;}
[ \t\n] ;
. {return yytext[0];}
%%
int yywrap(){
    return 1;
}

