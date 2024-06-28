# Vim Best Practice
#vim

[dot 范式](../../files/books/Vim.pdf#page=54)
尽量使用 Vim 中的精髓部分——dot(.)

[停顿在Normal模式](../../files/books/Vim.pdf#page=57)
Normal 模式便是我们使用 Vim 时最自然放松的状态

[控制撤销命令的粒度](../../files/books/Vim.pdf#page=58)
在 Vim 中，我们自己可以控制撤销命令的粒度。从进入插入模式开始，直到返回普通模式为止，在此期间输入或删除的任何内容都被当成一次修改。这样我们的 undo 便能更加灵活 。

[尽量构造简易可重复的修改](../../files/books/Vim.pdf#page=60)
可重复的操作可以最大限度发挥 dot 的威力。

[能够重复，就别用次数](../../files/books/Vim.pdf#page=67)
能够重复，就别用次数去重复执行命令。这是基于 dot 范式的。

[操作符+动作命令=操作](../../files/books/Vim.pdf#page=70)

[可视模式基本逻辑](../../files/books/Vim.pdf#page=90)

[插入模式下即时更正错误](../../files/books/Vim.pdf#page=75)

[不离开插入模式粘贴寄存器中的文本](../../files/books/Vim.pdf#page=80)

[R -- 进入替换模式 ](../../files/books/Vim.pdf#page=87)
推荐使用gR进入虚拟替换模式，详见链接。

[如果可以，最好使用操作符命令，而不是可视模式](../../files/books/Vim.pdf#page=98)
操作符命令修改文本时在 dot 范式下的表现优于可视模式

[对于列文本的修改及灵活使用 24-26](../../files/books/Vim.pdf#page=101) 