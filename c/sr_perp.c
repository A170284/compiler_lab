#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX 100

typedef struct {
    char stack[MAX];
    char input[MAX];
    char action[MAX];
} Step;

Step steps[100];
int step_count = 0;

void record_step(char *stack, char *input, char *action) {
    strcpy(steps[step_count].stack, stack);
    strcpy(steps[step_count].input, input);
    strcpy(steps[step_count].action, action);
    step_count++;
}

int can_reduce(char *stack, int top, char *production) {
    int len = strlen(production);
    if(top < len - 1) return 0;

    for(int i = 0; i < len; i++) {
        if(stack[top - len + 1 + i] != production[i])
            return 0;
    }
    return 1;
}

void shift_reduce_parse(char *input) {
    char stack[MAX] = "$";
    int top = 0;
    int i = 0;
    char temp_stack[MAX], temp_input[MAX], action[MAX];

    // Initial state
    sprintf(temp_input, "%s", input);
    record_step("$", temp_input, "");

    while(1) {
        int reduced = 0;

        // Try reductions
        if(can_reduce(stack, top, "id")) {
            stack[top-1] = 'E';
            stack[top] = '\0';
            top--;
            sprintf(temp_stack, "%s", stack);
            sprintf(temp_input, "%s", &input[i]);
            record_step(temp_stack, temp_input, "Reduce E->id");
            reduced = 1;
        }
        else if(top >= 2 && stack[top] == 'E' && stack[top-1] == '*' && stack[top-2] == 'E') {
            stack[top-2] = 'E';
            stack[top-1] = '\0';
            top -= 2;
            sprintf(temp_stack, "%s", stack);
            sprintf(temp_input, "%s", &input[i]);
            record_step(temp_stack, temp_input, "Reduce E->E*E");
            reduced = 1;
        }
        else if(top >= 2 && stack[top] == 'E' && stack[top-1] == '+' && stack[top-2] == 'E') {
            stack[top-2] = 'E';
            stack[top-1] = '\0';
            top -= 2;
            sprintf(temp_stack, "%s", stack);
            sprintf(temp_input, "%s", &input[i]);
            record_step(temp_stack, temp_input, "Reduce E->E+E");
            reduced = 1;
        }

        if(!reduced) {
            if(input[i] == '$' && top == 1 && stack[1] == 'E') {
                record_step(stack, "$", "Accept");
                break;
            }

            if(input[i] == '$') {
                record_step(stack, "$", "Error");
                break;
            }

            // Shift
            stack[++top] = input[i];
            stack[top+1] = '\0';
            i++;

            sprintf(temp_stack, "%s", stack);
            sprintf(temp_input, "%s", &input[i]);
            sprintf(action, "Shift");
            record_step(temp_stack, temp_input, action);
        }
    }
}

int main() {
    char input[MAX];

    printf("Enter input string (end with $): ");
    scanf("%s", input);

    printf("\nGrammar: E -> E+E | E*E | id\n\n");
    shift_reduce_parse(input);

    printf("%-20s %-20s %-20s\n", "Stack", "Input", "Action");
    printf("------------------------------------------------------------\n");
    for(int i = 0; i < step_count; i++) {
        printf("%-20s %-20s %-20s\n", steps[i].stack, steps[i].input, steps[i].action);
    }

    return 0;
}

