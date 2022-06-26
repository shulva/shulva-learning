#include <iostream>
#include <string>
#include <vector>
using namespace std;

void fun1(string &s1) //处理斜杠
{
    s1 += ' ';
    for (int i = 0; i < s1.size(); i++)
    {
        if (s1[i] == '\\')
        {
            s1[i] = '/';
        }
    }

    int begin = 0;
    int end = 0;
    bool flag = true;

    for (int i = 0; i < s1.size(); i++)
    {
        if (s1[i] == '/' && flag && s1[i + 1] == '/')
        {
            begin = i;
            flag = false;
        }

        if (s1[i] == '/' && s1[i + 1] != '/' && (!flag))
        {
            end = i;
            flag = true;

            s1.erase(begin, end - begin);
            i = 0;
        }
    } ////

    s1.pop_back(); //加上的空格删掉
}

void fun2(string &s1) //处理单个点
{
    for (int i = 0; i < s1.size(); i++)
    {
        /* code */

        if (i == 0 && s1[i] == '.' && s1[i + 1] != '.')
        {
            s1.erase(0, 1);
            continue;
        }

        if (s1[i - 1] != '.' && s1[i] == '.' && s1[i + 1] != '.')
        {
            s1.erase(i, 1);
            continue;
        }
    }
}

void fun3(string &s1) //处理两个点
{
    for (int i = 0; i < s1.size(); i++)
    {

        if (s1[i] == '.' && i == 0)
        {
            s1 = "Value Error";
        }

        if (s1[i] == '.' && s1[i - 1] != '/')
        {
            s1 = "Value Error";
        }

        if (s1[i] == '.' && s1[i - 1] == '/')
        {
            for (int j = i - 2; j >= 0; j--)
            {
                if (s1[j] == '/')
                {
                    s1.erase(j, i + 2 - j);

                    i = 0;
                    break;
                }
                else if (j == 0)
                {
                    s1.erase(0, i + 2 - j);
                    i = 0;
                    break;
                }
            }
        }
    }
}

void fun4(string &s1, string &s2) //最终处理
{
    if (s2[0] == '\\' || s2[0] == '/')
    {
    }
    else if (s1[0] == '/')
    {
        s1.erase(0, 1);
    }

    if (s1 == "/")
    {
    }
    else if (s1[s1.size() - 1] == '/')
    {
        s1.pop_back();
    }

    if (s1.size() == 0 && (s2[0] == '/' || s2[0] == '\\'))
    {
        s1 += '/';
    }
}

int main()
{
    string s1;
    vector<string> v1;

    while (cin >> s1)
    {
        v1.push_back(s1);
    }

    for (int i = 0; i < v1.size(); i++)
    {
        string s1 = v1[i];
        string s2 = s1;

        fun2(s1);
        fun1(s1);
        fun3(s1);

        fun4(s1, s2);
        cout << s1 << endl;
    }

    return 0;
}
//./jisuanke\\./suantou/../bin/
//../\./\.\/.\/