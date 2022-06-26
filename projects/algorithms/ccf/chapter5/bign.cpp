#include <stdio.h>
#include <string.h>

struct bign
{
    int d[1000];
    int len;
    bign()
    {
        memset(d, 0, sizeof(d));
        len = 0;
    }
};

bign n_to_bign(char str[])
{
    bign a;
    a.len = strlen(str);
    for (int i = 0; i < a.len; i++)
    {
        a.d[i] = str[a.len - 1 - i] - '0';
    }
    return a;
}

int comparebign(bign a, bign b)
{
    if (a.len > b.len)
    {
        return 1; //a大
    }
    else if (a.len < b.len)
    {
        return -1;
    }
    else
    {
        for (int i = a.len - 1; i >= 0; i--)
        {
            if (a.d[i] > b.d[i])
                return 1;
            else if (a.d[i] < b.d[i])
                return -1;
        }
    }
    return 0; //完全相等
}

bign add(bign a, bign b)
{
    bign c;
    int carry;
    for (int i = 0; i < a.len || i < b.len; i++)
    {
        if (a.d[i] + b.d[i] >= 10)
        {
            int temp = a.d[i] + b.d[i] + carry;
            c.d[c.len++] = temp % 10;
            carry = temp / 10;
        }
    }
    if (carry != 0)
    {
        c.d[c.len++] = carry;
    }
    return c;
}

bign sub(bign a, bign b)
{
    bign c;
    for (int i = 0; i < a.len || i < b.len; i++)
    {
        if (a.d[i] < b.d[i])
        {
            a.d[i + 1] -= 1;
            a.d[i] += 10;
        }
        c.d[c.len++] = a.d[i] - b.d[i];
    }
    while (c.len - 1 >= 1 && c.d[c.len - 1] == 0) //去除多余的0，例如00112，去掉两个0
    {
        c.len--;
    }
    return c;
}

bign mul(bign a, int b)
{
    bign c;
    int carry;
    for (int i = 0; i < a.len; i++)
    {
        int temp = a.d[i] * b + carry;
        c.d[c.len++] = temp % 10;
        carry = temp / 10;
    }
    while (carry != 0)
    {
        c.d[c.len++] = carry % 10;
        carry /= 10;
    }
    return c;
}

bign divide(bign a, int b, int &r) //r为余数
{
    bign c;
    c.len = a.len;
    for (int i = a.len - 1; i > 0; i--)
    {
        r = r * 10 + a.d[i];
        if (r < b)
        {
            c.d[i] = 0;
        }
        else
        {
            c.d[i] = r / b;
            r = r % b;
        }
        }

    while (c.len - 1 >= 1 && c.d[c.len - 1] == 0) //去除多余的0，例如00112，去掉两个0
    {
        c.len--;
    }
    return c;
}

int main()
{
    return 0;
}