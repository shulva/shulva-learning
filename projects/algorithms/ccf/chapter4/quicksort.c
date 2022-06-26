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

void quicksort(int a[], int left, int right)
{
    if (left < right)
    {
        int position = partition(a, left, right);
        quicksort(a, left, position - 1);
        quicksort(a, position + 1, right);
    }
}

int main()
{
    int a[] = {2, 6, 8, 3, 8, 9};
    quicksort(a, 0, 5);
    for (int i = 0; i < 6; i++)
    {

        printf("%d ", a[i]);
    }

    return 0;
}