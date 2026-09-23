# Vim 

#vim

> [!NOTE] Vim Extension
> [Extending Vim and Plugins](files/slides/6.null/missing%20semester%20en.pdf#page=26&selection=73,0,73,13)
> [Vimium - Chrome Web Store ](https://chromewebstore.google.com/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb?hl=en)

> [!NOTE] Vim Resources
> https://cheatsheets.zip/vim
> [Vim Tips Wiki | Fandom](https://vim.fandom.com/wiki/Vim_Tips_Wiki)
> [Vimways ~ 2019](https://vimways.org/2019/)has Various vim tips
> [VimGolf](https://www.vimgolf.com/)interesting vim game
> [bram's Vim](https://www.moolenaar.net/habits.html)

### Vim进阶示例

这里给出一些与书中技巧相关的命令，脱离简单的`y,c,p,d + w/hjkl`的用法，精进vim的使用。

`W`:到下一个大单词（以空格分隔）词首
`{/}`:到上/下一个段落，以空行为分隔

##### 范围选择进阶
- **使用标记 (Marks)**:
    - `m[a-z]` - 在当前光标位置设置一个标记（如 `ma`）。
    - `'[a-z]` - 跳转到标记所在行的行首（如 `'a`）。
	- `` `[a-z]`` - 精确跳转到标记所在的光标位置（如 `a`）。
    - **组合应用**: 通过设置两个标记（如`ma`在起点，`mb`在终点），可以用`db`或`yb` 这样的命令精确操作标记之间的文本，而无需进入可视模式。
- **使用搜索 (Search) 作为移动**:
    - `/{pattern} (向前搜索) 和 ?{pattern} (向后搜索) `本身就是一种“移动”命令。
    - **组合应用**:
        - `d/foo`- 删除从当前位置到下一个“foo”出现之处。
        - `y?bar` - 复制从当前位置到上一个“bar”出现之处。
##### 扩展能力：寄存器与数量修饰
- **使用[命名寄存器](2-a-5-a%20（复制粘贴与寄存器的关系）.md#寄存器)**:
    - `"[a-z]` - 作为命令的前缀，指定本次操作使用的寄存器。
    - **组合应用**:
        - `"add` - 将当前行剪切到寄存器 a 中。
        - `"by/foo` - 将到下一个"foo"的文本复制到寄存器 b 中。
        - `"ap` - 将寄存器 a 的内容粘贴出来。
    - **意义**: 提供了多个独立的剪贴板，可以同时处理多个不相关的文本片段。

#####  批处理与自动化：[Vim-Ex命令](2-a-2-c%20（命令行模式）.md#Vim-Ex命令)
这部分展示了Vim继承自ed和ex的强大行编辑能力。
- **地址与范围**:
    - :`127,215` - 指定第127到215行。
    - `. (当前行), $ (最后一行), :% (所有行)`
    - `+n, -n` - 相对偏移。
    - `:'a,'b` - 标记a和b之间的行范围。
- **核心Ex命令**:
    - `:s/old/new/g` - 替换 (Substitute)。
    - `:d` - 删除 (Delete)。
    - `:m$` - 移动到文件末尾 (Move)。
    - `:j` - 连接 (Join)。
    - `:g/{pattern}/[cmd]`: **全局命令 (Global)**，对所有匹配{pattern}的行执行`[cmd]。
    - `:v/{pattern}/[cmd]`: 反向全局命令，对所有不匹配{pattern}的行执行[cmd]。
        - **示例**: `:%g/foo/d` (删除所有含"foo"的行), `:%g/^ /-1j` (将所有以三个空格开头的行与其上一行合并)。
#####  与外部世界交互：过滤与读写

Vim可以将[外部mkl](2-a-2-c%20（命令行模式）.md#Vim与Shell)无缝集成到编辑流程中。
- **读入文件或命令**:
    - `:r {filename}` - 将文件内容读入当前位置。
    - `:r! {command}` - 将命令的输出结果读入当前位置。
- **过滤文本 (!)**:
    - `!{motion}{command}` 或 `:{range}!{command}` - 将指定的文本**作为输入**传递给外部命令，并用**命令的输出**替换原文。
    - **示例**:
        - `1G!Gsort` - 对整个文件进行排序。（`1G`先移动）
        - `{!}fmt` - 重新格式化当前段落。（`{`先移动）
        - `:1,$!sort -t',' -k2` - 整个文件排序
#####  终极自动化：宏与寄存器执行
- **执行寄存器 (@)**:
    - `@[a-z]` - 将寄存器中的内容作为Vim命令序列来执行。
    - **示例**: 通过一系列操作，将一行文本（如一个文件路径）构造成一个完整的Ex命令（如`:r /path/to/file`），然后存入寄存器c `("cdd)`，最后用`@c`执行它。
-  sourcing 文件 (:so)**:
    - `:so {filename}` - 执行文件中的Ex命令。
    - 常用于加载配置文件 (.vimrc) 或预设的“宏”脚本。