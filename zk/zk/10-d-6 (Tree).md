# Tree

![Rooted Tree](files/slides/Tsinghua-DSA-2024Fall-chapter/05.Binary%20Trees.pdf#page=3)

[树的接口](files/slides/Tsinghua-DSA-2024Fall-chapter/05.Binary%20Trees.pdf#page=10):root(),parent()...
[父节点+孩子节点的概念](files/slides/Tsinghua-DSA-2024Fall-chapter/05.Binary%20Trees.pdf#page=11)

> [!NOTE] intro
> [Ordered Tree 有序树](files/slides/Tsinghua-DSA-2024Fall-chapter/05.Binary%20Trees.pdf#page=3)：兄弟节点间有次序关系。
> [路径+环路](files/slides/Tsinghua-DSA-2024Fall-chapter/05.Binary%20Trees.pdf#page=5)：
> - $V中的k+1个节点，通过V中的k条边依次相联，构成一条路径/通路$
> - $\pi = \{(v_0,v_1),(v_1,v_2),...(v_{k-1},v_k)\},v_0=v_k即为环路$
>
> [连通+无环](files/slides/Tsinghua-DSA-2024Fall-chapter/05.Binary%20Trees.pdf#page=6)：节点之间均有路径称为连通图。不含环路则为无环图。

## 二叉树

![二叉树接口](files/slides/Tsinghua-DSA-2024Fall-chapter/05.Binary%20Trees.pdf#page=15)

 [BinNode](files/slides/Tsinghua-DSA-2024Fall-chapter/05.Binary%20Trees.pdf#page=21)：二叉树节点接口

> [!NOTE] intro
> [长子-兄弟表示法](files/slides/Tsinghua-DSA-2024Fall-chapter/05.Binary%20Trees.pdf#page=16)：有根且有序的多叉树，均可转化并表示为二叉树。长子=左孩子，兄弟=右孩子
> [节点-边的对应公式](files/slides/Tsinghua-DSA-2024Fall-chapter/05.Binary%20Trees.pdf#page=16)
> [满二叉树](files/slides/Tsinghua-DSA-2024Fall-chapter/05.Binary%20Trees.pdf#page=18)：顾名思义，如果每一个层的结点数都达到最大值，则这个二叉树就是满二叉树。
> [真二叉树](files/slides/Tsinghua-DSA-2024Fall-chapter/05.Binary%20Trees.pdf#page=18)：通过引入外部节点,可使原有节点度数统一为2。如此，即可将任一二叉树转化为真二叉树

> [!example] 括号匹配
> [Stack](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=28):匹配左右括号
> [代码实现](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=29):顺序扫描表达式，用栈记录已扫描的部分(实际上只需记录左括号)。反复迭代,凡遇(，则进栈；凡遇)，则出栈
> >[!faq] 扩展
> > - 多种括号:[如法炮制](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=31)
