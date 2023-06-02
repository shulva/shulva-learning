#include <stdio.h>

int partition(int a[], int left, int right) //分割
{
    int temp = a[left];
    while (left < right)
    {
        while (left < right && a[right] > temp)
        {
            right--;
        }
        a[left] = a[right];
        while (left < right && a[left] <= temp)
        {
            left++;
        }
        a[right] = a[left];
    }
    a[left] = temp;
    return left;
}

int randsearch(int a[], int left, int right, int k) //返回第k大的数
{
    if (left == right)
    {
        return a[left];
    }

    int pos = partition(a, left, right);
    int m = pos - left + 1;

    if (k == m)
    {
        return a[pos];
    }

    if (k < m)
    {
        return randsearch(a, left, pos - 1, k);
    }
    else
    {
        return randsearch(a, pos + 1, right, k - m);
    }
}
int main()
{
}