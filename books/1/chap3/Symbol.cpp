/*
 * g++ symbol.cpp -o symbol
 */

#include <stdio.h>
namespace myname
{
    int var = 42;
}

extern "C" double _ZN6myname3varE;

int main()
{
    printf("%d\n", _ZN6myname3varE);
}