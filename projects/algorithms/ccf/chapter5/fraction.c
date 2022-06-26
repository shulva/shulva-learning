#include <stdio.h>
struct fraction
{
    int up;
    int down;
};

typedef struct fraction fraction;

int gcd(int a, int b)
{
    if (b == 0)
        return a;
    else
        return gcd(b, a % b);
}
/*
    1.若分母down为负数,那么令分子up和分母down都变为相反数
    2.如果分子up为0，则令分母down为1
    3.同时以gcd约分分子分母
*/

fraction reduction(fraction result)
{
    if (result.down < 0)
    {
        result.down = -result.down;
        result.up = -result.up;
    }

    if (result.up == 0)
    {
        result.down = 1;
    }
    else
    {
        int d = gcd(abs(result.down), abs(result.up));
        result.down /= d;
        result.up /= d;
    }
    return result;
}

fraction add(fraction a, fraction b)
{
    fraction result;
    result.up = a.up * b.down + a.down * b.up;
    result.down = a.down * b.down;
    return reduction(result);
}

fraction sub(fraction a, fraction b)
{
    fraction result;
    result.up = a.up * b.down - a.down * b.up;
    result.down = a.down * b.down;
    return reduction(result);
}

fraction mul(fraction a, fraction b)
{
    fraction result;
    result.up = a.up * b.up;
    result.down = a.down * b.down;
    return reduction(result);
}

fraction divide(fraction a, fraction b)
{
    fraction result;
    result.up = a.up * b.down;
    result.down = a.down * b.up; //b.up不为0，最好处理
    return reduction(result);
}

int main()
{
    return 0;
}