#include <stdio.h>
int main()
{
    int a, b, d;
    scanf("%d %d %d", &a, &b, &d);
    int ans[32];
    int temp = a + b;
    int num = 0;
    do
    {
        ans[num++] = temp % d;
        temp = temp / d;
    } while (temp != 0);
    for (int i = num - 1; i >= 0; i--)
    {
        /* code */
        printf("%d", ans[i]);
    }

    return 0;
}