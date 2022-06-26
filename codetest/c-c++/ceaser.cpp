#include <iostream>
using namespace std;

//解密
string decrypt(int len, string str, int key)
{
    string str1 = str;

    for (int i = 0; i < len; i++)
    {
        str1[i] = ((str1[i] - 'a') - key) % 26 + 'a';
    }

    return str1;
}

//加密
string encrypt(int len, string str, int key)
{
    string str1 = str;

    for (int i = 0; i < len; i++)
    {
        str1[i] = ((str1[i] - 'a') + key) % 26 + 'a';
    }

    return str1;
}

int main()
{

    char flag = 'y';

    cout << "encrypt/decrypt(y/n)?" << endl;
    cin >> flag;

    while (flag != 'y' && flag != 'n')
    {
        cout << "pls input again" << endl;
        cin >> flag;
    }

    string text;
    int key = 0;

    cout << "pls input text" << endl;
    cin >> text;

    cout << "pls input key" << endl;
    cin >> key;

    int len = text.length();

    if (flag == 'y')
    {
        cout << "after encrypt:" << encrypt(len, text, key) << endl;
    }
    else
    {
        cout << "after decrypt:" << decrypt(len, text, key) << endl;
    }

    return 0;
}
