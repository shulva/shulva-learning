#include <stdio.h>
#include <algorithm>
#include <string.h>
using namespace std;
struct Stu
{
    char id[15];
    int score;
    int localid;
    int localrank;
};

Stu stu[30010];

bool cmp(Stu a, Stu b)
{
    if (a.score != b.score)
        return a.score > b.score;
    else
        return strcmp(a.id, b.id) < 0;
}
int main()
{
    int n, k, count = 0;
    scanf("%d", &n);
    for (int j = 0; j < n; j++)
    {
        scanf("%d", &k);
        for (int i = 0; i < k; i++)
        {
            scanf("%s %d", stu[count].id, &stu[count].score);
            stu[count].localid = j + 1;
            count++;
        }
        sort(stu + count - k, stu + count, cmp);
        int localrank = 1;

        for (int i = 0; i < k; i++)
        {
            if (i > 0 && stu[count - k + i].score != stu[count - k + i - 1].score)
                localrank = i + 1;
            stu[count - k + i].localrank = localrank;
        }
    }
    sort(stu + 0, stu + count, cmp);
    int rank = 1;

    printf("%d", count);
    printf("\n");
    for (int i = 0; i < count; i++)
    {
        if (i > 0 && stu[i].score != stu[i - 1].score)
            rank = i + 1;
        printf("%s %d %d %d\n", stu[i].id, rank, stu[i].localid, stu[i].localrank);
    }

    return 0;
}