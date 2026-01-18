# 监督学习

![](Machine%20Learning%20intro.md#^supervised-learning)

## intro

> Image Classification: A core task in Computer Vision

![lecture_2, 页面 8](files/slides/CS231n/lecture_2.pdf#page=8)

但是对于机器来说，其存在着诸多挑战：Viewpoint variation(All pixels change when the camera moves!) , Illumination, Background Clutter , Occlusion , Deformation , Intraclass variation , [Context]([lecture_2, 页面 15](files/slides/CS231n/lecture_2.pdf#page=15&selection=17,0,17,7))...

我们需要的图像分类器至少现在没有什么可以硬编码的算法来进行识别。前人也做过努力（例如使用边缘检测识别物体，但难以泛化）

> Unlike e.g. sorting a list of numbers, no obvious way to hard-code the algorithm for recognizing a cat, or other classes.

```python
def classify_image(image):
	#some magic here?
	return class_label
```

> Data-Driven Approach

![lecture_2, 页面 19](files/slides/CS231n/lecture_2.pdf#page=19)

## K Nearest Neighbor

> First classifier: Nearest Neighbor

```python
def train(images,labels): # Memorize all data and labels
	#ML!
	return model

def predict(model,test_images): # Predict the label of the most similar training image
	return test_labels
```

![lecture_2, 页面 23](files/slides/CS231n/lecture_2.pdf#page=23)

**Q: With N examples, how fast are training and prediction?**  
**A: Train O(1), predict O(N)**
- **训练 O(1)：** 极快。因为只是拷贝数据进内存，不进行计算。
- **预测 O(N)：** **极慢。** 如果你有 100 万张训练图。每预测一张新图，你就必须做 100 万次减法运算。
    
**This is bad: we want classifiers that are fast at prediction; slow for training is ok.**  
（**这是坏事：** 我们希望分类器在预测时非常快，即使训练时很慢也没关系。）

```python
self.Xtr - X[i,:]
操作： 用训练矩阵 (N, 3072) 减去单个测试向量 (3072)。
NumPy 会自动把测试向量复制N次，叠成一个同样的矩阵，然后让训练集里的每一张图都跟这张测试图进行像素级的相减。
最后得到一个 (N, 3072) 的差值矩阵，代表每个像素的差异。

np.sum(..., axis = 1)
操作：把每个像素的差异加起来，汇总成这张图的总差异。
axis = k相当于把tensor的第k个维度通过求和消灭
我们要把一张图里的 3072 个像素差异加起来，这些像素排在同一行里，所以要沿着 axis=1 加。
最后得到一个形状为 (N) 的一维数组。数组里的第0个数，就是测试图和第0张训练图的距离。第k个数，就是和第k张训练图的距离。
```

```python
def train(self, X, y): # Memorize training data
    # the nearest neighbor classifier simply remembers all the training data
	# 这种方法下，一般会把图像的像素点变为一个vector，所以一般X的形式类似于(N,3072) 3072是像素点数目
    self.Xtr = X
    self.ytr = y

def predict(self, X):
	num_test = X.shape[0] # 获取测试图片的数量N
	Ypred = np.zeros(num_test,dtype=self.ytr.dtype)
	
    for i in xrange(num_test):
        # 1. 计算距离 (核心行)
        # 使用 L1 距离 (曼哈顿距离): 所有像素点绝对值差的和
        distances = np.sum(np.abs(self.Xtr - X[i,:]), axis = 1)
        
        # 2. 按最小值，找到最近的邻居
        min_index = np.argmin(distances) 
        
        # 3. 预测标签
        Ypred[i] = self.ytr[min_index]
```

> 当然，我们可以改变K的数值来调整算法，选用更多的周遭样本

![lecture_2, 页面 30](files/slides/CS231n/lecture_2.pdf#page=30)

> 同样，我们也可以改变distance的算法
> K数值和L1/L2对这个问题的影响可以[在此](http://vision.stanford.edu/teaching/cs231n-demos/knn/)体验。L1会倾向于方块/直角，L2则会倾向于圆弧/斜线

![lecture_2, 页面 32](files/slides/CS231n/lecture_2.pdf#page=32)

> [!question] 如果我旋转坐标轴，分类结果会变吗？
> - **L2 距离：不变。**
>     - 因为圆旋转了还是圆。不管你把坐标纸怎么转，两点之间的直线距离是不变的。
>     - 所以 L2 对坐标系的旋转不敏感（Rotation Invariant）。
>         
> - **L1 距离：会变！**
>     - 因为正方形旋转了就不是原来的正方形了。
>     - L1 距离严重依赖于你定义的坐标轴方向。这意味着如果你把原本的图片旋转了 45 度再喂给KNN，分类结果可能会完全不同。

## hyperparameters

So,What is the best value of k to use?What is the best distance to use?
These are **hyperparameters**: choices about the algorithms themselves.
==Very problem/dataset-dependent. Must try them all out and see what works best.==


We can take some part of the training data as validation set In Idea 3
==but sometimes validation set may not represent entire landscope because it is almost always much smaller==
so we have 4....
![lecture_2, 页面 40](files/slides/CS231n/lecture_2.pdf#page=40)

> [CIFAR10](files/slides/CS231n/lecture_2.pdf#page=44&selection=14,8,14,23)的实验可以用来举个选取超参数的例子

![lecture_2, 页面 41](files/slides/CS231n/lecture_2.pdf#page=41)

> 但是，像素层面的数学距离根本无法代表图像内容的真实含义

shifted在人类感官上应该没什么变化，Occluded和Tinted变了很多。但是在KNN眼里，他们都变化了很多
仅仅因为shift 1 pixel

![lecture_2, 页面 47](files/slides/CS231n/lecture_2.pdf#page=47)

## Linear Classifier

>  我们不再像 KNN 那样记忆图片，而是定义一个函数 $f(x, W) = Wx + b$ 来概括映射关系。

1.  **输入到输出：**
    *   **输入 ($x$)：** 将 32x32x3 的图片拉伸成一个 **3072维** 的长向量。
    *   **输出：** 经过计算得到 **10个分类得分**（对应10个类别，分越高代表越可能是该类）。
2.  **核心机制：**
    *   **$W$ (权重)：** 这是一个 10x3072 的矩阵。它负责==把像素空间映射到分类空间==
    *   **$b$ (偏置)：** 这是一个 10x1 的向量。它负责调整不同类别的基础门槛（比如如果训练集里猫很多，猫的偏置就会高）。

分类就是做一次**矩阵乘法**，把**像素数据**压缩成**分类得分**，所有的“知识”都存储在参数 **$W$** 和 **$b$** 里。

![lecture_2, 页面 53](files/slides/CS231n/lecture_2.pdf#page=53)

==W (权重矩阵) 和 b (偏置向量) 的每一行，都精确地对应一个分类的参数和偏置==

![lecture_2, 页面 58](files/slides/CS231n/lecture_2.pdf#page=58)

if we did not have the bias,all of these lines should have passed through the origin from the center of that space , which doesn't really make any sense.But with the bias , we can create more reliable functions and decision boundaries.

![lecture_2, 页面 61](files/slides/CS231n/lecture_2.pdf#page=61)

> hard to seperate! Because you a **linear** in space...

线性分类器在空间中只是一条直线，对于下面的分类问题无能为力...
![lecture_2, 页面 62](files/slides/CS231n/lecture_2.pdf#page=62)

> How to choose a good $W$?
> Define a loss function that quantifies our unhappiness with the scores across the training data.
> Come up with a way of efficiently finding the parameters that minimize the loss function. ([损失函数](12-c-1（线性回归）.md#损失函数) optimization)

![lecture_2, 页面 67](files/slides/CS231n/lecture_2.pdf#page=67)

# Softmax classifier

Softmax分类器得名于**softmax函数**，该函数用于将原始的类别分数压缩成总和为1的归一化正值，以便可以应用交叉熵损失。

 > **Softmax Loss（交叉熵损失）** 的计算,把无意义的scores变为prob，再算出模型的错误Loss

1.  **指数化 ($e^x$)：** 把得分变成正数，并拉大分差
2.  **归一化 (Normalize)：** 算出每个类别的百分比概率

这里的指数和归一化主要是应用Softmax变换，从而将分数变为一个有意义的概率分布。
而且Softmax函数是符合Multinominal Logistic Regression的。
Softmax分类器就是二元的逻辑斯谛回归（Logistic Regression）分类器在多类别问题上的泛化。

> [!NOTE] Why we are only using Softmax function?
> Softmax is great because it does a function which converts any set of floating point numbers into a probability  distribution where they will sum to 1. 
> And depending on the value of score, that will translate to the relative probability of that value.
> So if you have a really high positive number , and everything else is very low negative , you will have nearly 1 for Softmax and 0 is almost for the other values.
> So it is nice because it converts any lists of floating point numbers into a list of probability based on the values of lists.
> That's the main utility of Softmax.

> [!NOTE] Multinominal Logistic Regression
> Logistic Regression思想的核心在于：二分类事件输出的对数几率(log odds)是由输入$x$的线性函数表示的模型(统计学习方法6.1.2)
> 但是，如果不是二分类问题，而是多分类问题呢？
> 则，对于任意一个类别k以及基准类别K，我们有如下对数几率：
> $\log\left(\frac{P(y=k|x)}{P(y=K|x)}\right) = (W_k \cdot x + b_k) - (W_K \cdot x + b_K)$
> 可见，其仍为输入$x$的线性函数表示的模型。
> 核心思想没有改变，我们只是将二分类中的核心思想扩展到了多分类场景中

![lecture_2, 页面 75](files/slides/CS231n/lecture_2.pdf#page=75)

---

> [!NOTE] 详解
> 与SVM将输出 `f(xi, W)` 视为每个类别的（未经校准且可能难以解释的）分数不同，Softmax分类器给出的输出则稍微更直观一些（即归一化后的类别概率），并且它还有一个我们稍后会描述的概率论解释。
> 
> 在Softmax分类器中，映射函数 `f(xi; W) = W·xi` 保持不变，但我们现在将这些分数解释为每个类别的**未归一化对数概率**，并用==交叉熵损失（cross-entropy loss）来替代合页损失（hinge loss）==。
> 
> 交叉熵损失的形式如下：
> $L_i = -\log(p_{y_i}) = -\log\left(\frac{e^{f_{y_i}}}{\sum_{j=1}^{K} e^{f_j}}\right)$
> 
> 和之前一样，整个数据集的总损失是所有训练样本的 `Li` 的**平均值**，再加上一个**正则化项 R(W)**。
> 
> 函数$p_j = \sigma(\mathbf{f})_j = \frac{e^{f_j}}{\sum_{k=1}^{K} e^{f_k}}$被称为 **softmax 函数**：它接收一个包含任意实数值分数的向量，并将其压扁（squash）成一个所有值都在0到1之间且总和为1的向量。
> 
> ##### 信息论视角
> 一个真实分布 `p` 和一个估计分布 `q` 之间的**交叉熵**定义为：$H(p, q) = - \sum_{k} p(x) \log q(x)$
> 
> 因此，Softmax分类器是在最小化估计的类别概率（即我们上面看到的交叉熵损失中的参数）与“真实”分布之间的交叉熵。
> 在这个解释中真实分布是所有概率质量都集中在正确类别上的分布（即 `p = [0, 1, ..., 0]`，在第 `y_i` 个位置上为1）。
> 数学推导在此：[交叉熵](Linear%20Classification%20intro.md#交叉熵)
> 
> 此外，由于交叉熵可以写成熵和[KL散度](Linear%20Classification%20intro.md#KL散度)（Kullback-Leibler divergence）的形式：
> $H(p,q) = H(p) + D_{KL}(p||q) ,$ $D_{KL}(p \| q) = \sum_{x} p(x) \log\left(\frac{p(x)}{q(x)}\right)$
> 并且狄拉克δ分布$p$(真实分布，所有概率集中在一个点上)  的熵为零，因此这也等价于最小化两个分布之间的KL散度（一种距离度量）。
> 换句话说，交叉熵目标函数希望预测的分布将其所有概率质量都放在正确答案上。
> 
> ##### 概率论解释
> 观察这个表达式 $P(y_i | \mathbf{x}_i; W) = \frac{e^{f_{y_i}}}{\sum_{j=1}^{K} e^{f_j}}$
> 我们可以将其解释为：在给定图像 $x_i$ 和参数 $W$ 的条件下，分配给正确标签 $y_i$ 的（归一化）概率。
> 
> 要理解这一点，请记住Softmax分类器将输出向量 `f` 中的分数解释为归一化的对数概率。因此，对这些数值取指数就得到了（未归一化的）概率，而除法部分则执行了归一化操作，使得所有概率总和为1。
> 
> 在这个概率论的解释下，我们实际上是在最小化正确类别的负对数似然（negative log likelihood），这可以被理解为在执行最大似然估计（Maximum Likelihood Estimation, MLE）。这种观点的一个优点是，我们现在也可以将完整损失函数中的正则化项 `R(W)` 解释为来自权重矩阵 `W` 的一个高斯先验（Gaussian prior），此时我们执行的就不是MLE，而是最大后验概率估计（Maximum a posteriori, MAP）。提及这些解释是为了帮助建立直觉，但这个推导的完整细节超出了这里的范围。
> 
> ##### 实践问题：online-softmax
> 在实践中，当你编写代码来计算Softmax函数时，由于指数运算的存在，中间项 `e^(f_yi)` 和 `Σ_j e^(f_j)` 可能会变得非常大。对非常大的数进行除法可能会导致数值不稳定，因此使用一个**归一化技巧**非常重要。
> 
> 注意到，如果我们在分数的分子和分母上同乘以一个常数 `C`，并将其推入求和中，我们会得到以下（数学上等价的）表达式：
> 
> `e^(f_yi) / Σ_j e^(f_j) = (C * e^(f_yi)) / (C * Σ_j e^(f_j)) = e^(f_yi + log C) / Σ_j e^(f_j + log C)`
> 
> 我们可以自由选择常数 `C` 的值。这不会改变任何结果，但我们可以利用它来提高计算的数值稳定性。
> 一个常见的选择是令 `log C = -max(f_j)`。这仅仅表示我们应该对向量 `f` 内部的值进行平移，使得其中的最大值为零。在代码中：
> 
> ```python
> f = np.array([123, 456, 789]) # 一个有3个类别且分数都很大的例子
> p = np.exp(f) / np.sum(np.exp(f)) # 糟糕的实现：数值问题，可能溢出
> 
> # 正确做法：先平移f的值，使其最大值为0
> f -= np.max(f) # f 变为 [-666, -333, 0]
> p = np.exp(f) / np.sum(np.exp(f)) # 现在计算是安全的，并且能给出正确答案
> ```
> 

## SVM loss

准确地说，SVM分类器使用合页损失（hinge loss），有时也称为最大间隔损失（max-margin loss）。
Softmax分类器使用交叉熵损失（cross-entropy loss）。

> The Multiclass Support Vector Machine "wants" the score of the correct class to be higher than all other scores by at least a margin of delta. 

对于任何一个错误类别，如果它的分数落在了图中的**红色区域内**（即与正确类别的分数差距小于delta），或者甚至比正确类别的分数更高，那么就会产生累积的损失。
反之，如果所有错误类别的分数都在红色区域之外（即与正确类别的分数差距大于等于delta），那么损失就为零。
![svm loss](https://cs231n.github.io/assets/margin.jpg)

第一个Loss，计算时$S_{yi}$为cat，减去的都是3.2($y_i$ is the label)
第二个Loss同理，计算时$S_{yi}$为car，减去4.9
这里公式中的+1其实是可以选择的超参数，一般称之为delta/margin

![lecture_2, 页面 90](files/slides/CS231n/lecture_2.pdf#page=91)

Loss over full dataset is average: L = (2.9+0+12.9)/3 = 5.27

> [!question] 一些问题
> ##### SVM loss $L_i$ 可能的最小值/最大值是多少？
> 最小值为0，最大值为正无穷
> ##### 假设在初始化时W很小，导致所有 s ≈ 0。假设有N个样本和C个类别，此时的损失 $L_i$ 是多少？
> 则有$L_i \approx (C-1)*\Delta$
> ##### 如果求和是针对所有类别（包括 j = y_i）呢？
> 那改动后的Loss = 原Loss加上一个$\Delta$，如果用梯度去寻求最佳参数，那么loss加上一个常数对结果不会有什么影响
> ##### 如果我们用平均值（mean）代替求和（sum）呢？
> 那么也只是多了一个常数因子在前，对于求最佳参数不会有什么改变
> ##### 如果我们使用平方SVM损失（squared SVM loss）呢？
> 则其公式为$L_{sq_i} = \sum_{j \neq y_i} \left( \max(0, s_j - s_{y_i} + \Delta) \right)^2$
> 这种形式对违反间隔（margin）的行为惩罚得更重。不过观察函数图像，平方SVM是更平滑的。未平方的版本（即标准Hinge Loss）更为常用，但在某些数据集上，平方合页损失的效果可能会更好。

## SVM vs Softmax

这是针对同一个数据点，SVM分类器和Softmax分类器之间差异的一个示例。

在两种情况下，我们都计算出了相同的分数向量 f。不同之处在于**对这个分数向量 f 的解释**：

- SVM 将这些分数解释为**类别得分**，其损失函数的目标是促使**正确类别**（图中的蓝色类别2）的得分比其他所有类别的得分都**高出一个安全间隔（margin）**。
- Softmax分类器则将这些分数解释为每个类别的（未归一化的）对数概率，其目标是促使正确类别的（归一化后的）对数概率尽可能高（这等价于让它的负对数概率尽可能低）。

但需要强调的是，这两个数字是不可比较的；它们只有在**同一个分类器内部**、针对**相同数据**计算出的不同损失值之间进行比较时才有意义。

![lecture_2, 页面 99](files/slides/CS231n/lecture_2.pdf#page=99)


**Softmax分类器为每个类别提供“概率”。**

与SVM计算出的那种未经校准且难以解释的类别分数不同，Softmax分类器允许我们计算出所有标签的“概率”。
eg: 给定一张图片，SVM分类器可能为你给出“猫”、“狗”、“船”这三个类别的分数为 [12.5, 0.6, -23.0]。
而Softmax分类器则可以计算出这三个标签的概率为 [0.9, 0.09, 0.01]，这能让你直观地理解它对每个类别的置信度。

然而，我们之所以给“概率”这个词加上引号，是因为这些概率分布的**集中程度（peaky）或分散程度（diffuse）**，直接取决于**正则化强度 λ**——这是你作为一个超参数输入给系统的。

举个例子，假设三个类别未经归一化的对数概率是 [1, -2, 0]。
Softmax函数会这样计算： $[1, -2, 0] -> [e¹, e⁻², e⁰] = [2.71, 0.14, 1] -> [0.7, 0.04, 0.26]$

现在，如果正则化强度 λ **更高**，权重 W 会受到更强的惩罚，这会导致权重的值变得更小。
例如，假设权重都缩小了一半，分数变为 [0.5, -1, 0]。
Softmax现在会这样计算：  $[0.5, -1, 0] -> [e⁰.⁵, e⁻¹, e⁰] = [1.65, 0.37, 1] -> [0.55, 0.12, 0.33]$  
可以看到，现在的概率分布变得**更加分散**了。

更进一步，在极限情况下，如果由于极强的正则化强度 λ 导致权重趋近于极小的数值，那么输出的概率将会接近**均匀分布**。因此，最好将Softmax分类器计算出的概率理解为一种**置信度**。在这里，与SVM类似，分数的**排序**是有意义的，但其**绝对值**（或它们之间的差异）严格来说并不能直接等同于真实的概率。

**在实践中，SVM和Softmax的表现通常不相上下。**

SVM和Softmax之间的性能差异通常非常小，不同的人对于哪个分类器更好有不同的看法。

与Softmax分类器相比，SVM是一个更“局部”的目标函数，这既可以被看作是一个**缺点**，也可以被看作是一个**特性**。

思考一个例子，假设分数是 [10, -2, 3]，并且第一个类别是正确的。一个SVM（例如，期望的安全间隔 Δ=1）会发现正确类别的分数已经比其他类别的分数高出了所要求的间隔，因此它计算出的损失为零。
==SVM并不关心各个分数的具体数值==：如果分数是 [10, -100, -100] 或是 [10, 9, 9]，SVM会**一视同仁**，因为 Δ=1 的间隔条件已经被满足，所以损失都是零。

然而，对于Softmax分类器来说，这些情况是**不等价的**。对于 [10, 9, 9] 这组分数，Softmax会计算出比 [10, -100, -100] **高得多的损失**。换句话说，**Softmax分类器永远不会对它产生的分数完全满意**：正确类别的概率总可以更高，错误类别的概率总可以更低，损失也总有优化的空间。

但是，SVM一旦满足了间隔条件就感到满意了，它不会在这个约束之外去微观管理（micromanage）各个分数的精确值。这可以被直观地理解为一个**特性**：例如，一个汽车分类器，它可能应该把大部分“精力”投入到区分“汽车”和“卡车”这个困难的问题上，而不应该被那些“青蛙”的样本所影响——对于“青蛙”，模型已经给出了极低的分数，而且它们很可能聚集在数据空间中一个完全不同的区域。

---

## 一些数学

---
### KL散度

KL 散度（Kullback-Leibler Divergence），简称 **KL 散度** 或 **相对熵**，是用来衡量**两个概率分布之间差异**的一个指标。
==你可以把它简单理解为“两个分布有多不像”**。==

对于两个概率分布 $P(x)$ 和 $Q(x)$：

*   $P$ 是**真实的分布**（数据的本来面目）。
*   $Q$ 是你**假设的分布**（你用来拟合的模型）。
$$ D_{KL}(P || Q) = \sum P(x) \log \frac{P(x)}{Q(x)} $$



对于连续概率分布 $P(z)$ 和 $Q(z)$，KL 散度的定义是：
$$ D_{KL}(Q \| P) = E_{x \sim Q} \left[ \log \frac{Q(x)}{P(x)} \right] $$
或者写成积分形式：
$$ D_{KL}(Q \| P) = \int Q(x) \log \frac{Q(x)}{P(x)} dz $$

---
KL 散度 $D_{KL}(P || Q)$ 衡量的就是：**如果你错误地用分布 $Q$ 来编码本来服从分布 $P$ 的数据，平均每条消息你会多浪费多少比特（bit）的信息量。**

它的性质有：
1.  **非负性**: $D_{KL}(P || Q) \ge 0$。
    *   只有当 $P$ 和 $Q$ 完全一模一样时，KL 散度才等于 0。
    *   只要有差异，它就是正数。

2.  **不对称性**: $D_{KL}(P || Q) \neq D_{KL}(Q || P)$。
    *   “用 $Q$ 拟合 $P$” 和 “用 $P$ 拟合 $Q$” 产生的损失是不一样的。
    *   所以它**不是**一个标准的“距离”（距离应该是对称的，A到B等于B到A）。

---
### 交叉熵

$$
\\[2em]
\normalsize
\begin{aligned}
& \text{1. 从交叉熵的通用定义出发：} \\
& H(p, q) = - \sum_{k=1}^{C} p_k \log q_k \\
\\
& \text{2. 定义在多分类问题中的真实分布 } p \text{ 与预测分布 } q \text{：} \\
& \quad \text{真实分布 } p \text{ 是一个one-hot向量，其中真实类别 } y_i \text{ 的概率为1，其余为0。} \\
& \qquad p_k = 
\begin{cases} 
1 & \text{if } k = y_i \\
0 & \text{if } k \neq y_i 
\end{cases}
\\
& \quad \text{预测分布 } q \text{ 由Softmax函数给出。} \\
& \qquad q_k = \frac{e^{f_k}}{\sum_{j=1}^{C} e^{f_j}} \\
\\
& \text{3. 将 } p \text{ 和 } q \text{ 代入交叉熵定义并化简：} \\
H(p, q) &= - \sum_{k=1}^{C} p_k \log q_k \\
&= - \left( \sum_{k \neq y_i} p_k \log q_k + p_{y_i} \log q_{y_i} \right) && \text{(拆分求和项)} \\
&= - \left( \sum_{k \neq y_i} (0 \cdot \log q_k) + (1 \cdot \log q_{y_i}) \right) && \text{(代入one-hot的定义)} \\
&= - \left( 0 + \log q_{y_i} \right) && \text{(化简零项)} \\
&= - \log q_{y_i} \\
&= - \log\left(\frac{e^{f_{y_i}}}{\sum_{j=1}^{C} e^{f_j}}\right) && \text{(代入Softmax的定义)} \\
\\
& \text{4. 结论：} \\
& \text{这个结果与Softmax分类器的损失函数 } L_i \text{ 的定义完全相同。} \\
& \therefore \quad L_i = H(p, q)
\end{aligned}
$$

---
### 最大似然估计

当然，这里是将上述逻辑过程用严谨的LaTeX公式推导形式展现出来。
最小化交叉熵损失等价于最大似然估计

---
$$
\\[2em]
\normalsize
\begin{aligned}
& \textbf{1. 定义最大似然估计 (Maximum Likelihood Estimation, MLE)} \\
& \text{给定一组独立同分布的训练数据 } \mathcal{D} = \{(\mathbf{x}_i, y_i)\}_{i=1}^N \text{，似然函数 } L(W) \text{ 是在参数 } W \text{ 下，观测到} \\
& \text{整个数据集真实标签的联合概率。我们的目标是找到能最大化该似然函数的参数 } W^* \text{。} \\
\\
W^* &= \arg\max_W L(W) \\
&= \arg\max_W P(y_1, \dots, y_N | \mathbf{x}_1, \dots, \mathbf{x}_N; W) \\
\\
& \text{由于样本独立同分布 (I.I.D.)，联合概率等于各样本概率的乘积：} 
L(W) = \prod_{i=1}^N P(y_i | \mathbf{x}_i; W) \\
\\
& \textbf{2. 引入对数似然 (Log-Likelihood)} \\
& \text{由于对数函数是单调递增的，最大化 } L(W) \text{ 等价于最大化其对数 } \log L(W) \text{。取对数能将} \\
& \text{乘积运算转换为求和运算，便于计算且能防止数值下溢。} \\
\\
W^* &= \arg\max_W \log L(W) \\
&= \arg\max_W \log \left( \prod_{i=1}^N P(y_i | \mathbf{x}_i; W) \right) \\
&= \arg\max_W \sum_{i=1}^N \log P(y_i | \mathbf{x}_i; W) \\
\\
& \textbf{3. 转换为最小化问题 (Conversion to Minimization)} \\
& \text{在优化理论中，我们习惯于最小化一个损失函数。最大化一个函数等价于最小化它的负值。} \\
& \text{因此，我们可以将最大化对数似然问题，等价地转换为最小化负对数似然问题。} \\
W^* &= \arg\min_W \left( - \sum_{i=1}^N \log P(y_i | \mathbf{x}_i; W) \right) \\
\\
& \text{通常，我们优化的是所有样本损失的平均值，这不改变最优解的位置：} \\
W^* &= \arg\min_W \frac{1}{N} \sum_{i=1}^N \left( - \log P(y_i | \mathbf{x}_i; W) \right) \\
\\
& \textbf{4. 与Softmax分类器的交叉熵损失建立联系} \\
& \text{Softmax分类器为单个样本 } i \text{ 定义的损失函数 } L_i \text{ 正是正确类别的负对数概率：} \\
L_i(W) &= - \log P(y_i | \mathbf{x}_i; W) \\
&= - \log\left(\frac{e^{f_{y_i}}}{\sum_{j=1}^{K} e^{f_j}}\right) \\
\\
& \text{因此，整个数据集的平均损失 } \mathcal{L}(W) \text{ 为：} \\
\mathcal{L}(W) &= \frac{1}{N} \sum_{i=1}^N L_i(W) = \frac{1}{N} \sum_{i=1}^N \left( - \log P(y_i | \mathbf{x}_i; W) \right) \\
\\
& \textbf{5. 结论} \\
& \text{比较第3步和第4步的结果，我们发现，最小化Softmax分类器的平均交叉熵损失函数 } \mathcal{L}(W) \text{，} \\
& \text{在数学上与执行最大似然估计的目标是完全等价的。} \\
& \quad \min_W \mathcal{L}(W) \iff \max_W L(W)
\end{aligned}
$$