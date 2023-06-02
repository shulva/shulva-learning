#include <stdio.h>
int dayofyear[13][2] = {
    {0, 0},
    {31, 31},
    {28, 29}, //闰年
    {31, 31},
    {30, 30},
    {31, 31},
    {30, 30},
    {31, 31},
    {31, 31},
    {30, 30},
    {31, 31},
    {30, 30},
    {31, 31}};
_Bool isrun(int year)
{
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
}
int main()
{
    int y1, y2, m1, m2, d1, d2;
    int time1, time2;
    while (scanf("%d%d", &time1, &time2) != EOF)
    {
        if (time1 > time2)
        {
            int temp = time1;
            time1 = time2;
            time2 = temp;
        }
    } //time1<=time2
    y1 = time1 / 10000;
    m1 = (time1 % 10000) / 100;
    d1 = time1 % 100;

    y2 = time2 / 10000;
    m2 = (time2 % 10000) / 100;
    d2 = time2 % 100;

    int ans = 1;

    while (y1 < y2 || m1 < m2 || d1 < d2)
    {
        d1++;
        ans++;
        if (d1 == dayofyear[m1][isrun(y1)])
        {
            d1 = 1;
            m1++;
        }
        if (m1 == 13)
        {
            y1++;
            m1 = 1;
        }
    }

    printf("%d", ans);

    return 0;
}