# Practical Vim
#vim

这部分笔记制作时，书中的指导思想应当与具体操作或者示例分开。

> [!Abstract] Vim解决问题的方式
> 
> [dot 范式](../../files/books/Vim.pdf#page=54)
> 尽量使用 Vim 中的精髓部分——dot(.)，不停地执行-重复。
> 

> [!Abstract] 模式
> 
> [控制撤销命令的粒度](../../files/books/Vim.pdf#page=58)
> 在 Vim 中，我们自己可以控制撤销命令的粒度。从进入插入模式开始，直到返回普通模式为止，在此期间输入或删除的任何内容都被当成一次修改。这样我们的 undo 便能更加灵活 。
> 
> [尽量构造简易可重复的修改](../../files/books/Vim.pdf#page=60)
> 可重复的操作可以最大限度发挥 dot 的威力。
> 
> [能够重复，就别用次数](../../files/books/Vim.pdf#page=67)
> 能够重复，就别用次数去重复执行命令。这是基于 dot 范式的。
> 
> [如果可以，最好使用操作符命令，而不是可视模式](../../files/books/Vim.pdf#page=98)
> 操作符命令修改文本时在 dot 范式下的表现优于可视模式
> 
> > [!Example] 实战示例
> >
> >  [R -- 进入替换模式 ](../../files/books/Vim.pdf#page=87)
> 推荐使用gR进入虚拟替换模式，详见链接。
> >
> > [不离开插入模式粘贴寄存器中的文本](../../files/books/Vim.pdf#page=80)
> >
> > [对于列文本的修改及灵活使用 24-26](../../files/books/Vim.pdf#page=101) 


