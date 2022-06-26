#include <stdio.h>
int main()
{
    int n;
    char c;
    scanf("%d %c", &n, &c);

    int row = n;
    int col = n % 2 ? (n / 2 + 1) : n / 2;

    for (int i = 0; i < row; i++)
    {
        /* code */
        printf("%c", c);
    }
    printf("\n");
    for (int i = 0; i < col - 2; i++)
    {
        printf("%c", c);
        for (int i = 0; i < row - 2; i++)
        {
            printf(" ");
        }
        printf("%c", c);
        printf("\n");
    }

    for (int i = 0; i < row; i++)
    {
        /* code */
        printf("%c", c);
    }

    return 0;
}