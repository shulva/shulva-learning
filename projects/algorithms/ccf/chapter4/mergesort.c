#include <stdio.h>
#define maxn 100

void merge(int a[], int ll, int lr, int rl, int rr)
{
    int i = ll;
    int j = rl;
    int temp[maxn];
    int index = 0;
    while (i <= lr && j <= rr)
    {
        if (a[i] <= a[j])
        {
            temp[index++] = a[i++];
        }
        else
        {
            temp[index++] = a[j++];
        }
    }

    while (i <= lr)
    {
        temp[index++] = a[i++];
    }
    while (j <= rr)
    {
        temp[index++] = a[j++];
    }

    for (int i = 0; i < index; i++)
    {
        a[i + ll] = temp[i];
    }
}

void mergesort1(int a[], int left, int right) //递归实现
{
    if (left < right)
    {
        int mid = (left + right) / 2;
        mergesort1(a, left, mid);
        mergesort1(a, mid + 1, right);
        merge(a, left, mid, mid + 1, right);
    }
}

int main()
{
    return 0;
}