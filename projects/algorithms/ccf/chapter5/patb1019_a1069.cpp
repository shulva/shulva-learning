#include <stdio.h>
#include <algorithm>
void n_to_array(int n, int num[])
{
    for (int i = 0; i < 4; i++)
    {
        num[i] = n % 10;
        n = n / 10;
    }
}

int array_to_n(int num[])
{
    int sum = 0;
    for (int i = 0; i < 4; i++)
    {
        sum = sum * 10 + num[i];
    }
    return sum;
}

bool cmp(int a, int b)
{
    return a > b;
}

int main()
{
    int n;
    int min, max;
    int num[5];
    scanf("%d", &n);

    while (1)
    {
        n_to_array(n, num);
        std::sort(num, num + 4);
        min = array_to_n(num);
        std::sort(num, num + 4, cmp);
        max = array_to_n(num);

        n = max - min;
        printf("%04d - %04d = %04d\n", max, min, n); //%04d会自动补零. eg:123->0123
        if (n == 0 || n == 6174)
            break;
    }

    return 0;
}
