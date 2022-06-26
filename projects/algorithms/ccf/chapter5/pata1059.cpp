#include <stdio.h>
#include <math.h>
#define maxn 100001

int prime[maxn];
int primenum = 0;
bool isprime[maxn] = {0};

void findprime()
{
    for (int i = 2; i < maxn; i++)
    {
        if (isprime[i] == 0) //是素数
        {
            prime[primenum++] = i;
            for (int j = i + i; j < maxn; j += i) //+i来遍历i的倍数
            {
                isprime[j] = 1; //不是素数
            }
        }
    }
}

struct factor
{
    int x;
    int count;
} fac[10];

int facnum = 0;

void findfac(int n)
{
    int sqr = (int)sqrt(1.0 * n);
    for (int i = 0; i < primenum && prime[i] < sqr; i++)
    {
        if (n % prime[i] == 0)
        {
            fac[facnum].x = prime[i];
            fac[facnum].count = 0;
            while (n % prime[i] == 0)
            {
                fac[facnum].count++;
                n = n / prime[i];
            }
            facnum++;
        }

        if (n == 1)
            break;
    }

    if (n != 1)
    {
        fac[facnum].x = n;
        fac[facnum].count = 1;
        facnum++;
    }
}

int main()
{
    int n;
    scanf("%d", &n);

    findprime();
    findfac(n);

    if (n == 1)
        printf("1=1");
    else
    {
        printf("%d=", n);

        for (int i = 0; i < facnum; i++)
        {
            if (fac[i].count > 1)
            {
                printf("%d^%d", fac[i].x, fac[i].count);
            }
            else
            {
                printf("%d", fac[i].x);
            }

            if (i < facnum - 1)
            {
                printf("*");
            }
            else
            {
                printf("\n");
            }
        }
    }

    return 0;
}