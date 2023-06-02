#include <stdio.h>
int array[210];
int main()
{
    int n, x;
    scanf("%d", &n);
    for (int i = 0; i < n; i++)
    {
        scanf("%d", &array[i]);
    }
    scanf("%d", &x);

    int num = 0;

    for (int num = 0; num < n; num++)
    {
        /* code */
        if (x == array[num])
        {
            printf("%d", num);
            break;
        }
    }

    if (num == n)
    {
        printf("%d", num);
    }

    return 0;
}