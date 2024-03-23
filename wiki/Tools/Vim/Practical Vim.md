## chapter1 Vim解决问题的方式
[斜杠/ -- 查找单词](../../../pdf/books/Vim.pdf#page=51)
[f{char} -- 查找字符](../../../pdf/books/Vim.pdf#page=47) 

[一箭双雕](../../../pdf/books/Vim.pdf#page=44)
 很多 Vim 命令可以看作为两个或多个其他命令的组合
 
[可重复执行的命令](../../../pdf/books/Vim.pdf#page=49)

[dot 范式](../../../pdf/books/Vim.pdf#page=54)
尽量使用 Vim 中的精髓部分——dot(.)
## chapter2 普通模式

[停顿在Normal模式](../../../pdf/books/Vim.pdf#page=57)
Normal 模式便是我们使用 Vim 时最自然放松的状态

[控制撤销命令的粒度](../../../pdf/books/Vim.pdf#page=58)
在 Vim 中，我们自己可以控制撤销命令的粒度。从进入插入模式开始，直到返回普通模式为止，在此期间输入或删除的任何内容都被当成一次修改。这样我们的 undo 便能更加灵活 。
