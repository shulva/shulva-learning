# RNN

## RNN intro : Process Sequences

> RNN Advantages and Disadvantages

![lecture_7, 页面 77](files/slides/CS231n/lecture_7.pdf#page=77)

one to many:e.g. Image Captioning image -> sequence of words
many to one:e.g. action prediction sequence of video frames -> action class
many to many:e.g. Video Captioning Sequence of video frames -> caption

![lecture_7, 页面 18](files/slides/CS231n/lecture_7.pdf#page=18)

So, if you have a sequence of input x and a sequence of output y...
![lecture_7, 页面 21](files/slides/CS231n/lecture_7.pdf#page=24)

> Notice: the same function and the same set of parameters are used at every time step.

here, We are using the same set of W and the same activation functions each time we are computing the hidden state.
![lecture_7, 页面 21](files/slides/CS231n/lecture_7.pdf#page=22)

> RNN output generation

So here,$W_{hy}$ is a matrix that you will multiply by your hidden state. 
It converts your hidden state to the dimension of your output.It is also the weight matrix you learn.
So not only does it do the dimension change, but it also applies the transformation to your hidden state.
![lecture_7, 页面 21](files/slides/CS231n/lecture_7.pdf#page=23)

RNN激活函数的其中一个形式。这里的$W_{hh}以及W_{xh}和W_{hy}$从维度映射的角度去理解比较好。
![lecture_7, 页面 26](files/slides/CS231n/lecture_7.pdf#page=26)

---
## Vanilla RNN Concrete Example

> How could we create an RNN to do this?

Q: What information should be captured in the "hidden" state?
A: Previous input and current value for x.
![lecture_7, 页面 29](files/slides/CS231n/lecture_7.pdf#page=29)

$W_{xh}x_t$: Right hand term $x=0 -> [0, 0, 0] ; x=1 -> [1, 0, 0];$
$W_{hh}h_{t-1}$:  we can see w_hh in code is `np.array([[0,0,0],[1,0,0],[0,0,1]])`.
`[0,0,0]` : 0 for top row of left term (only use value from right term)，这个值设置的意义是，
隐藏状态 h_t 的第一个元素（代表“当前输入值”）完全不受过去任何信息（h_{t-1}）的影响，它的值只由当前输入 x_t 决定。
`[1,0,0]`: Copy over "current" value from previous hidden state to be "previous"
将h_{t-1}中第一行代表"current"复制到当前h_t中的第二行，将移至h_t中代表"previous"的第二行。
`[0,0,1]`:Keep 1 on the bottom (helpful for output)

将$W_{yh}$设置为`[1,1,-1]`,其与h_t dot product，加上ReLU函数，则有结果:$y_t = Max(Current + Previous – 1, 0)$

> 效果看上去不错！不过这些W是人工设定的，在实践中，我们要怎么找到这些Weight Matrix呢？

![lecture_7, 页面 36](files/slides/CS231n/lecture_7.pdf#page=36)

---
## RNN computational graph : Find W

> Re-use the same weight matrix at every time-step

这里还有[Many to One](files/slides/CS231n/lecture_7.pdf#page=43)以及[One to Many](files/slides/CS231n/lecture_7.pdf#page=43)的情况。One to Many情况中填充x输入序列可以用全0或是y_{t-1}。
![lecture_7, 页面 43](files/slides/CS231n/lecture_7.pdf#page=43)

>  Backpropagation through time

If you have an extremely long input sequence, you need to keeping the activations and the gradients at each time ==in memory== and then summing them all together.
This is going to be ==extremely large memory cost== as your input sequence increases!
![lecture_7, 页面 50](files/slides/CS231n/lecture_7.pdf#page=50)

> Run forward and backward through chunks of the sequence instead of whole sequence

当然，这是一种妥协，如果memory够用，肯定还是上面的方法更好。
![lecture_7, 页面 51](files/slides/CS231n/lecture_7.pdf#page=51)

在**前向传播**时，RNN 会完整地处理序列，让信息（hidden state）尽可能地向后流动，以维持长期的记忆。
在**反向传播**时，为了节省计算和内存，并缓解梯度问题，我们只将梯度截断在最近的 k 个时间步内进行传播和更新。
![lecture_7, 页面 52](files/slides/CS231n/lecture_7.pdf#page=52)

只有Single output的则把loss累计起来，只在最后一步进行计算。
反向传播同样会被截断，只会向后传播k步。
![lecture_7, 页面 54](files/slides/CS231n/lecture_7.pdf#page=54)

具体的RNN中的Weight Matrix的更新过程，请去本节中的[LSTM:Long Short Term Memory](RNN%20and%20LSTM.md#LSTM%20Long%20Short%20Term%20Memory)中浏览详细内容。

---
## Character-level Language Model

Time step wise classification based on softmax.
![lecture_7, 页面 61](files/slides/CS231n/lecture_7.pdf#page=61)

> Embedding layer

Embedding layer is better to have vectors as input to our models.And you can learn what these embedding layers are too.We tend to favor spread out  weights in genearl when we are trying to learn these.
So you can initialize your embedding layer to this small zero values with something like Kaiming initialization.
And then you are just looking at one row of it at a time as your input vector , rather than it being a number as input.
How you would have to represent that is basically a one with a bunch of zeros and optimization is only the embedding works better.

嵌入层是更好的，它让我们可以用向量作为模型的输入。并且，这些嵌入层本身的内容也是可以学习的。
当我们学习embedding时，我们通常偏好权重分布得更散开一些。所以你可以用类似 Kaiming 初始化这样的方法，将你的嵌入层初始化为接近于零的小数值。
然后，你每次只是把（嵌入矩阵的）其中一行作为你的输入向量，而不是用一个数字作为输入。相当于把嵌入层当做一个巨大的查找表。
如果你不得不用（传统方法one-hot）来表示它，那基本上就是一个1和一堆0，而从优化的角度来看，只有嵌入层才能更好地工作。更重要的是，稠密的嵌入向量使得梯度能够有效地传播，让模型能够学习到单词之间的语义关系。

![lecture_7, 页面 62](files/slides/CS231n/lecture_7.pdf#page=62)

[随着多轮的训练](files/slides/CS231n/lecture_7.pdf#page=65),我们也可以看到效果在逐渐变好。
这里也推荐[Andrej Karpathy](https://karpathy.github.io/)的文章：[RNN的有效性]https://karpathy.github.io/2015/05/21/rnn-effectiveness/

---
# LSTM:Long Short Term Memory

但是事实上，大部分人使用并训练的是LSTM，而非Vanilla RNN。

## RNN的缺点

这里hidden state中反向传播的过程以及推导出的h_t相对于h_{t-1}的梯度。
![lecture_7, 页面 99](files/slides/CS231n/lecture_7.pdf#page=99)

> 最终公式中连绵不绝的梯度相乘会引来一个问题..

[tanh'](files/slides/CS231n/lecture_7.pdf#page=104&selection=17,0,17,7)的最大值小于1，所以最后会导致梯度消失(vanishing gradient)问题。

![lecture_7, 页面 103](files/slides/CS231n/lecture_7.pdf#page=103)

我们可以不引入非线性，或者使用没有tan函数缺点的其他激活函数，但这无济于事，因为还有$W_{hh}$的连乘。
只要$W_{hh}$的最大奇异值大于1或小于1，终究还是会有梯度爆炸或是梯度消失的问题。
大于1的情况下，我们可以粗暴地直接通过设置阈值来防止梯度爆炸。
但是如果要解决Largest singular value < 1: Vanishing gradients的问题，我们就得更改RNN的架构。

![lecture_7, 页面 107](files/slides/CS231n/lecture_7.pdf#page=107)

## LSTM

这里有一篇很好的[材料](https://colah.github.io/posts/2015-08-Understanding-LSTMs/)可以用来理解LSTM。
![lecture_7, 页面 110](files/slides/CS231n/lecture_7.pdf#page=115)

非常精巧的设计!

LSTM 通过cell state `c_t` 的通道来进行梯度更新，梯度主要通过简单的逐元素乘法和加法进行传播，避免了标准RNN中那种反复与同一个权重矩阵 `W` 相乘导致的梯度消失/爆炸问题。

*   `c_{t-1}` -> `c_t` : 这是Cell State，是 LSTM 的记忆核心。信息可以在上面长期保留。
*   **`i, f, g, o`**: 这四个字母分别代表**输入门 (input) i**、**遗忘门 (forget) f**、**候选记忆 g** 和**输出门 (output) o**。它们的值都是通过 `W` 计算出来的，并通过 Sigmoid (`σ`) 或 `tanh` 激活函数得到。
*   **`⊙` 和 `+`**: 分别代表逐元素乘法 (element-wise multiplication) 和逐元素加法 (element-wise addition)。


*   **第二行 `c_t = f ⊙ c_{t-1} + i ⊙ g`**: 
    *   `f ⊙ c_{t-1}`: 用**遗忘门 `f`** 逐元素地乘以旧的cell state `c_{t-1}。`f`的值在0到1之间，决定了要“忘记”多少旧信息。
    *   `i ⊙ g`: 用**输入门 `i`** 逐元素地乘以**候选记忆 `g`**。`i` 决定了要“写入”多少新信息。
    *   `+`: 将“部分忘记后的旧信息”和“部分写入的新信息”加起来，形成新的cell state `c_t`。
*   第三行 `h_t = o ⊙ tanh(c_t)`: 这是hidden state的更新公式。它由输出门 `o` 控制，决定从cell state `c_t` 中提取多少信息作为当前时间步的输出。

> **"Backpropagation from c_t to c_{t-1} only elementwise multiplication by f, no matrix multiply by W"**
> （从 `c_t` 到 `c_{t-1}` 的反向传播，只涉及到与遗忘门 `f` 的逐元素乘法，没有与 `W` 的矩阵乘法）

*   根据链式法则，当梯度从 `c_t` 反向传播到 `c_{t-1}` 时，它需要乘以局部梯度 `∂c_t / ∂c_{t-1}`。
*   从公式中我们可以看出，这个局部梯度就是**遗忘门 `f`**。

---
**为什么这能解决梯度消失？**

1.  **没有 `W` 的连乘**: 梯度在沿着cell state反向传播时，全绕开了那个会导致梯度消失/爆炸的 `W` 矩阵连乘。
2.   在 `c_t = ... + ...` 这个加法节点，梯度在反向传播时会被**原封不动地**传递过去（加法门的梯度是1）。
3.  **遗忘门 `f` 的动态控制**: 梯度在每个时间步会乘以一个不同的遗忘门 `f`。`f` 的值是通过 `sigmoid` 计算的，在0到1之间。
    *   如果网络学会了要**记住**某个重要的早期信息，它会让对应的 `f` 在很多时间步里都**接近于 1**。
    *   当梯度乘以一个接近1的值时，它几乎**不会衰减**，可以顺畅地传播很长的距离。
    *   只有当网络决定要**忘记**某个信息时（`f` 接近0），这条梯度路径才会被关闭。



![lecture_7, 页面 117](files/slides/CS231n/lecture_7.pdf#page=117)

LSTM至少表现的很出色，虽然其并没有保证解决了梯度爆炸或是消失的问题。但是其至少提供了训练较长的RNN的方法。
![lecture_7, 页面 119](files/slides/CS231n/lecture_7.pdf#page=119)

And one thing could be cool is this idea of directly adding outputs and skipping some activation functions and other layers is actually high related to the idea of ResNets.ResNets have these skip connections.
ResNets使训练层数变深，LSTM使time step可以更长。
![lecture_7, 页面 121](files/slides/CS231n/lecture_7.pdf#page=121)

RWKV,Mamba... 都是很有价值的工作。
![lecture_7, 页面 122](files/slides/CS231n/lecture_7.pdf#page=122)