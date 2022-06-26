#include <stdio.h>
int school[100000] = {0};
int main()
{
    int n;
    scanf("%d", &n);
    int schid, schsco;

    for (int i = 0; i < n; i++)
    {
        scanf("%d%d", &schid, &schsco);
        school[schid] += schsco;
    }
    int index = 1, max = -10;
    for (int i = 1; i <= n; i++)
    {
        /* code */
        if (school[i] > max)
        {
            max = school[i];
            index = i;
        }
    }
    printf("%d %d", index, max);
    return 0;
}