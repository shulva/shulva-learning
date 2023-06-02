#include <stdio.h>
#include <math.h>
#define maxn 10
int hashfunc(char str[], int len) //若字符串中还有数字，则增加进制52->62(多了10个数字)
{
    int count = 0;
    for (int i = 0; i < len; i++)
    {
        if (str[i] >= 'A' && str[i] <= 'Z')
        {
            count = count * 52 + (str[i] - 'A');
        }
        else if (str[i] >= 'a' && str[i] <= 'z')
        {
            count = count * 52 + (str[i] + 26 - 'a'); //lower > upper 26
        }
    }
    return count;
}
//全排列

int n, m;
int countqueen = 0;
int per[maxn];
int hashtable[maxn] = {0};

void permutation(int index)
{
    if (index == n)
    {
        for (int i = 0; i < n; i++)
        {
            printf("%d ", per[i]);
        }
        printf("\n");
        return;
    }

    for (int i = 0; i < n; i++)
    {
        if (hashtable[i] == 0)
        {
            per[index] = i;
            hashtable[i] = 1;
            permutation(index + 1);
            hashtable[i] = 0;
        }
    }
}

void queen(int index) //n皇后
{

    if (index == m)
    {
        _Bool flag = 1;
        for (int i = 0; i < m; i++)
        {
            for (int j = i + 1; j < m; j++)
            {
                if (abs(i - j) == abs(per[i] - per[j]))
                {
                    flag = 0;
                }
            }
        }
        if (flag == 1)
        {
            countqueen++;
        }

        return;
    }

    for (int i = 0; i < m; i++)
    {
        if (hashtable[i] == 0)
        {
            per[index] = i;
            hashtable[i] = 1;
            queen(index + 1);
            hashtable[i] = 0;
        }
    }
}

void queen2(int index) //n皇后回溯剪枝
{
    if (index == m)
    {
        countqueen++;
        return;
    }

    for (int i = 0; i < m; i++)
    {

        if (hashtable[i] == 0)
        {
            _Bool flag = 1;
            for (int j = 0; j < index; j++)
            {
                if (abs(index - j) == abs(i - per[j]))
                {
                    flag = 0; //不等到最终return时检查，而是在index列的遍历过程(i的遍历)中将不符合的序列直接去掉
                    break;
                }
            }

            if (flag)
            {
                per[index] = i;
                hashtable[i] = 1;
                queen2(index + 1);
                hashtable[i] = 0;
            }
        }
    }
}

int main()
{
    scanf("%d", &n);
    permutation(0);

    scanf("%d", &m);
    queen(0);

    printf("%d", countqueen);
    printf("\n");

    countqueen = 0;
    queen2(0);
    printf("%d", countqueen);

    return 0;
}