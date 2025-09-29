#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    // check argument number
    if (argc != 4) {
        printf("Usage: %s a b c\n", argv[0]);
        printf("Where a, b, and c are integers\n");
        return 1;
    }
    
    // convert char to int
    int a = atoi(argv[1]);
    int b = atoi(argv[2]);
    int c = atoi(argv[3]);
    
    // check division by 0
    if (a == 0) {
        printf("Error: division by zero (a cannot be equal to 0)\n");
        return 1;
    }
    
    // (((b/a)+c)-a)
    int result = ((b / a) + c) - a;

    printf("Result: %d\n", result);
    
    return 0;
}
