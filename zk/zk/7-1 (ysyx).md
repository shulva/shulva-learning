# YSYX问题记录

## **预学习阶段**

### PA0

> [!Question] 实验必做内容：[如何科学地提问](https://ysyx.oscc.cc/docs/2306/preliminary/0.1.html#%E5%A6%82%E4%BD%95%E7%A7%91%E5%AD%A6%E5%9C%B0%E6%8F%90%E9%97%AE)
> 
> ###### 阅读"提问的智慧"和"别像弱智一样提问", 编写读后感
> 读后感：[如何科学地提问-读后感](codetest/typst/report.pdf#page=1&selection=0,0,0,7)
> ###### STFW, RTFM, RTFSC
> STFW: Search The Fuck Web
> RTFM: [Read The Fuck Manual](https://en.wikipedia.org/wiki/RTFM)
> RTFSC: Read The Fuck Source Code

> [!info] 实验选做内容：[First Exploration with GNU/Linux ](https://ysyx.oscc.cc/docs/ics-pa/0.2.html)
> 
> ###### Where is GUI?
> >Have you wondered if there is something that you can do it in CLI, but can not in GUI?
> 
> 例如寻找"shulva"文件夹下所有的jpg文件并在他们的文件名后加上按特定顺序排列的数字。更多示例请阅读[这里](https://www.reddit.com/r/linux/comments/2mur41/what_is_there_you_cannot_do_using_gui_what_you/)。
> 
> ###### Why executing the "poweroff" command requires superuser privilege in some Linux distributions?
> > Can you provide a scene where bad thing will happen if the `poweroff` command does not require superuser privilege?
> 
> Linux毕竟是multi-user的操作系统，poweroff会影响到其他的用户。你并不想在运行关键程序时被人关机打断吧？更详细的解释请阅读[这里](https://unix.stackexchange.com/questions/253767/why-does-reboot-and-poweroff-require-root-privileges)。

> [!info] 实验选做内容：[Linux入门教程](https://ysyx.oscc.cc/docs/ics-pa/linux.html#%E6%8E%A2%E7%B4%A2%E5%91%BD%E4%BB%A4%E8%A1%8C)
> 
> ###### 消失的cd
> >`cd`没有manpage, 这是为什么? 如果你思考后仍然感到困惑, 试着到互联网上寻找答案.
> 
> 确实不知道原因。所以...RTFM and STFW
> man cd 会导向 bulit-in的 manpage,有[这个](https://superuser.com/questions/1487103/running-whatis-cd-always-returns-nothing-appropriate-on-ubuntu-18-04)解释,但到底为什么会这样？
> 详见 [Why is cd not a program? ](https://unix.stackexchange.com/questions/38808/why-is-cd-not-a-program)and [Shell builtin](https://en.wikipedia.org/wiki/Shell_builtin)and 
> [What is the difference between a builtin command and one that is not? ](https://unix.stackexchange.com/questions/11454/what-is-the-difference-between-a-builtin-command-and-one-that-is-not)
> 
>
> > [!warning]
> > 
> > [While some builtin commands may exist in	more than one shell, their operation may be different	under each shell which supports them.](https://man.freebsd.org/cgi/man.cgi?builtin#DESCRIPTION)
> > 也许是因为各个shell中built-in command的差异，所以这些built-in command没有一个统一的manpage?