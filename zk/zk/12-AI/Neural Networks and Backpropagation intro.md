# Neural Networks and Backpropagation

## Neural Network

神经网络通过引入非线性激活函数（如 ReLU），将简单的线性分类器升级为了能够学习更复杂特征的层级计算模型。
我们构建了一个2层神经网络 f = W₂ max(0, W₁x)。
- 第一层 W₁x: 还是线性变换，它从原始输入 x 中提取出一组初级特征 h(templates)。
- max():它引入了非线性，让模型能学习更复杂的组合关系，而不只是一条直线。
- 第二层 W₂(...): 在第一层提取的非线性特征 h(templates) 的基础上，再次进行线性变换，最终得到分类分数 s。

通过在两次线性变换之间插入一个非线性激活函数，神经网络获得了强大的特征学习能力，远超简单的线性模型。

![lecture_4, 页面 28](files/slides/CS231n/lecture_4.pdf#page=29)

我们通过激活函数来引入非线性，这里的`max(0,x)`便相当于激活函数。
如果不引入非线性，那么最后化为的形式还是线性的。
So , we need some sort of non-linearity in the middle of neural net work to be able to give us the power to solve non-linear problem.
![lecture_4, 页面 31](files/slides/CS231n/lecture_4.pdf#page=31)

激活函数有很多种，按需选择，这里有一些原理解释:[Sigmoid & Relu & Gelu](CNN.md#Sigmoid%20&%20Relu%20&%20Gelu)

> [!question] How would we choose for a new problem which of these activation functions to use?
> Actually , it's **empirical** in most cases. But we often start with value , or we go with standard activation functions being used for those specific architectures. There are some activation functions that are commonly used in CNN , or in transformer, and different architectures.  

![lecture_4, 页面 32](files/slides/CS231n/lecture_4.pdf#page=32)

---
### Example of NN

一般来说，more neurons = more capacity = better performance
![lecture_4, 页面 34](files/slides/CS231n/lecture_4.pdf#page=34)


> [!question] Why is the model more underfitting when we increase the value of lambda here?
> The value of lambda is controlling how much contribution the regularizer should have in the overall loss.
> And the larger contribution that you have on the regularizer and remember that regularizer was defined on $W$.
> So it constrains the $W$. It's giving less freedom to the values on $W$.
> So less freedom equals a little bit more generic boundaries, not necessarily giving you those detailed value.
> So if you constrains the model too much , even with the regularizer , it will not perform well.

> Do not use size of neural network as a regularizer

![lecture_4, 页面 41](files/slides/CS231n/lecture_4.pdf#page=41)

> [!question] Why shoule we not choose the size of NN as a regularizer?
> In networks , we often start increasing the number of parameters, until we see some levels of overfitting.
> That's the time we know that the network is actually understanding the patterns in the data and is now able to mermorize the data. And that's the time we try to minimize the overfitting  by regularizing the network. 
> So regularization play an important factor there.
> So if we go too high on the number of parameters and complexity of NN, then that's going to be causing a problem.

---
### Biological Neurons Inspire

> Be very careful with your brain analogies!

Biological Neurons: 
- Many different types 
- Dendrites can perform complex non-linear computations 
- Synapses are not a single weight but a complex non-linear dynamical system

![lecture_4, 页面 45](files/slides/CS231n/lecture_4.pdf#page=45)

Biological Neurons are Complex connectivity patterns, common architectures can not implement like it.
But neural networks with random connections can [work](files/slides/CS231n/lecture_4.pdf#page=47) too!
![lecture_4, 页面 45](files/slides/CS231n/lecture_4.pdf#page=46)

---
## Backpropagation

> Plugging in neural networks with loss functions

直接计算这一整个函数的$\nabla L$非常复杂，而且有不少缺点

![lecture_4, 页面 51](files/slides/CS231n/lecture_4.pdf#page=51)


> Better idea:Computational graphs + Backpropagation

[CNN](files/slides/CS231n/lecture_4.pdf#page=53)就有类似的架构
![lecture_4, 页面 52](files/slides/CS231n/lecture_4.pdf#page=52)

> [!question] 为什么在反向传播中计算梯度？
> 如果要得到一个输出$L$相对于 k 个不同的输入变量$w_i$ 的导数，通常需要进行 k 次独立的前向计算。
> 同理，如果是反向传播，那么m个输出变量就需要m次计算。
> 对于神经网络优化**这种“单输出（损失），多输入（参数）”**的场景，一次正向+一次反向计算的成本要小的多
使用链式法则来计算损失函数针对输入变量的梯度，并进行参数的更新

我们最终的目标是计算**损失函数 L** 相对于网络中**每个参数 $w_i$** 的偏导数 $∂L/∂w_i$
我们仍然需要正向计算去获得中间值和最终的值L来帮助反向传播计算梯度。
![](../../../files/images/AI/12-b-3-4.png)

![lecture_4, 页面 71](files/slides/CS231n/lecture_4.pdf#page=72)

UpStream gradient上游来的反向信息+自身算出的local gradient
计算结点无需关心整个计算图的结构或是其他的什么宏观问题，它只需要专注计算就好
![lecture_4, 页面 78](files/slides/CS231n/lecture_4.pdf#page=78)


当然，计算图的构造不是唯一的。像[这个例子](files/slides/CS231n/lecture_4.pdf#page=79)也可以使用Sigmoid函数来简化计算图
毕竟Sigmoid的local gradient是比较简洁优雅的
![lecture_4, 页面 98](files/slides/CS231n/lecture_4.pdf#page=98)

> Patterns in gradient flow 反向传播的一些基本模式

1. 加法门 (Add Gate): 像个分发器，把梯度原样复制给所有输入。
2. 乘法门 (Mul Gate): 像个交换器，把梯度乘以“另一个”输入的值再传回去。
3. 复制门 (Copy Gate): 像个累加器，把所有分支传回的梯度加起来。
4. Max门 (Max Gate): 像个路由器，只把梯度传给前向传播时值最大的那个输入，其他输入梯度为0。

梯度在网络中反向传播时，会根据每个运算的数学性质，被相应地分配、缩放、聚合或路由。
![lecture_4, 页面 102](files/slides/CS231n/lecture_4.pdf#page=102)

所以整个过程是先做一遍前向传播，再去计算一遍反向传播
Pytorch中有很多已经封装好的[API](files/slides/CS231n/lecture_4.pdf#page=110),这是Pytorch sigmoid layer的[内部实现](files/slides/CS231n/lecture_4.pdf#page=114)。
![lecture_4, 页面 104](files/slides/CS231n/lecture_4.pdf#page=103)


---
## What about vector-valued functions?

 在深度学习中，多元函数通常是**复合的（composite）**，幸运的是，链式法则可以被用来微分复合函数。
让我们先考虑单变量函数。假设函数y=f(u)和u=g(x)都是可微的，根据链式法则有：
$$
\frac{dy}{dx} = \frac{dy}{du} \frac{du}{dx}.
$$


现在考虑一个更一般的场景，即函数具有任意数量的变量的情况。 假设可微分函数$y$有变量$u_1,u_2...u_m$，其中每个可微分函数$u_i$都有变量$x_1...x_n$。

则注意，$y$是$x_1...x_n$的函数。对于任意$i=1,2...n$，链式法则有：

$$
\frac{\partial y}{\partial x_i} = \frac{\partial y}{\partial u_1} \frac{\partial u_1}{\partial x_i} + \frac{\partial y}{\partial u_2} \frac{\partial u_2}{\partial x_i} + \cdots + \frac{\partial y}{\partial u_m} \frac{\partial u_m}{\partial x_i}
$$

![lecture_4, 页面 118](files/slides/CS231n/lecture_4.pdf#page=118)

> Backprop with Vectors

最终的损失L是一个标量
**∂L/∂z**就是上游梯度Upstream gradient。是最终损失 L 对向量 z 中**每一个元素**的偏导数。维度$D_z$和 z 的维度相同。

**∂z/∂x** 和 **∂z/∂y**就是局部梯度local gradient，它们都是**雅可比矩阵 (Jacobian matrices)**。它们只描述了函数 f 自身的特性
**∂z/∂x** (维度 $[D_x * D_z]$): 描述了输出向量 z 的**每一个元素**是如何受到输入向量 x 的**每一个元素**影响的。矩阵的第 (i, j) 个元素是 $∂z_j / ∂x_i$。
**∂z/∂y **(维度 $[D_y * D_z]$): 同理，描述了 z 和 y 之间的关系。

所以同理，最后的**∂L/∂x**与**∂L/∂y**做一个Matrix-vector乘法即可。

![lecture_4, 页面 125](files/slides/CS231n/lecture_4.pdf#page=125)

在下方这个例子中，input维度和output维度都为4，即$D_x=D_z=4$，所以Jacobian矩阵为4\*4的矩阵。
这个雅可比矩阵是稀疏的：非对角线上的元素永远为零！
所以不要显式地构建出完整的雅可比矩阵（太占空间）——而是使用下面的隐式乘法来代替$\frac{\partial L}{\partial x}$的计算过程。
$$

\left( \frac{\partial L}{\partial x} \right)_i = 
\begin{cases} 
    \left( \frac{\partial L}{\partial z} \right)_i & \text{if } x_i > 0 \\
    0 & \text{otherwise}
\end{cases}

$$

![lecture_4, 页面 132](files/slides/CS231n/lecture_4.pdf#page=132)

---
## What about Tensors?

同理，计算的时候注意维度要对齐
![lecture_4, 页面 137](files/slides/CS231n/lecture_4.pdf#page=137)

Jacobians: $dy/dx: [(N×D)×(N×M)] dy/dw: [(D×M)×(N×M)]$ 
For a neural net we may have N=64, D=M=4096 Each Jacobian takes ~256 GB of memory! Must work with them implicitly!
这里的矩阵计算有误，结果应当为[17, 11,  8, -6],[ 5,  2, 11,  7]。不过无伤大雅
![lecture_4, 页面 144](files/slides/CS231n/lecture_4.pdf#page=144)

所以，不使用jacobian矩阵的公式方法为：
These formulas are easy to remember: they are the only way to make shapes match up!

$$
\begin{array}{c}
[N \times D] \ [N \times M] \ [M \times D] \\
\boxed{
    \frac{\partial L}{\partial x} = \left( \frac{\partial L}{\partial y} \right) w^T
}
\end{array}
\qquad
\begin{array}{c}
[D \times M] \ [D \times N] \ [N \times M] \\
\boxed{
    \frac{\partial L}{\partial w} = x^T \left( \frac{\partial L}{\partial y} \right)
}
\end{array}
$$


