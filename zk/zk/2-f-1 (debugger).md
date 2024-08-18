# debugger

> [!NOTE] gdb
> [GDB debugging tutorial for beginners](https://linuxconfig.org/gdb-debugging-tutorial-for-beginners)
> ```
> Program terminated with signal SIGFPE, Arithmetic exception.
> #0  0x000055c87f76013b in actual_calc (a=13, b=0) at testgdb.c:3
> 3         c=a/b;
> ```
> **SIGFPE**标明了终止信号
> **#0**则是gdb中**frame**的概念，可以简要理解成步骤/时间帧
> ```
> (gdb) bt
>  #0  0x000055c87f76013b in actual_calc (a=13, b=0) at testgdb.c:3
>  #1  0x000055c87f760171 in calc () at testgdb.c:12
>  #2  0x000055c87f76018a in main () at testgdb.c:17
> 
> (gdb) f 1
>  #1  0x000055c87f760171 in calc () at testgdb.c:12
>  12        actual_calc(a, b);
> (gdb) p a
>  $1 = 13
> ```
> 你可以通过**bt (backtrace)**来追踪函数栈
> 可以通过 f 1跳到frame 1处（这很重要，因为f=2时a是未被定义的），再用p a来打印a的值
> > [!warning]
> > - Floating point Exception后面没有(core dumped)说明core dumped文件没有生成。
> > - GDB does _not_ check if there is a source code revision match! It is thus of paramount importance that you use the exact same source code revision as the one from which your binary was compiled.

> [!NOTE] pdb
> ###### Basic Command
> 1. `l(ist)` - 展示当前行附近的 11 行，或者是继续之前的展示。
> 2. `s(tep)` - 执行当前行，停在第一个可能停下的地方。
> 1. `n(ext)` - 继续执行程序到当前函数的下一行或者是直到它返回结果。
> 2. `b(reak)` - 设置程序断点 (取决于提供的参数)。
> 3. `r(eturn)` - 继续执行直到当前函数返回结果。
> 3. `c(ontinue)` - 执行到程序断点处。
> ###### Tutorial
> [6.null pdb](files/slides/6.null/missing%20semester%20en.pdf#page=64&selection=37,0,37,9)
> [pdb-tutorial](https://github.com/MartinLwx/pdb-tutorial?tab=readme-ov-file#pdb-101-pdb-%E4%BB%8B%E7%BB%8D)
> [Python Debugging With Pdb](https://realpython.com/python-debugging-pdb/#toc)

> [!NOTE] others
> [What is Reverse Debugging and Why Do We Need It? ](https://undo.io/resources/reverse-debugging-whitepaper)
> [rr: lightweight recording & deterministic debugging](https://rr-project.org/)
> [Debug C and C++ programs with rr ](https://developers.redhat.com/blog/2021/05/03/instant-replay-debugging-c-and-c-programs-with-rr#requirements_and_setup)
> 简单来说，reverse debugging通过记录程序的所有行为（eg:memory access,call to os)，从而通过倒回的方式去定位Bug。