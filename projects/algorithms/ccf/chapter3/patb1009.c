#include <stdio.h>
#include <string.h>
int main()
{
    char str[90];
    gets(str);
    int num = 0;
    int height = 0;
    char ans[90][90];

    int index = strlen(str);
    for (int i = 0; i < index; i++)
    {
        if (str[i] != ' ')
        {
            ans[num][height++] = str[i];
        }
        else
        {
            num++;
            height = 0;
        }
    }

    for (int i = num; i >= 0; i--)
    {
        printf("%s", ans[i]);
        if (i > 0)
            printf(" ");
    }

    return 0;
}