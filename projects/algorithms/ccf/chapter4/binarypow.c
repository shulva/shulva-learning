#include <stdio.h>
typedef long long LL;

LL binarypow1(LL a, LL b, LL m) //递归写法
{
    if (b == 0)
    {
        return 1;
    }
    if (b % 2 == 1) //幂次数为奇数
    {
        return a * binarypow1(a, b - 1, m) % m;
    }
    else
    {
        LL mul = binarypow1(a, b / 2, m);
        return mul * mul % m;
    }
}

LL binarypow2(LL a, LL b, LL m) //迭代写法
{
    LL count = 1;
    while (b > 0)
    {
        if (b & 1 == 1)
        {
            count = count * a % m;
        }
        a = a * a;
        b >>= 1;
    }
    return count;
}

int main()
{

    printf("%d\n", binarypow1(2, 4, 3));
    printf("%d", binarypow2(2, 4, 3));

    return 0;
}