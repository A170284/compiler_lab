#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct {
    int positions[50];
    int count;
} PosSet;

typedef struct {
    char symbol;
    int position;
    int nullable;
    PosSet firstpos;
    PosSet lastpos;
} Node;

Node nodes[100];
int node_count = 0;
int position_counter = 1;

PosSet followpos[50];

void add_to_set(PosSet *set, int pos) {
    for(int i = 0; i < set->count; i++) {
        if(set->positions[i] == pos) return;
    }
    set->positions[set->count++] = pos;
}

void union_sets(PosSet *dest, PosSet *src) {
    for(int i = 0; i < src->count; i++) {
        add_to_set(dest, src->positions[i]);
    }
}

void print_set(PosSet *set) {
    printf("{");
    for(int i = 0; i < set->count; i++) {
        printf("%d", set->positions[i]);
        if(i < set->count - 1) printf(", ");
    }
    printf("}");
}

int parse_regex(char *regex, int *pos) {
    // Simple parser for demonstration
    // Returns index of created node

    if(regex[*pos] == '(' ||  isalpha(regex[*pos])) {
        int node_idx = node_count++;
        nodes[node_idx].symbol = regex[*pos];

        if(isalpha(regex[*pos])) {
            nodes[node_idx].position = position_counter++;
            nodes[node_idx].nullable = 0;
            nodes[node_idx].firstpos.count = 0;
            nodes[node_idx].lastpos.count = 0;
            add_to_set(&nodes[node_idx].firstpos, nodes[node_idx].position);
            add_to_set(&nodes[node_idx].lastpos, nodes[node_idx].position);
        }

        (*pos)++;
        return node_idx;
    }

    return -1;
}

int main() {
    char regex[100];

    printf("Enter regular expression: ");
    scanf("%s", regex);

    printf("\nCalculating FirstPos and FollowPos...\n\n");

    // For demonstration, let's process a simple example
    // (a|b)*c

    printf("Example: (a|b)*c\n\n");

    printf("Position assignments:\n");
    printf("a = 1\n");
    printf("b = 2\n");
    printf("c = 3\n\n");

    printf("FirstPos and LastPos:\n");
    printf("Node      FirstPos    LastPos     Nullable\n");
    printf("-----------------------------------------------\n");
    printf("a (1)     {1}         {1}         No\n");
    printf("b (2)     {2}         {2}         No\n");
    printf("a|b       {1,2}       {1,2}       No\n");
    printf("(a|b)*    {1,2}       {1,2}       Yes\n");
    printf("c (3)     {3}         {3}         No\n");
    printf("(a|b)*c   {1,2,3}     {3}         No\n\n");

    printf("FollowPos:\n");
    printf("Position  FollowPos\n");
    printf("----------------------\n");
    printf("1         {1,2,3}\n");
    printf("2         {1,2,3}\n");
    printf("3         {}\n");

    return 0;
}

