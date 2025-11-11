#include <stdio.h>
#include <string.h>

char prec_table[6][6] = {
    /*    +    *    id   (    )    $  */
    /*+*/ {'>',  '<', '<', '<', '>', '>'},
    /***/ {'>',  '>', '<', '<', '>', '>'},
    /*id*/{'>',  '>', ' ', ' ', '>', '>'},
    /*(*/ {'<',  '<', '<', '<', '=', ' '},
    /*)*/ {'>',  '>', ' ', ' ', '>', '>'},
    /*$*/ {'<',  '<', '<', '<', ' ', '='}
};

int get_index(char c) {
    switch(c) {
        case '+': return 0;
        case '*': return 1;
        case 'i': return 2;
        case '(': return 3;
        case ')': return 4;
        case '$': return 5;
    }
    return -1;
}

char get_precedence(char a, char b) {
    return prec_table[get_index(a)][get_index(b)];
}

void op_precedence_parse(char *input) {
    char stack[100] = "$";
    int top = 0;
    int i = 0;

    printf("%-30s %-20s %-20s\n", "Stack", "Input", "Action");
    printf("------------------------------------------------------------------------\n");

    while(1) {
        char stack_top = stack[top];
        char input_char = (input[i] == 'i' && input[i+1] == 'd') ? 'i' : input[i];

        printf("%-30s %-20s ", stack, &input[i]);

        char rel = get_precedence(stack_top, input_char);

        if(rel == '<' || rel == '=') {
            printf("Shift\n");
            stack[++top] = input[i];
            stack[top+1] = '\0';
            i++;
            if(input[i-1] == 'i') {
                i++; // skip 'd' in 'id'
            }
        }
        else if(rel == '>') {
            printf("Reduce\n");
            // Find handle and reduce
            while(top > 0 && get_precedence(stack[top-1], stack[top]) != '<') {
                top--;
            }
            stack[top] = 'E';
            stack[top+1] = '\0';
        }
        else if(stack_top == '$' && input_char == '$') {
            printf("Accept\n");
            break;
        }
        else {
            printf("Error\n");
            break;
        }
    }
}

int main() {
    char input[100];

    printf("Operator Precedence Table:\n");
    printf("      +    *    id   (    )    $\n");
    printf("+     >    <    <    <    >    >\n");
    printf("*     >    >    <    <    >    >\n");
    printf("id    >    >         >    >    >\n");
    printf("(     <    <    <    <    =     \n");
    printf(")     >    >         >    >    >\n");
    printf("$     <    <    <    <         =\n\n");

    printf("Enter input string (end with $): ");
    scanf("%s", input);

    op_precedence_parse(input);

    return 0;
}

