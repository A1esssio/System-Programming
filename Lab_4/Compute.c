#include <stdio.h>

// 4
long long calculate_sum(int n) {
    long long sum = 0;
    for (int k = 1; k <= n; ++k) {
        int sign = (k % 2 == 0) ? 1 : -1;
        long long term = (long long)sign * k * (k + 4) * (k + 8);
        sum += term;
    }
    return sum;
}

// 6
int count_numbers(int n) {
    int count = 0;
    for (int i = 1; i <= n; ++i) {
        if (i % 3 != 0 && i % 7 != 0 && i % 5 == 0) {
            ++count;
        }
    }
    return count;
}

// 7
int reverse_number(int n) {
    int reversed = 0;
    int isNegative = 0;
    
    if (n < 0) {
        isNegative = 1;
        n = -n;
    }
    
    while (n > 0) {
        reversed = reversed * 10 + (n % 10);
        n /= 10;
    }
    
    if (isNegative) {
        reversed = -reversed;
    }
    
    return reversed;
}

int main() {
    int choice, n;
    
    printf("\033[2J");
    printf("\033[H");
    printf("Select a task:\n");
    printf("1 - calculate the sum \n");
    printf("2 - count the numbers (not divisible by 3 and 7, but divisible by 5)\n");
    printf("3 - reverse the digits of a number\n");
    printf("Your choice: ");
    scanf("%d", &choice);

    switch(choice) {
        case 1:
            printf("\033[2J");
            printf("\033[H");
            printf("Enter n: ");
            scanf("%d", &n);
            if (n < 1) {
                printf("Error: n must be a positive number\n");
                return 1;
            }
            long long result1 = calculate_sum(n);
            printf("Sum for n = %d: %lld\n", n, result1);
            break;

        case 2:
            printf("\033[2J");
            printf("\033[H");
            printf("Enter n: ");
            scanf("%d", &n);
            if (n < 1) {
                printf("Error: n must be a positive number\n");
                return 1;
            }
            int result2 = count_numbers(n);
            printf("The number of numbers from 1 to %d is %d\n", n, result2);
            printf("\n");
            break;
            
        case 3:
            printf("\033[2J");
            printf("\033[H");
            printf("Enter a number: ");
            scanf("%d", &n);
            int result3 = reverse_number(n);
            printf("The number with the reverse order of digits is %d\n", result3);
            break;
            
        default:
            printf("Error: invalid selection\n");
            return 1;
    }
    
    return 0;
}
