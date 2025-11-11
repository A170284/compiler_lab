%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

char *newtemp(void);
%}

%union {
  char *s;
}

%token <s> IDENT NUM
%type <s> expr term factor

%left '+' '-'
%left '*' '/'
%right UMINUS

%%

input:
    /* empty */
  | input line
  ;

line:
    '\n'
  | expr '\n'   { /* print final result location and free it */ 
                  printf("Result in %s\n", $1);
                  free($1);
                }
  ;

expr:
    expr '+' term { char *t = newtemp();
                     printf("%s = %s + %s\n", t, $1, $3);
                     free($1); free($3);
                     $$ = t;
                   }
  | expr '-' term { char *t = newtemp();
                     printf("%s = %s - %s\n", t, $1, $3);
                     free($1); free($3);
                     $$ = t;
                   }
  | term          { $$ = $1; }
  ;

term:
    term '*' factor { char *t = newtemp();
                       printf("%s = %s * %s\n", t, $1, $3);
                       free($1); free($3);
                       $$ = t;
                     }
  | term '/' factor { char *t = newtemp();
                       printf("%s = %s / %s\n", t, $1, $3);
                       free($1); free($3);
                       $$ = t;
                     }
  | factor          { $$ = $1; }
  ;

factor:
    '(' expr ')'        { $$ = $2; }        /* just pass upward (owned) */
  | '-' factor  %prec UMINUS {                    /* unary minus: make temp */
                       char *t = newtemp();
                       printf("%s = 0 - %s\n", t, $2);
                       free($2);
                       $$ = t;
                     }
  | IDENT               { $$ = $1; }  /* token already strdup'ed in lexer */
  | NUM                 { $$ = $1; }  /* token already strdup'ed in lexer */
  ;

%%

/* ---- helper C functions ---- */

static int temp_counter = 1;

char *newtemp(void) {
    char buf[32];
    snprintf(buf, sizeof(buf), "t%d", temp_counter++);
    return strdup(buf);
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
