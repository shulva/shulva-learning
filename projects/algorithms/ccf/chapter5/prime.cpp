#include <stdio.h>
#include <math.h>
#define maxn 100

int prime[maxn];
int primenum;
bool isprime[maxn] = {0};

bool isPrime(int n)
{
    if (n <= 1)
        return 0;

    int sqr = (int)sqrt(1.0 * n);
    for (int i = 0; i < sqr; i++)
    {
        if (n % i == 0)
            return false;
    }
    return true;
}

void findprime()
{
    for (int i = 2; i < maxn; i++)
    {
        if (isprime[i] == true) //是素数
        {
            prime[primenum++] = i;
            for (int j = i + i; j < maxn; j += i) //+i来遍历i的倍数
            {
                isprime[j] = false; //不是素数
            }
        }
    }
}

int main()
{
    return 0;
}