#include <stdio.h>
#include <algorithm>
struct cake
{
    double price;
    double number;
    double total;
};

cake moon[1010];

bool cmp(cake a, cake b)
{
    return a.price > b.price;
}

int main()
{
    int n;
    double need;
    scanf("%d %lf", &n, &need);

    for (int i = 0; i < n; i++)
    {
        double number;
        scanf("%lf", &number);
        moon[i].number = number;
    }

    for (int i = 0; i < n; i++)
    {
        double total;
        scanf("%lf", &total);
        moon[i].total = total;
        moon[i].price = moon[i].total / moon[i].number;
    }

    std::sort(moon, moon + n, cmp);

    double count = 0;

    for (int i = 0; i < n; i++)
    {
        if (moon[i].number > need)
        {
            count += need * moon[i].price;
            break;
        }

        count += moon[i].total;
        need = need - moon[i].number;
    }
    printf("%.2f\n", count);
}