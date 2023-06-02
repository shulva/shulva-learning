#include <stdio.h>
#include <string.h>
_Bool judge(char str[])
{
    int len = strlen(str);
    for (int i = 0; i < len / 2; i++)
    {
        if (str[i] != str[len - i - 1])
        {
            return 0;
        }
    }
    return 1;
}
int main()
{
    char str[255];
    while (gets(str))
    {
        if (judge(str))
        {
            printf("%s", "YES");
        }
        else
        {
            printf("%s", "NO");
        }
    }
    return 0;
}