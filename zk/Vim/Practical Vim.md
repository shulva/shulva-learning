## chapter1 Vim解决问题的方式
[斜杠/ -- 查找单词](../../../pdf/books/Vim.pdf#page=51)
[f{char} -- 查找字符](../../../pdf/books/Vim.pdf#page=47) 

[一箭双雕](../../../pdf/books/Vim.pdf#page=44)
 很多 Vim 命令可以看作为两个或多个其他命令的组合
 
[可重复执行的操作及如何回退](../../../pdf/books/Vim.pdf#page=49)

[dot 范式](../../../pdf/books/Vim.pdf#page=54)
尽量使用 Vim 中的精髓部分——dot(.)

# 第一部分 模式--mode
## chapter2 普通模式

[停顿在Normal模式](../../../pdf/books/Vim.pdf#page=57)
Normal 模式便是我们使用 Vim 时最自然放松的状态

[控制撤销命令的粒度](../../../pdf/books/Vim.pdf#page=58)
在 Vim 中，我们自己可以控制撤销命令的粒度。从进入插入模式开始，直到返回普通模式为止，在此期间输入或删除的任何内容都被当成一次修改。这样我们的 undo 便能更加灵活 。

[尽量构造可重复的修改](../../../pdf/books/Vim.pdf#page=60)
可重复的操作可以最大限度发挥 dot 的威力。

 [ctrl 数字加减](../../../pdf/books/Vim.pdf#page=64)

[能够重复，就别用次数](../../../pdf/books/Vim.pdf#page=67)
能够重复，就别用次数去重复执行命令。这是基于 dot 范式的。

[操作符+动作命令=操作](../../../pdf/books/Vim.pdf#page=70)

# chapter3 插入模式
[插入模式下即时更正错误](../../../pdf/books/Vim.pdf#page=75)
 
[不离开插入模式粘贴寄存器中的文本](../../../pdf/books/Vim.pdf#page=80)

[插入非常用字符](../../../pdf/books/Vim.pdf#page=85)

[R -- 进入替换模式](../../../pdf/books/Vim.pdf#page=87)
# chapter4  可视模式
[可视模式基本逻辑](../../../pdf/books/Vim.pdf#page=90)

[激活可视模式](../../../pdf/books/Vim.pdf#page=92)

[可视模式基本操作](../../../pdf/books/Vim.pdf#page=93)

[如果可以，最好使用操作符命令，而不是可视模式](../../../pdf/books/Vim.pdf#page=98)
操作符命令修改文本时在 dot 范式下的表现优于可视模式

[对于列文本的修改及灵活使用 24-26](../../../pdf/books/Vim.pdf#page=101) 

# chapter5 命令行模式