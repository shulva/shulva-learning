# Regularization and Optimization

### Regularization intro

> Regularization is to do worse on the training data but better on the test data or just unseen data

f1 is overfit , f2 is doing better on unseen data.
![lecture_3, 页面 15](files/slides/CS231n/lecture_3.pdf#page=15)

> Occam's Razor: Among multiple competing hypotheses, the simplest is the best, William of Ockham 1285-1347

Why regularize? 
- Express preferences over weights 
- Make the model simple so it works on test data 
- Improve optimization by adding curvature

![lecture_3, 页面 19](files/slides/CS231n/lecture_3.pdf#page=19)

L2会使小于1的数更小，而且L2会引入curvature（曲度），从而更容易优化
当然，并不一定非要使模型简化，性能才是我们必须要关注的

图中答案是same
![lecture_3, 页面 23](files/slides/CS231n/lecture_3.pdf#page=23)

所以，我们有如下的形式：
![lecture_3, 页面 23](files/slides/CS231n/lecture_3.pdf#page=25)


## Optimiazation intro

优化（optimization）可以称为用模型拟合观测数据的过程
所以，我们需要找到尽可能使Loss变小的参数$W$

> 策略1：随机寻找参数

15.5% accuracy! not bad! (SOTA is ~99.7%) (not bad在哪我请问了)
```python
# assume X_train is the data where each column is an example (e.g. 3073 x 50,000)
# assume Y_train are the labels (e.g. 1D array of 50,000)
# assume the function L evaluates the loss function

bestloss = float("inf") # Python assigns the highest possible float value
for num in xrange(1000):
  W = np.random.randn(10, 3073) * 0.0001 # generate random parameters
  loss = L(X_train, Y_train, W) # get the loss over the entire training set
  if loss < bestloss: # keep track of the best solution
    bestloss = loss
    bestW = W
  print 'in attempt %d the loss was %f, best %f' % (num, loss, bestloss)

# prints:
# in attempt 0 the loss was 9.401632, best 9.401632
# in attempt 1 the loss was 8.959668, best 8.959668
# in attempt 2 the loss was 9.044034, best 8.959668
# in attempt 3 the loss was 9.278948, best 8.959668
# in attempt 4 the loss was 8.857370, best 8.857370
# in attempt 5 the loss was 8.943151, best 8.857370
# in attempt 6 the loss was 8.605604, best 8.605604
# ... (truncated: continues for 1000 lines)
```

> 策略2：follow the gradient

![lecture_3, 页面 32](files/slides/CS231n/lecture_3.pdf#page=32)

通过数值的方法（加上一个很小的h）去计算梯度是比较慢的，而且只是一个近似的解

> - Numerical gradient: approximate, slow, easy to write
> - Analytic gradient: exact, fast, error-prone
> - In practice: Always use analytic gradient, but check implementation with numerical gradient. This is called a gradient check.

![lecture_3, 页面 39](files/slides/CS231n/lecture_3.pdf#page=42)

我们通过计算当前损失函数L对于其参数$W$的梯度，从而不停地更改参数，最终最小化损失函数值

## 梯度

我们可以连结一个多元函数对其所有变量的偏导数，以得到该函数的梯度（gradient）向量。

设函数$f:\mathbb{R}^n\rightarrow\mathbb{R}$的输入是 一个$n$维向量$\mathbf{x}=[x_1,x_2,\ldots,x_n]^\top$，并且输出是一个标量。

则，函数$f(x)$相对于$x$的梯度是一个包含$n$个偏导数的向量:
$$
\nabla_{\mathbf{x}} f(\mathbf{x}) = \bigg[\frac{\partial f(\mathbf{x})}{\partial x_1}, \frac{\partial f(\mathbf{x})}{\partial x_2}, \ldots, \frac{\partial f(\mathbf{x})}{\partial x_n}\bigg]^\top
$$

例如：$\nabla_{\mathbf{x}} \|\mathbf{x} \|^2 = \nabla_{\mathbf{x}} \mathbf{x}^\top \mathbf{x} = 2\mathbf{x}$

同样，对于任何矩阵$\mathbf{X}$，都有$\nabla_{\mathbf{X}} \|\mathbf{X} \|_F^2 = 2\mathbf{X}$。

> [!NOTE] proof
>  $有f(x) =\|\mathbf{x} \|^2 = x^T x = \sum_{i=1}^{n}  x_i^2$
>
>  $有∂f/∂x_i = 2x_i$
>
> $则有[∂f/∂x_1,∂f/∂x_2...∂f/∂x_i]=2[x_1,....x_i]=2\mathbf{x}$

![](../../../files/images/AI/12-b-2-1.png)

> [!NOTE] 分子布局
> 上图中所采用的是分子布局，即**导数的形状主要由分子（被求导的函数 y）的维度结构决定**，同理对应的有分母布局。
> 可以将其看作：标量 y 的结构是 (1,)并且列向量 x 的结构是 (n,1)。为了**匹配**分子的输出方式，∂$\mathbf{y}$/∂x 的维度在结果中表现为 (1,n)。

## 随机梯度下降-Stochastic Gradient Descent

所以，一般的梯度下降如下：

```python
while Ture:
	weights_grad = evaluate_gradient(loss_fun,data,weights)
	weights += - step_size * weights_grad #perform parameter updat
```

> If we calculate all , it costs a lot. So we can use sgd
> the reason why it is called sgd because we are sampling a random subset of our data

每次循环都只随机地取一小部分数据
![lecture_3, 页面 48](files/slides/CS231n/lecture_3.pdf#page=48)

当然，SGD也存在着潜在的问题

> 1.损失函数在不同方向上的曲率差异巨大
> 其在平缓的维度上进展极其缓慢，在陡峭的维度上来回震荡

![lecture_3, 页面 51](files/slides/CS231n/lecture_3.pdf#page=51)

补充：损失函数具有很高的condition number：即海森矩阵的最大奇异值与最小奇异值之比很大。
这在数学上意味着该函数在不同方向上的弯曲程度（曲率）差异极大，其几何形状是一个狭长的椭圆形山谷。

> 2. 如果损失函数存在局部最小值或鞍点，则梯度为零，梯度下降被困住了

saddle point的直观表现：[鞍点](files/slides/CS231n/lecture_3.pdf#page=53)
Saddle points much more common in high dimension.
当然，这些问题并非sgd所独有，其他使用梯度下降的算法也会有这样的问题。
![lecture_3, 页面 53](files/slides/CS231n/lecture_3.pdf#page=53)

## SGD + Momentum

> 3.梯度下降的过程中，由于sgd只取了一部分数据，所以sgd下降的过程中会有很多noise，具体表现为下降过程中并不是直接的往minimum的方向走，而是会往其他的方向走。这也会拖慢到达最优解的速度

You may see SGD+Momentum formulated different ways, but they are equivalent - give same sequence of x
有点类似惯性作用
至于[Nesterov Momentum](files/slides/CS231n/lecture_3.pdf#page=100&selection=20,0,20,8)，了解一下即可，毕竟后面介绍的Adam才是主流。

> [!NOTE] 公式比较
> 标准sgd下一步的位置完全由梯度决定
> 
> SGD+Momentum引入了一个新变量 v，代表速度 (velocity)。
> 新的速度 v_{t+1} 是由两部分组成的：
> - ρ * v_t：一部分是衰减后的旧速度。ρ (rho) 是一个摩擦系数，它让旧的速度随时间衰减。
> - ∇f(x_t)：另一部分是当前梯度，它提供了新的加速度。
> 参数 x 不再直接用梯度更新，而是用新的速度 v 来更新。

![lecture_3, 页面 60](files/slides/CS231n/lecture_3.pdf#page=60)

---
## RMSProp

> 基于每个维度上历史梯度平方和（带衰减）来对梯度进行逐元素缩放

Per-parameter learning rates" or "adaptive learning rates
其认为**不同参数（维度）应该有不同的学习率**。它通过调整更新公式的**分母**项，来为每个参数自适应地调整学习率。

![lecture_3, 页面 62](files/slides/CS231n/lecture_3.pdf#page=62)

> [!NOTE] 讲解
> *   **引入变量**: `grad_squared`
>     *   这个变量用于**累积过去梯度值的平方**。它的大小反映了最近这个参数的梯度大小
> 
> *   **关键代码行分析**:
>     1.  `grad_squared = decay_rate * grad_squared + (1 - decay_rate) * dx * dx`
>         *   这一行在更新 `grad_squared` 这个累积量。它是一个**指数衰减移动平均**，和 Momentum 里的速度更新非常相似。
>         *   `dx * dx`：这是当前梯度的**逐元素平方**。
>             *   如果某个参数的梯度 `dx` **一直很大**，那么 `grad_squared` 的对应值也会**累积得很大**。
>             *   如果某个参数的梯度 `dx` **一直很小**，那么 `grad_squared` 的对应值也会**保持很小**。
> 
>     1.  `x -= learning_rate * dx / (np.sqrt(grad_squared) + 1e-7)`
>         *   这是参数更新的核心。标准的更新步长 `learning_rate * dx` 被 `(np.sqrt(grad_squared) + 1e-7)` 除了。
>         *   `np.sqrt(grad_squared)`：对累积的梯度平方和开方，是 RMSProp 名字的来源（**R**oot **M**ean **S**quare Prop）。
>         *   `+ 1e-7`：用来防止分母为零。
>         *   **直观理解**:
>             *   当 `grad_squared` **很大**时（意味着历史梯度很大），分母就很大，这会**减小**实际的更新步长。
>             *   当 `grad_squared` **很小**时（意味着历史梯度很小），分母就很小，这会**增大**实际的更新步长。
> 
> ---
> ##### Progress along “steep” directions is damped; progress along “flat” directions is accelerated
> 
> 1.  **陡峭方向**:
>     *   这个方向的梯度 `dx` **一直很大**。
>     *   因此，`grad_squared` 在这个维度上的值会**迅速累积得非常大**。
>     *   在更新时，大的 `grad_squared` 会导致一个**很大的分母**，从而**有效减小**了这个方向上的学习率。
>     *   **效果**：抑制了在陡峭方向上的剧烈震荡。
> 
> 1.  **平缓方向**:
>     *   这个方向的梯度 `dx` **一直很小**。
>     *   因此，`grad_squared` 在这个维度上的值会**保持很小**。
>     *   在更新时，小的 `grad_squared` 会导致一个**很小的分母**，从而**有效增大**了这个方向上的学习率。
>     *   **效果**：加速了在平缓方向上的前进速度。

---
## Adam And AdamW

> Adam结合了两者的思想

Adam (Adaptive Moment Estimation) 优化器同时维护了两种历史信息：
1. **一阶矩估计 (First Moment Estimation)**：这本质上就是**梯度的指数移动平均**，也就是 **Momentum** 的核心思想。它告诉我们梯度的平均方向和大小。
2. **二阶矩估计 (Second Moment Estimation)**：这是**梯度平方的指数移动平均**，也就是 **RMSProp** 的核心思想。它告诉我们梯度的大小（或者说方差?）。

通过结合这两者，Adam 既能像 Momentum 一样利用惯性，又能像 RMSProp 一样为每个参数自适应地调整学习率。

![lecture_3, 页面 70](files/slides/CS231n/lecture_3.pdf#page=70)

> [!question] un_bias的作用
> 
> ```python
> first_unbias = first_moment / (1 - beta1 ** t)
> second_unbias = second_moment / (1 - beta2 ** t)
> ```
> 
> 这是 Adam 引入的一个重要修正步骤。
>     
> - 为什么需要修正？ 因为 `first_moment 和 second_moment`初始化为0。在训练刚开始时（t 很小），它们的计算值会偏向于0。
> - 分析: 随着 t 增大，`beta1 ** t 和 beta2 ** t` 会趋近于0，分母会趋近于1，这个修正项的作用会逐渐消失。它主要在训练初期发挥作用。

---

正则化与自适应优化器是如何相互作用的?这事实上取决于你如何设置

Adam 将权重惩罚和梯度混在一起处理，导致惩罚效果受到自适应学习率的干扰。
AdamW 将权重惩罚和梯度分开处理，使得惩罚更加直接和有效。
因此，AdamW 通常能获得比 Adam 更好的训练效果和模型泛化能力

![lecture_3, 页面 76](files/slides/CS231n/lecture_3.pdf#page=76)


## Learning Rates

如下代码中`step_size`便相当于是学习率
```python
while Ture:
	weights_grad = evaluate_gradient(loss_fun,data,weights)
	weights += - step_size * weights_grad 
```

![lecture_3, 页面 79](files/slides/CS231n/lecture_3.pdf#page=79)

事实上我们可以在训练过程中调整学习率,如下是多种调整学习率的方法：Step,Cosine,Liner,Inverse sqrt,Linear Warmup...
具体可以去slides中看具体的学习率曲线是长什么样的，在此不赘述

![lecture_3, 页面 84](files/slides/CS231n/lecture_3.pdf#page=84)

---
## Hessian optimize

如下是使用梯度和hessian进行梯度下降的对比

![lecture_3, 页面 88](files/slides/CS231n/lecture_3.pdf#page=87)

second-order同时使用一阶导数（梯度）和二阶导数（海森矩阵）信息，更精确

![lecture_3, 页面 88](files/slides/CS231n/lecture_3.pdf#page=88)

但事实上，deep learning基本不用这种方法。根本原因在于其巨大的计算和存储开销

- N = (Tens or Hundreds of) Millions:
    - 对于现代的深度神经网络，模型总参数量N 的值达到数千万甚至数亿是非常普遍的。
- Hessian has O(N²) elements:
    - Hessian矩阵包含的元素数量是 N²。
    - 问题一（存储）: 仅仅是存储这个海森矩阵就需要海量的内存
- Inverting takes O(N³):
    - 牛顿法的更新公式需要计算海森矩阵的逆矩阵 H⁻¹。
    - 矩阵求逆是一个计算量非常大的操作，其时间复杂度大约是 O(N³)。
    - 问题二（计算）: 在每次参数更新时都计算一次矩阵的逆，这个计算时间是完全无法接受的。
	
![lecture_3, 页面 90](files/slides/CS231n/lecture_3.pdf#page=90)

当然，也有[BFGS和L-BFGS](files/slides/CS231n/lecture_3.pdf#page=112&selection=12,0,12,6)这样减少计算与存储成本的方法（计算从N\^3->N\^2,存储从N\^2->1）
但是L-BFGS只在全批量的场景下表现很好，在minbatch的场景下表现不佳，所以还是很少用

---
## Looking Ahead : Neural Networks

>  How to optimize more complex functions?

![lecture_3, 页面 96](files/slides/CS231n/lecture_3.pdf#page=96)

对于很多问题，我们需要引入非线性！
现实世界中的很多问题，用直线是无法解决的。
比如下图，我们通过一个**非线性变换**（这里是从笛卡尔坐标 (x, y) 变成极坐标 (r, θ)），把数据映射到一个新的空间。在新的空间里，数据变得可以用一条**直线**分开了。

在神经网络中，**激活函数（Activation Function）** 就扮演了这个非线性变换的角色。它能把数据映射到一个新的空间，使得原本线性不可分的问题，在高维空间中变得线性可分。没有非线性激活函数，再多层的神经网络也只相当于一个单层的线性模型，无法解决复杂问题。

![lecture_3, 页面 95](files/slides/CS231n/lecture_3.pdf#page=95)