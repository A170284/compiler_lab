#include <stdio.h>
#include <string.h>

int label_count = 1;
int temp_count = 1;

void generate_while_tac(char *condition, char *body_statements[], int num_stmts) {
    int L1 = label_count++;
    int L2 = label_count++;
    int L3 = label_count++;

    printf("L%d: if %s goto L%d\n", L1, condition, L2);
    printf("    goto L%d\n", L3);
    printf("L%d:\n", L2);

    for(int i = 0; i < num_stmts; i++) {
        // Parse and generate TAC for each statement
        char left[20], right[20], op[10], operand1[20], operand2[20];

        if(strchr(body_statements[i], '=')) {
            sscanf(body_statements[i], "%[^=]=%s", left, right);

            // Check if it's a simple assignment or expression
            if(strchr(right, '+') || strchr(right, '-') || strchr(right, '*') || strchr(right, '/')) {
                // Expression
                if(sscanf(right, "%[^+-*/]%[+-*/]%s", operand1, op, operand2) == 3) {
                    printf("    t%d = %s %s %s\n", temp_count, operand1, op, operand2);
                    printf("    %s = t%d\n", left, temp_count);
                    temp_count++;
                }
            } else {
                printf("    %s = %s\n", left, right);
            }
        }
    }

    printf("    goto L%d\n", L1);
    printf("L%d:\n", L3);
}

int main() {
    char condition[100];
    char body[10][100];
    int num_stmts = 0;

    printf("Enter while condition (e.g., i<10): ");
    scanf("%s", condition);

    printf("Enter number of statements in body: ");
    scanf("%d", &num_stmts);

    printf("Enter statements (e.g., x=0 or i=i+1):\n");
    for(int i = 0; i < num_stmts; i++) {
        scanf("%s", body[i]);
    }

    printf("\nGenerated Three Address Code:\n");
    generate_while_tac(condition, body, num_stmts);

    return 0;
}

