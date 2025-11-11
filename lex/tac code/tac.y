%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

char *newtemp(void);
char *newlabel(void);

/* utility to join strings conveniently */
char *strjoin(const char *a, const char *b) {
    size_t la = a ? strlen(a) : 0;
    size_t lb = b ? strlen(b) : 0;
    char *r = malloc(la + lb + 1);
    if (!r) exit(1);
    if (a) memcpy(r, a, la);
    if (b) memcpy(r + la, b, lb);
    r[la+lb] = '\0';
    return r;
}

%}

%union {
  char *s;    /* place (result name or label) */
}

%token <s> IDENT NUM
%type <s> stmt stmt_list expr term factor lvalue opt_expr

%left '+' '-'
%left '*' '/'
%nonassoc '<' '>' LE GE EQ NE
%right UMINUS

%%

program:
    stmt_list
  ;

stmt_list:
    /* empty */         { /* nothing */ }
  | stmt_list stmt
  ;

stmt:
    ';'                 { /* empty statement */ }
  | lvalue '=' expr ';' {
        /* assignment */
        printf("%s = %s\n", $1, $3);
        free($1); free($3);
    }
  | expr ';'            { /* bare expression (function call style) */
        free($1);
    }
  | "return" opt_expr ';' {
        if ($2) {
            printf("return %s\n", $2);
            free($2);
        } else {
            printf("return\n");
        }
    }
  | "if" '(' expr ')' stmt  {
        char *ltrue = newlabel();
        char *lend  = newlabel();
        /* expr is boolean temp */
        printf("if %s goto %s\n", $3, ltrue);
        printf("goto %s\n", lend);
        printf("%s:\n", ltrue);
        printf("%s", ""); /* placeholder */
        /* print stmt (it already printed) */
        printf("%s:\n", lend);
        free($3);
        free(ltrue); free(lend);
    }
  | "if" '(' expr ')' stmt "else" stmt {
        char *ltrue = newlabel();
        char *lfalse = newlabel();
        char *lend = newlabel();
        printf("if %s goto %s\n", $3, ltrue);
        printf("goto %s\n", lfalse);
        printf("%s:\n", ltrue);
        /* then stmt printed */
        printf("goto %s\n", lend);
        printf("%s:\n", lfalse);
        /* else stmt printed */
        printf("%s:\n", lend);
        free($3);
        free(ltrue); free(lfalse); free(lend);
    }
  | "while" '(' expr ')' stmt {
        char *lbegin = newlabel();
        char *lbody  = newlabel();
        char *lend   = newlabel();
        printf("%s:\n", lbegin);
        printf("if %s goto %s\n", $3, lbody);
        printf("goto %s\n", lend);
        printf("%s:\n", lbody);
        /* body already printed */
        printf("goto %s\n", lbegin);
        printf("%s:\n", lend);
        free($3);
        free(lbegin); free(lbody); free(lend);
    }
  | "for" '(' opt_expr ';' opt_expr ';' opt_expr ')' stmt {
        /* $3 = init (or NULL), $5 = cond (or NULL), $7 = incr (or NULL) */
        char *lbegin = newlabel();
        char *lbody  = newlabel();
        char *lend   = newlabel();

        if ($3) { printf("%s\n", $3); free($3); }

        printf("%s:\n", lbegin);

        if ($5) {
            printf("if %s goto %s\n", $5, lbody);
            printf("goto %s\n", lend);
            free($5);
        } else {
            /* empty condition = true */
            printf("goto %s\n", lbody);
        }

        printf("%s:\n", lbody);
        /* body printed */
        if ($7) {
            printf("%s\n", $7); free($7);
        }
        printf("goto %s\n", lbegin);
        printf("%s:\n", lend);

        free(lbegin); free(lbody); free(lend);
    }
  | '{' stmt_list '}' {
        /* block: nothing to print here; contained stmts already printed */
    }
  ;

opt_expr:
    /* empty */ { $$ = NULL; }
  | expr { $$ = $1; }
  ;

lvalue:
    IDENT                       { $$ = $1; }       /* var */
  | IDENT '[' expr ']' {
        /* represent as a[index] for TAC: leave as string "a[t2]" */
        char *b1 = strjoin($1, "[");
        char *b2 = strjoin(b1, $3);
        free(b1); free($1); free($3);
        char *b3 = strjoin(b2, "]");
        free(b2);
        $$ = b3;
    }
  ;

expr:
    expr '+' term {
        char *t = newtemp();
        printf("%s = %s + %s\n", t, $1, $3);
        free($1); free($3);
        $$ = t;
    }
  | expr '-' term {
        char *t = newtemp();
        printf("%s = %s - %s\n", t, $1, $3);
        free($1); free($3);
        $$ = t;
    }
  | term { $$ = $1; }
  ;

term:
    term '*' factor {
        char *t = newtemp();
        printf("%s = %s * %s\n", t, $1, $3);
        free($1); free($3);
        $$ = t;
    }
  | term '/' factor {
        char *t = newtemp();
        printf("%s = %s / %s\n", t, $1, $3);
        free($1); free($3);
        $$ = t;
    }
  | factor { $$ = $1; }
  ;

factor:
    '(' expr ')' { $$ = $2; }
  | '-' factor %prec UMINUS {
        char *t = newtemp();
        printf("%s = 0 - %s\n", t, $2);
        free($2);
        $$ = t;
    }
  | IDENT {
        $$ = $1; /* variable name */
    }
  | IDENT '[' expr ']' {
        /* read array element: produce t = a[idx] */
        char *temp = newtemp();
        char *b1 = strjoin($1, "[");
        char *b2 = strjoin(b1, $3);
        free(b1);
        char *b3 = strjoin(b2, "]");
        free(b2);
        printf("%s = %s\n", temp, b3); /* temp = a[idx] (rvalue) */
        free(b3); free($1); free($3);
        $$ = temp;
    }
  | NUM {
        $$ = $1;
    }
  /* relational expressions as factors: treat relational via separate rule */
  | expr '<' expr {
        char *t = newtemp();
        printf("%s = %s < %s\n", t, $1, $3);
        free($1); free($3);
        $$ = t;
    }
  | expr '>' expr {
        char *t = newtemp();
        printf("%s = %s > %s\n", t, $1, $3);
        free($1); free($3);
        $$ = t;
    }
  | expr LE expr {
        char *t = newtemp();
        printf("%s = %s <= %s\n", t, $1, $3);
        free($1); free($3);
        $$ = t;
    }
  | expr GE expr {
        char *t = newtemp();
        printf("%s = %s >= %s\n", t, $1, $3);
        free($1); free($3);
        $$ = t;
    }
  | expr EQ expr {
        char *t = newtemp();
        printf("%s = %s == %s\n", t, $1, $3);
        free($1); free($3);
        $$ = t;
    }
  | expr NE expr {
        char *t = newtemp();
        printf("%s = %s != %s\n", t, $1, $3);
        free($1); free($3);
        $$ = t;
    }
  ;

%%

/* helper functions */

static int temp_counter = 1;
static int label_counter = 1;

char *newtemp(void) {
    char buf[32];
    snprintf(buf, sizeof(buf), "t%d", temp_counter++);
    return strdup(buf);
}

char *newlabel(void) {
    char buf[32];
    snprintf(buf, sizeof(buf), "L%d", label_counter++);
    return strdup(buf);
}

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}
