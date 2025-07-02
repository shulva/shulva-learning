# 矢量化加速[^1]

在训练我们的模型时，我们经常希望能够同时处理整个小批量的样本。 
为了实现这一点，需要我们对计算进行**矢量化**， 从而利用线性代数库，而不是在Python中编写开销高昂的for循环。

为了说明矢量化为什么如此重要，我们考虑对向量相加的两种方法。 
我们实例化两个全为1的10000维向量。 

在一种方法中，我们将使用Python的for循环遍历向量。 
在另一种方法中，我们将依赖对`+`的调用。

```python

n = 10000
a = torch.ones([n])
b = torch.ones([n])

c = torch.zeros(n)
timer = Timer()
for i in range(n):
    c[i] = a[i] + b[i] #'0.16749 sec'

d = a + b # '0.00042 sec'

```

 矢量化代码通常会带来数量级的加速。 另外，我们将更多的数学运算放到库中，而无须自己编写那么多的计算，从而减少了出错的可能性。


[^1]: https://zh-v2.d2l.ai/chapter_linear-networks/linear-regression.html#id8
