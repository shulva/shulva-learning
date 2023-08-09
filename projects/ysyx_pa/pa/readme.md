# [PA 南京大学 计算机系统基础实验](https://ysyx.oscc.cc/docs/ics-pa/)
## [PA0 世界诞生的前夜：开发环境配置](https://ysyx.oscc.cc/docs/ics-pa/PA0.html) 
### [Preparation](https://ysyx.oscc.cc/docs/ics-pa/0.1.html)
#### [Installing Ubuntu](https://ysyx.oscc.cc/docs/ics-pa/0.1.html#installing-ubuntu)
- Remember, the machine is always right!
### [First Exploration with GNU/Linux](https://ysyx.oscc.cc/docs/ics-pa/0.2.html) 
- you can use df -h to see how much disk space linux occupies
### [installing tools](https://ysyx.oscc.cc/docs/ics-pa/0.3.html) 
- you will download and install some tools needed for the PAs from the network mirrors.
#### [checking network state](https://ysyx.oscc.cc/docs/ics-pa/0.3.html#checking-network-state)
- If you can ping Baidu successfully, you should successfully ping the mirror host above, too.
#### [Setting APT source file](https://ysyx.oscc.cc/docs/ics-pa/0.3.html#setting-apt-source-file)
- 如果你的系统不是Ubuntu 22.04, 请更换合适的源
- you can use cat /etc/apt/sources.list to see the apt source
#### [Updating APT package information](https://ysyx.oscc.cc/docs/ics-pa/0.3.html#setting-apt-source-file)
- you can use apt-get update to update the source
#### [installing tools for pas](https://ysyx.oscc.cc/docs/ics-pa/0.3.html#installing-tools-for-pas)
- The following tools are necessary for PAs:
```
apt-get install build-essential    # build-essential packages, include binary utilities, gcc, make, and so on
apt-get install man                # on-line reference manual
apt-get install gcc-doc            # on-line reference manual for gcc
apt-get install gdb                # GNU debugger
apt-get install git                # revision control system
apt-get install libreadline-dev    # a library used later
apt-get install libsdl2-dev        # a library used later
apt-get install llvm llvm-dev      # llvm project, which contains libraries used later
apt-get install llvm-11 llvm-11-dev # only for ubuntu20.04
```
### [Configuring vim](https://ysyx.oscc.cc/docs/ics-pa/0.4.html)
#### [Learning vim](https://ysyx.oscc.cc/docs/ics-pa/0.4.html#learning-vim)
- [Vim Genius](http://www.vimgenius.com/)
#### [Enabling syntax highlight](https://ysyx.oscc.cc/docs/ics-pa/0.4.html#enabling-syntax-highlight)
- missing semester include this 
#### [Enabling more vim features](https://ysyx.oscc.cc/docs/ics-pa/0.4.html#enabling-more-vim-features)
```
set background=dark
setlocal noswapfile " 不要生成swap文件
set bufhidden=hide " 当buffer被丢弃的时候隐藏它
colorscheme evening " 设定配色方案
set number " 显示行号
set cursorline " 突出显示当前行
set ruler " 打开状态栏标尺
set shiftwidth=2 " 设定 << 和 >> 命令移动时的宽度为 2
set softtabstop=2 " 使得按退格键时可以一次删掉 2 个空格
set tabstop=2 " 设定 tab 长度为 2
set nobackup " 覆盖文件时不备份
set autochdir " 自动切换当前目录为当前文件所在的目录
set backupcopy=yes " 设置备份时的行为为覆盖
set hlsearch " 搜索时高亮显示被找到的文本
set noerrorbells " 关闭错误信息响铃
set novisualbell " 关闭使用可视响铃代替呼叫
set t_vb= " 置空错误铃声的终端代码
set matchtime=2 " 短暂跳转到匹配括号的时间
set magic " 设置魔术
set smartindent " 开启新行时使用智能自动缩进
set backspace=indent,eol,start " 不设定在插入状态无法用退格键和 Delete 键删除回车符
set cmdheight=1 " 设定命令行的行数为 1
set laststatus=2 " 显示状态栏 (默认值为 1, 无法显示状态栏)
set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ Ln\ %l,\ Col\ %c/%L%) " 设置在状态行显示的信息
set foldenable " 开始折叠
set foldmethod=syntax " 设置语法折叠
set foldcolumn=0 " 设置折叠区域的宽度
setlocal foldlevel=1 " 设置折叠层数为 1
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR> " 用空格键来开关折叠
filetype plugin indent on
set showmatch          " Show matching brackets.
set ignorecase         " Do case insensitive matching
set smartcase          " Do smart case matching
set incsearch          " Incremental search
set hidden             " Hide buffers when they are abandoned
```
### [More Exploration](https://ysyx.oscc.cc/docs/ics-pa/0.5.html)
#### [Learning to use basic tools](https://ysyx.oscc.cc/docs/ics-pa/0.5.html#learning-to-use-basic-tools)
- [Here(Linux)](https://ysyx.oscc.cc/docs/ics-pa/linux.html) is a small tutorial for GNU/Linux written by jyy
- [RTFM](https://en.wikipedia.org/wiki/RTFM) Read The Fucking Manual. Sometime you need to use it as the final weapon
- [Here(GDB)](https://www.cprogramming.com/gdb.html) is a small tutorial for GDB
- homework:Write a "Hello World" program under GNU/Linux:[link](./pa0/hello_world.c)
- homework:Write a Makefile to compile the "Hello World" program:[link](./pa0/Makefile)
- homework:Learn to use GDB
#### [installing tmux](https://ysyx.oscc.cc/docs/ics-pa/0.5.html#installing-tmux)
missing semester include this
- how to ask question? you need read [this](https://github.com/ryanhanwu/How-To-Ask-Questions-The-Smart-Way/blob/master/README-zh_CN.md) and [this](https://github.com/tangx/Stop-Ask-Questions-The-Stupid-Ways/blob/master/README.md)
- think:things behind scrolling
#### [Why GNU/Linux and How to](https://ysyx.oscc.cc/docs/ics-pa/0.5.html#why-gnu-linux-and-how-to)
Unix Philosophy:
- 每个工具只做一件事情, 但做到极致
- 工具采用文本方式进行输入输出, 从而易于使用
- 通过工具之间的组合来解决复杂问题
some cli tools:
- 文件管理 - cd, pwd, mkdir, rmdir, ls, cp, rm, mv, tar
- 文件检索 - cat, more, less, head, tail, file, find
- 输入输出控制 - 重定向, 管道, tee, xargs
- 文本处理 - vim, grep, awk, sed, sort, wc, uniq, cut, tr
- 正则表达式
- 系统监控 - jobs, ps, top, kill, free, dmesg, lsof
### [Getting Source Code for PAs](https://ysyx.oscc.cc/docs/ics-pa/0.6.html)
- 不要使用root账户做实验!!!
- [why it is bad to login as root?](https://askubuntu.com/questions/16178/why-is-it-bad-to-log-in-as-root)
- [git visualizing](http://onlywei.github.io/explain-git-with-d3/)
#### [Git Usage](https://ysyx.oscc.cc/docs/ics-pa/0.6.html)
- include in missing semester
#### [Compiling and Running NEMU](https://ysyx.oscc.cc/docs/ics-pa/0.6.html)
- please not the warning of "no such file or directory" and install correspondent tools
#### [Development Tracing](https://ysyx.oscc.cc/docs/ics-pa/0.6.html)
#### [Local Commit](https://ysyx.oscc.cc/docs/ics-pa/0.6.html)
#### [Writing Report](https://ysyx.oscc.cc/docs/ics-pa/0.6.html)
#### [Submission](https://ysyx.oscc.cc/docs/ics-pa/0.6.html)
- [Here(C language)](https://docs.huihoo.com/c/linux-c-programming/) is an excellent tutorial about C language. It contains a lot like ds,arch,assembly,os and so on.
- STFW
- RTFM
- RTFSC
## [PA1 - 开天辟地的篇章: 最简单的计算机](https://ysyx.oscc.cc/docs/ics-pa/PA1.html)
### [在开始愉快的PA之旅之前](https://ysyx.oscc.cc/docs/ics-pa/1.1.html)
#### [NEMU是什么？](https://ysyx.oscc.cc/docs/ics-pa/1.1.html#nemu%E6%98%AF%E4%BB%80%E4%B9%88)
- 简要介绍了模拟器，编译加速以及NEMU的概念
- 你可以通过[FUEUX(你在PA0中已经克隆了)](https://github.com/NJU-ProjectN/fceux-am)运行一些老游戏的ROM,阅读并根据fceux-am/README.md中的内容进行操作.我写了个shell脚本，将游戏名作为参数输入即可
- make程序默认使用单线程来顺序地编译所有文件,为了加快编译的过程, 我们可以让make创建多个线程来并行地编译文件.具体地, 首先你需要通过lscpu命令来查询你的系统中有多少个CPU. 然后在运行make的时候添加一个-j?的参数, 其中?为你查询到的CPU数量.
- 你也可以通过ccache来缩短编译时间
#### [选择你的角色](https://ysyx.oscc.cc/docs/ics-pa/1.1.html#%E9%80%89%E6%8B%A9%E4%BD%A0%E7%9A%84%E8%A7%92%E8%89%B2)
- 简要介绍了ISA的概念，给予了三个ISA的手册
- 你需要从x86/mips32/riscv32(64)这三种指令集架构(ISA)中选择一种
- 为了方便叙述, 讲义将用$ISA来表示你选择的ISA
- NEMU的框架代码会把riscv32作为默认的ISA: [Volume1](https://github.com/riscv/riscv-isa-manual/releases/download/draft-20210813-7d0006e/riscv-spec.pdf),[Volume2](https://github.com/riscv/riscv-isa-manual/releases/download/draft-20210813-7d0006e/riscv-privileged.pdf),[ABI for riscv](https://github.com/riscv-non-isa/riscv-elf-psabi-doc)
#### [还等什么呢？](https://ysyx.oscc.cc/docs/ics-pa/1.1.html#%E8%BF%98%E7%AD%89%E4%BB%80%E4%B9%88%E5%91%A2)
- 记得随时记录实验心得！
### [开天辟地的篇章](https://ysyx.oscc.cc/docs/ics-pa/1.2.html)
#### [最简单的计算机](https://ysyx.oscc.cc/docs/ics-pa/1.2.html#%E6%9C%80%E7%AE%80%E5%8D%95%E7%9A%84%E8%AE%A1%E7%AE%97%E6%9C%BA)
- 简要介绍了一个简单的计算模型
- CPU怎么知道现在执行到哪一条指令呢? 为此, 先驱为CPU创造了一个特殊的计数器, 叫"程序计数器"(Program Counter, PC). 在x86中, 它有一个特殊的名字, 叫EIP(Extended Instruction Pointer).
- [turing machine(计算模型)](https://en.wikipedia.org/wiki/Universal_Turing_machine)
- think:计算机可以没有寄存器吗? (建议二周目思考)
- homework:尝试理解计算机如何计算
#### [重新认识程序:程序是个状态机](https://ysyx.oscc.cc/docs/ics-pa/1.2.html#%E9%87%8D%E6%96%B0%E8%AE%A4%E8%AF%86%E7%A8%8B%E5%BA%8F-%E7%A8%8B%E5%BA%8F%E6%98%AF%E4%B8%AA%E7%8A%B6%E6%80%81%E6%9C%BA)
- 简要介绍了将计算机与程序看作状态机的思想,介绍了其的优点
- homework:从状态机视角理解程序运行
(0,x,x)->(1,0,x)->(2,0,0)->(3,0,1)->(4,1,1)->(2,1,1)->(3,1,2)->(4,3,2)->...->(2,4851,98)->(3,4851,99)->(4,4950,99)->(2,4950,99)->(3,4950,100)->(4,5050,100)->(5,5050,100)
### [RTFSC](https://ysyx.oscc.cc/docs/ics-pa/1.3.html)
- 为了方便叙述, 我们将在NEMU中模拟的计算机称为"客户(guest)计算机", 在NEMU中运行的程序称为"客户程序".
#### [框架代码初探](https://ysyx.oscc.cc/docs/ics-pa/1.3.html#%E6%A1%86%E6%9E%B6%E4%BB%A3%E7%A0%81%E5%88%9D%E6%8E%A2)
- 简要介绍了代码文件的架构
- [NEMU API](https://ysyx.oscc.cc/docs/ics-pa/nemu-isa-api.html)
- think:一个程序从哪里开始执行呢?
#### [配置系统和项目构建](https://ysyx.oscc.cc/docs/ics-pa/1.3.html#%E9%85%8D%E7%BD%AE%E7%B3%BB%E7%BB%9F%E5%92%8C%E9%A1%B9%E7%9B%AE%E6%9E%84%E5%BB%BA)
- 简单介绍了NEMU系统配置的文件和过程以及Makefile编译链接的文件和过程
- 目前我们只需要关心配置系统生成的如下文件:
- nemu/include/generated/autoconf.h, 阅读C代码时使用
- nemu/include/config/auto.conf, 阅读Makefile时使用
- 在menuconfig中选中TARGET_AM时, nemu/src/monitor/sdb目录下的所有文件都不会参与编译.
- Makefile的编译规则在nemu/scripts/build.mk中定义
- 我们可以键入make -nB, 它会让make程序以"只输出命令但不执行"的方式强制构建目标.
- [make](https://www.gnu.org/software/make/manual/make.html#Overview)
#### [准备第一个客户程序](https://ysyx.oscc.cc/docs/ics-pa/1.3.html#%E5%87%86%E5%A4%87%E7%AC%AC%E4%B8%80%E4%B8%AA%E5%AE%A2%E6%88%B7%E7%A8%8B%E5%BA%8F)
- 简要介绍了客户程序运行前的一系列准备工作
- think:kconfig生成的宏与条件编译
- think:为什么全部都是函数?
- think:参数的处理过程
- [Disk image](https://en.wikipedia.org/wiki/Disk_image)
- homework:实现x86的寄存器结构体(二周目再写x86,一周目先用riscv)
- think: reg\_test()是如何测试你的实现的?
#### [运行第一个客户程序](https://ysyx.oscc.cc/docs/ics-pa/1.3.html#%E8%BF%90%E8%A1%8C%E7%AC%AC%E4%B8%80%E4%B8%AA%E5%AE%A2%E6%88%B7%E7%A8%8B%E5%BA%8F)
- 简要介绍了NEMU的使用方法和内部运行的流程,以及一些在调试中有用的内置宏
- 在cmd_c()函数中, 调用cpu_exec()的时候传入了参数-1, 你知道这是什么意思吗?
- 调用cpu_exec()的时候传入了参数-1, 这一做法属于未定义行为吗? 请查阅C99手册确认你的想法.
- think:谁来指示程序的结束?
- think:有始有终 (建议二周目思考)
- homework:理解框架代码
- GDB还自带一个叫TUI的简单界面. 在一个高度较高的窗口中运行GDB后, 输入layout split就可以切换到TUI, 这样你就可以同时从源代码和指令的角度来观察程序的行为了. 
- [gdb command](http://www.gdbtutorial.com/gdb_commands)
- homework:为NEMU编译时添加GDB.调试信息会增加一个编译选项:(CFLAGS_BUILD += $(if $(CONFIG_CC_DEBUG),-Og -ggdb3,))
- homework:优美地退出
#### [就是这么简单](https://ysyx.oscc.cc/docs/ics-pa/1.3.html#%E5%B0%B1%E6%98%AF%E8%BF%99%E4%B9%88%E7%AE%80%E5%8D%95)
- 存储器是个在nemu/src/memory/paddr.c中定义的大数组
- PC和通用寄存器都在nemu/src/isa/$ISA/include/isa-def.h中的结构体中定义
- 加法器在... 嗯, 这部分框架代码有点复杂, 不过它并不影响我们对TRM的理解, 我们还是在PA2里面再介绍它吧
- TRM(turing machine)的工作方式通过cpu_exec()和exec_once()体现
