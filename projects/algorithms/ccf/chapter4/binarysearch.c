#include <stdio.h>
//二分查找，要求数组为严格递增序列

int binarysearch(int a[], int left, int right, int x)
{
    int mid;
    while (left <= right)
    {
        mid = (left + right) / 2;
        if (a[mid] == x)
            return mid;
        if (a[mid] < x)
            left = mid + 1;
        else
            right = mid - 1;
    }

    return -1;
}

int main()
{
    int n = 10;
    int a[10] = {1, 2, 4, 8, 12, 15, 18, 20, 24, 28};
    printf("%d %d", binarysearch(a, 0, n - 1, 4), binarysearch(a, 0, n - 1, 6));
    return 0;
}