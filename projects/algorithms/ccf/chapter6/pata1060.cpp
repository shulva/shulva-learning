#include <stdio.h>
#include <iostream>
#include <string>
#include <algorithm>
using namespace std;

//有几个答案过不了，但我书上所述样例都过了。。搞不懂
int n; //精度

string deal(string s, int &e)
{
    while (s[0] == '0' && s.length() > 0)
    {
        s.erase(s.begin());
    }

    int index = 0;

    if (s[0] == '.') //小数点 0.xxx
    {
        s.erase(s.begin());

        while (s[0] == '0' && s.length() > 0)
        {
            s.erase(s.begin());
            e--;
        }
    }
    else //小数点前有非0数字
    {

        while (s[index] != '.' && index < s.length())
        {
            index++;
            e++;
        }

        if (index < s.length()) //有小数点
        {
            s.erase(s.begin() + index); //删掉小数点
        }
    }

    if (s.length() == 0)
    {
        e = 0;
    }

    index = 0;
    int num = 0;
    string res;

    while (num < n)
    {
        if (index < s.length())
        {
            res += s[index++];
        }
        else
        {
            res += '0';
        }
        num++;
    }

    return res;
}

int main()
{
    int e1 = 0;
    int e2 = 0;

    string s1, s2;

    cin >> n >> s1 >> s2;

    string s3 = deal(s1, e1);
    string s4 = deal(s2, e2);

    if (s3 == s4 && e1 == e2)
    {
        cout << "YES 0." << s3 << "*10^" << e1 << endl;
    }
    else
    {
        cout << "No 0." << s3 << "*10^" << e1 << " 0." << s4 << "*10^" << e2 << endl;
    }

    return 0;
}