# gdb

> [!NOTE] tutorial 1
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