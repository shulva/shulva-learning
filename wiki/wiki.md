# Principle
经过长期的思考与实践，我认为摘抄书上的内容所形成的笔记是不适用于我的。

根本原因是教科书的内容太长，如果摘抄的话做一篇笔记所需要的时间过久。经过思考我认为通过将书中的知识点化作可以引用且可以在wiki文件中进行一定的内容编辑的wiki形式是比较适合的。

同样，知识点形成一定规模的wiki文件后我们也可以通过目录的方式将其组织起来。没有优秀电子版的书籍可以使用typst或是texmacs来手动做pdf将文件内容组织起来。至于知识点是应该用.md还是使用.pdf还有待思考（引用应当直接指向ppt或是书籍pdf，做笔记太耗费时间)。

对于pdf和ppt的注释应当写在文件中还是写在wiki文件中还有待商榷。

正在做笔记和已经做完笔记的pdf书籍应当规约在一个文件夹中，鉴于书的大小一般较大，就不放入git仓库中了，但是文件夹与wiki文件的位置要定死，可以考虑使用.gitignore，迁移使用移动硬盘就行。
# Algorithm
# Architecture
# Tools
## Obsidian
[由此开始 - Obsidian 中文帮助 - Obsidian Publish](https://publish.obsidian.md/help-zh/%E7%94%B1%E6%AD%A4%E5%BC%80%E5%A7%8B)
## typst
[Tutorial – Typst Documentation](https://typst.app/docs/tutorial/)
https://typst.app/app/
[Typst 中文社区](https://typst.cn/#/)
对中文的italic支持不好，停止考察
感觉没有解决什么texmacs中我不满意的部分
## Texmacs
[TexmacsNotes](TexmacsNotes.pdf)
### pdf-design
可以参考以下几本书
[Intel® 64 and IA-32 Architectures.pdf](file:///D:/others/pdf/Intel%C2%AE%2064%20and%20IA-32%20Architectures.pdf)
- 使用#075fa8颜色作为对比
- 大章节小章节标题以及页眉图表上的文字广泛使用此颜色作为对比
- 大量的列表，表格，图以及粗体的运用
- 大章节标题下会有下划线分割，texmacs中用插入-突出中的设置即可
- 介绍新定义/概念时会另起一行，同时使用粗体或颜色来修饰此概念。
[Randal E. Bryant, David R. O’Hallaron - Computer Systems. A Programmer’s Perspective [3rd ed.]-Pearson (2016).pdf](file:///D:/others/pdf/Randal%20E.%20Bryant,%20David%20R.%20O%E2%80%99Hallaron%20-%20Computer%20Systems.%20A%20Programmer%E2%80%99s%20Perspective%20[3rd%20ed.]-Pearson%20(2016).pdf)
- 使用颜色为#00adee
- 各级标题会使用粗体或颜色来起到对比作用
- 附加内容(Aside)会使用背景色来对比，framed的背景色需要选中后使用右键-颜色添加，直接用调色板只会改变字体颜色
- 图表的描述内容不会使用颜色，但是图表本身的序号会使用(类似figure 2.8会被颜色修饰，但后面的描述内容不会)
- 类似于principle原理，therom定理的会使用颜色标红。公式行的尾部会有形于 (2.3) 序号的东西
- 会使用脚注
- 代码块会使用分割线与正文分割
[Cormen, Thomas H._ Leiserson, Charles E._ Rivest, Ronald L._ Stein, Clifford - Introduction to Algorithms (2022).pdf](file:///D:/others/pdf/Cormen,%20Thomas%20H._%20Leiserson,%20Charles%20E._%20Rivest,%20Ronald%20L._%20Stein,%20Clifford%20-%20Introduction%20to%20Algorithms%20(2022).pdf)
- 标题颜色为#0083b5
- 代码块会使用#fff1d6作为背景色修饰
- 相关的提到的术语/概念会使用#0083b5修饰，同时会使用斜体
- 二级标题会使用下划线分割，点击二级标题可以回到目录对应的位置
- 介绍新定义/概念时会另起一行，同时使用粗体或颜色来修饰此概念。
- proof/lemma之类的会使用加粗斜体，另起一行写主要内容

- 所有在正文中对于图表以及公式定理例子(example)的指代会使用颜色修饰
- example会另起一行的同时使用粗体/花体/颜色修饰
- 重点的概念/内容会使用粗体/花体/颜色
- 笔记的排版要尽量贴合原文排版
- 引用的公式图表有链接可以直接导向本体
- 代码块中的代码也可以使用颜色修饰
- 主流颜色是淡蓝色，也有使用偏深绿色的
- 表格的描述项(第一行/列)使用颜色修饰
