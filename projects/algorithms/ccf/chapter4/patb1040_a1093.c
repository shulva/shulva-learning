#include <stdio.h>
#include <string.h>
#define maxn 100010
#define mod 1000000007
int leftp[maxn] = {0};
char string[maxn];
int main()
{
    gets(string);
    int len = strlen(string);
    for (int i = 0; i < len; i++)
    {
        if (i > 0)
        {
            leftp[i] = leftp[i - 1];
        }
        if (string[i] == 'P')
        {
            leftp[i] = leftp[i - 1] + 1;
        }
    }
    int ans = 0;
    int rightnum = 0;

    for (int i = len - 1; i > 0; i--)
    {
        if (string[i] == 'T')
        {
            rightnum++;
        }
        else if (string[i] == 'A')
        {
            ans = (ans + rightnum * leftp[i]) % mod;
        }
    }

    printf("%d", ans);

    return 0;
}