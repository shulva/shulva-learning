# 使用 markdown 语法复刻1-b所提及的设计
#pdf #markdown

`<font color=red>红色<font>` <font color=red>红色<font>

`<font color=#075fa8>对比色<font>`<font color=#075fa8>对比色<font>

`<font size=10>size<font>` <font size=10>size<font>

`<font face=STKaiti>楷体<font>`<font face=STKaiti>楷体<font>

###### `###### <font color=red face=STKaiti>颜色在标题上的应用<font>` <font color=red face=STKaiti> 颜色在标题上的应用<font> 

`**粗体**` **粗体**

`*斜体*` *斜体* 

`<u>下划线<u>` <u>下划线<u>

> [!NOTE]
> 
> 使用 callout 语法进行背景色的对比，有多种颜色及形式可选

表格可以使用 obsidian 右键自带的插入表格，较为方便

脚注[^1]

分割线为---或***，效果如下

---

```
$$ 
\begin{equation} 
\sum_{i=0}^n i^2 = \frac{(n^2+n)(2n+1)}{6}
\label{eq:sum_1} 
\end{equation} 
\tag{1}
$$
```
$$ 
\begin{equation} 
\sum_{i=0}^n i^2 = \frac{(n^2+n)(2n+1)}{6}
\label{eq:sum_1} 
\end{equation} 
\tag{1}
$$

> [!Warning]
> \eqref 暂时有问题，公式的引用没法解决
> \label 经常出 multiply defined 的错误，重新命名 eq 即可
> 行号使用 \tag 解决即可

# References
[Markdown 语法手册 - 经验分享 - Obsidian 中文论坛](https://forum-zh.obsidian.md/t/topic/25240)
[markdown语法 | obsidian文档咖啡豆版](https://obsidian.vip/zh/markdown/)
[Markdown 数学公式指导手册 | Freeopen](https://freeopen.github.io/mathjax/)

 [^1]: 使用`[^锚点文字]`来定义脚注，在之后的任意位置使用`[^锚点文字]:`来描述脚注内容