# Queue

![04.Stack + Queue, 页面 2](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=76)

[Queue](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=78):实现与接口(enqueue,dequeue,front),直接基于向量或列表的接口派生


> [!example] 直方图内最大矩形
>
>  ![执行过程示例](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=84)
> - 可知$maxRect(r) = H[r]* (t(r)-s(r))$
> - $s(r) = max\{k\ | 0 \le k \le r \ and\ H[k-1] < H[r]\}$
> - $t(r) = min\{k\ | r \le k \le n \ and\ H[r] > H[k]\}$
> -简单来说，就是选择左区间中小于矩形高度的横坐标中的最大者和有区间中大于矩形高度的最大者以获得长度
>  
> 对于所有的 r 来说，我们可以使用[暴力算法](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=86)来获得所有的s(r)与t(r)，但是复杂度太高了。

> [!example] 队列的简单应用
> - [资源循环分配](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=80)
> - [银行服务](files/slides/Tsinghua-DSA-2024Fall-chapter/04.Stack%20+%20Queue.pdf#page=81)