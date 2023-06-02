#include <stdio.h>

int gcd(int a, int b)
{
    if (b == 0)
        return a;
    else
        return gcd(b, a % b);
}

int lcm(int a, int b)
{
    int d = gcd(a, b);
    return a / d * b; //先除d防止溢出
}

int main()
{
    return 0;
}