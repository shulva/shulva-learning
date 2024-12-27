# Stack

![04.Stack + Queue, 页面 2](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=2)

[Stack-ADT](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=3):各种接口函数的定义及功能
[Stack](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=4):实现与接口(push,pop,top),直接基于向量或列表的接口派生

## 栈的应用

> [!example] 函数调用栈
> ![Stack](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=10)

> [!example] 进制转换
> [Stack](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=21):给定任一10进制非负整数，将其转换为n进制表示形式
> >[!faq] 难点
> > - 转换后的位数在事先不能简便地确定，辅助空间如何才能既足够，亦不浪费？
> > - 转换后的各数位是自低而高得到的，如何自高而低输出？
> > - 若使用向量，则扩容策略必须得当；若使用列表，则多数接口均被闲置
> 
>  [代码实现](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=24):短除法：整商 + 余数

> [!example] 括号匹配
> [Stack](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=28):匹配左右括号
> [代码实现](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=29):顺序扫描表达式，用栈记录已扫描的部分(实际上只需记录左括号)。反复迭代,凡遇(，则进栈；凡遇)，则出栈
> >[!faq] 扩展
> > - 多种括号:[如法炮制](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=31)

> [!example] 中缀表达式计算:infix
> ![演示](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=37)
>
> - [思路](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=34):优先级高的局部执行计算，并被代以其数值。运算符渐少，直至得到最终结果
> - [代码实现及执行过程示例](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=39):运算数栈和运算符栈两者配合处理
>
> >[!example] 示例
> > [手工中缀表达式计算](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=51)
>

> [!example] 逆波兰表达式RPN:postfix
>
> ![执行过程示例](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=58)
> - [思路](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=57):在由运算符（operator）和操作数（operand）组成的表达式中，不使用括号（parenthesis-free）即可表示带优先级的运算关系
> - [代码实现中缀表达式转换RPN](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=63)
>
> >[!example] 示例
> > [手工转换RPN](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=61)
>
> >[!faq] PostScript
> > [PostScript](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=65)语言深深地影响了现代印刷业，其便使用了RPN语法。

> [!example] 栈混洗
>
> ![执行过程示例](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=68)
> - [混洗总数SP(n)=?](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=69):catalan(n)
> - [判断序列是否为栈混洗](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=72):对任何1 <= i <= j <= k <= n，[ ..., k , ..., i , ..., j , ... ]的序列必非栈混洗
> - [判断序列是否为栈混洗](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=74):每一个栈混洗，都对应于栈S的n次push与n次pop操作构成的某一序列；反之亦然
>
> >[!faq] 卡特兰数
> >[catalan](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=70)