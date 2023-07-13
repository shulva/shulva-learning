# [PA 南京大学 计算机系统基础实验](https://ysyx.oscc.cc/docs/ics-pa/)
## [PA0 世界诞生的前夜：开发环境配置](https://ysyx.oscc.cc/docs/ics-pa/PA0.html) 
### [Preparation](https://ysyx.oscc.cc/docs/ics-pa/0.1.html)
- Remember, the machine is always right!
### [First Exploration with GNU/Linux](https://ysyx.oscc.cc/docs/ics-pa/0.2.html) 
- you can use df -h to see how much disk space linux occupies
### [installing tools](https://ysyx.oscc.cc/docs/ics-pa/0.3.html) 
- you will download and install some tools needed for the PAs from the network mirrors.
#### checking network state
- If you can ping Baidu successfully, you should successfully ping the mirror host above, too.
#### Setting APT source file
- 如果你的系统不是Ubuntu 22.04, 请更换合适的源
- you can use cat /etc/apt/sources.list to see the apt source
#### Updating APT package information
- you can use apt-get update to update the source
#### Installing tools for PAs
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
#### Learning vim
- [Vim Genius](http://www.vimgenius.com/)
#### Enabling syntax highlight
- missing semester include this 
#### Enabling more vim features
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
#### Learning to use basic tools
- [Here(Linux)](https://ysyx.oscc.cc/docs/ics-pa/linux.html) is a small tutorial for GNU/Linux written by jyy
- [RTFM](https://en.wikipedia.org/wiki/RTFM) Read The Fucking Manual. Sometime you need to use it as the final weapon
- [Here(GDB)](https://www.cprogramming.com/gdb.html) is a small tutorial for GDB
#### installing tmux
missing semester include this
- how to ask question? you need read [this](https://github.com/ryanhanwu/How-To-Ask-Questions-The-Smart-Way/blob/master/README-zh_CN.md) and [this](https://github.com/tangx/Stop-Ask-Questions-The-Stupid-Ways/blob/master/README.md)
#### Why GNU/Linux and How to 
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
#### Git Usage
- include in missing semester
#### Compiling and Running NEMU
- please not the warning of "no such file or directory" and install correspondent tools
#### Development Tracing
#### Local Commit
#### Writing Report
#### Submission
- [Here(C language)](https://docs.huihoo.com/c/linux-c-programming/) is an excellent tutorial about C language. It contains a lot like ds,arch,assembly,os and so on.
- STFW
- RTFM
- RTFSC
## [PA1 - 开天辟地的篇章: 最简单的计算机](https://ysyx.oscc.cc/docs/ics-pa/PA1.html)
### [在开始愉快的PA之旅之前](https://ysyx.oscc.cc/docs/ics-pa/1.1.html)
#### NEMU是什么？
- 你可以通过[FUEUX(你在PA0中已经克隆了)](https://github.com/NJU-ProjectN/fceux-am)运行一些老游戏的ROM,阅读并根据fceux-am/README.md中的内容进行操作
