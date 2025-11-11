#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

typedef struct {
    char op[10];
    char arg1[10];
    char arg2[10];
    char result[10];
} Quadruple;

typedef struct {
    int index;
    char op[10];
    char arg1[10];
    char arg2[10];
} Triple;

Quadruple quads[50];
Triple triples[50];
int quad_count = 0;
int triple_count = 0;
int temp_count = 1;

char* generate_tac(char *expr, int *pos);

char* parse_factor(char *expr, int *pos) {
    char *result = malloc(10);

    while(expr[*pos] == ' ') (*pos)++;

    if(expr[*pos] == '(') {
        (*pos)++;
        char *sub_result = generate_tac(expr, pos);
        (*pos)++; // skip ')'
        return sub_result;
    }

    // Parse identifier
    int i = 0;
    while(isalnum(expr[*pos])) {
        result[i++] = expr[*pos];
        (*pos)++;
    }
    result[i] = '\0';
    return result;
}

char* parse_term(char *expr, int *pos) {
    char *left = parse_factor(expr, pos);

    while(expr[*pos] == ' ') (*pos)++;

    while(expr[*pos] == '*' || expr[*pos] == '/') {
        char op = expr[*pos];
        (*pos)++;
        char *right = parse_factor(expr, pos);

        char *temp = malloc(10);
        sprintf(temp, "t%d", temp_count++);

        // Add to quadruple
        strcpy(quads[quad_count].op, op == '*' ? "*" : "/");
        strcpy(quads[quad_count].arg1, left);
        strcpy(quads[quad_count].arg2, right);
        strcpy(quads[quad_count].result, temp);
        quad_count++;

        // Add to triple
        triples[triple_count].index = triple_count;
        strcpy(triples[triple_count].op, op == '*' ? "*" : "/");
        strcpy(triples[triple_count].arg1, left);
        strcpy(triples[triple_count].arg2, right);
        triple_count++;

        left = temp;
        while(expr[*pos] == ' ') (*pos)++;
    }

    return left;
}

char* generate_tac(char *expr, int *pos) {
    char *left = parse_term(expr, pos);

    while(expr[*pos] == ' ') (*pos)++;

    while(expr[*pos] == '+' || expr[*pos] == '-') {
        char op = expr[*pos];
        (*pos)++;
        char *right = parse_term(expr, pos);

        char *temp = malloc(10);
        sprintf(temp, "t%d", temp_count++);

        // Add to quadruple
        strcpy(quads[quad_count].op, op == '+' ? "+" : "-");
        strcpy(quads[quad_count].arg1, left);
        strcpy(quads[quad_count].arg2, right);
        strcpy(quads[quad_count].result, temp);
        quad_count++;

        // Add to triple
        triples[triple_count].index = triple_count;
        strcpy(triples[triple_count].op, op == '+' ? "+" : "-");
        strcpy(triples[triple_count].arg1, left);
        strcpy(triples[triple_count].arg2, right);
        triple_count++;

        left = temp;
        while(expr[*pos] == ' ') (*pos)++;
    }

    return left;
}

int main() {
    char expr[200];

    printf("Enter arithmetic expression: ");
    fgets(expr, 200, stdin);
    expr[strcspn(expr, "\n")] = 0;

    int pos = 0;
    generate_tac(expr, &pos);

    printf("\n=== THREE ADDRESS CODE ===\n");
    for(int i = 0; i < quad_count; i++) {
        printf("%s = %s %s %s\n", quads[i].result, quads[i].arg1, quads[i].op, quads[i].arg2);
    }

    printf("\n=== QUADRUPLE ===\n");
    printf("%-5s | %-10s | %-10s | %-10s\n", "Op", "Arg1", "Arg2", "Result");
    printf("------------------------------------------------\n");
    for(int i = 0; i < quad_count; i++) {
        printf("%-5s | %-10s | %-10s | %-10s\n",
               quads[i].op, quads[i].arg1, quads[i].arg2, quads[i].result);
    }

    printf("\n=== TRIPLE ===\n");
    printf("%-7s | %-5s | %-10s | %-10s\n", "Index", "Op", "Arg1", "Arg2");
    printf("------------------------------------------------\n");
    for(int i = 0; i < triple_count; i++) {
        printf("(%d)%-5s | %-5s | %-10s | %-10s\n",
               triples[i].index, "", triples[i].op, triples[i].arg1, triples[i].arg2);
    }

    return 0;
}

