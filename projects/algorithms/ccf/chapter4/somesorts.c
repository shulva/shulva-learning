#include <stdio.h>
void selectsort(int A[], int n) //小到大
{
    for (int i = 0; i < n; i++)
    {
        int index = i;
        for (int j = i; j < n; j++)
        {
            if (A[j] < A[index])
            {
                index = j;
            }
        }
        int temp = A[i];
        A[i] = A[index];
        A[index] = temp;
    }
}

void insertsort(int A[], int n) //小到大
{
    for (int i = 1; i < n; i++)
    {
        int temp = A[i];
        int j = i;
        while (j > 1 && temp < A[j - 1])
        {
            A[j] = A[j - 1];
            j--;
        }
        A[j] = temp;
    }
}

int main()
{

    int A[10] = {1, 4, 6, 3, 2, 8, 6, 4, 2, 1};
    insertsort(A, 10);
    for (int i = 0; i < 10; i++)
    {
        /* code */
        printf("%d", A[i]);
    }

    printf("\n");

    selectsort(A, 10);
    for (int i = 0; i < 10; i++)
    {
        /* code */
        printf("%d", A[i]);
    }
    return 0;
}