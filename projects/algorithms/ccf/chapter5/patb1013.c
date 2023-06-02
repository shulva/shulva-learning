#include <stdio.h>
#define maxn 100000

int prime[maxn];
int primenum = 0;
int isprime[maxn] = {0};

void findprime(int n)
{
    for (int i = 2; i < maxn; i++)
    {
        if (isprime[i] == 0) //是素数
        {
            prime[primenum++] = i;

            if (primenum >= n)
                break;

            for (int j = i + i; j < maxn; j += i) //+i来遍历i的倍数
            {
                isprime[j] = 1; //不是素数
            }
        }
    }
}

int main()
{
    int m, n;
    int count = 0;
    scanf("%d %d", &m, &n);
    findprime(n);

    for (int i = m; i <= n; i++)
    {
        printf("%d", prime[i - 1]);
        count++;

        if (count % 10 == 0 || i == n)
        {
            printf("\n");
        }
        else
        {
            printf(" ");
        }
    }

    return 0;
}