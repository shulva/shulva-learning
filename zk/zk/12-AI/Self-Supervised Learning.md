# Self-Supervised Learning

## intro

监督学习下，我们需要海量的，**有标注的数据**。但是这很昂贵，也很耗时。
所以，有没有办法在不需要大量人工标签的情况下训练网络？

![lecture_12, 页面 8](files/slides/CS231n/lecture_12.pdf#page=8)

我们的应对方法是：
首先，在pretext Task(相当于预训练)阶段，输入no labels没有标签的数据。（No manual annotation）。
这时，我们就可以学习非常多的数据（尽管没有高质量的human label）。
没有标签怎么训练呢？Define a task based on the data itself，自己给自己出题。
只要能让模型去理解图片的内容和结构就行。而且也可以采用我们可以自动生成标签的dataset，这里有些[例子](files/slides/CS231n/lecture_12.pdf#page=12&selection=17,0,17,4)。

之后，在Downstream Task阶段，我们使用有标签的数据（虽然不多就是了）。
这时，我们就可以将上面训练好的模型直接拿下来用，再训练，就像之前提到的Transfer Learning迁移学习。
这时模型学会了通用的特征后，再用少量标签数据稍加微调，就能解决实际问题。
![lecture_12, 页面 9](files/slides/CS231n/lecture_12.pdf#page=9)

Pretext的Learned Representation的右半部分一般是Decoder/Classifier/Regressor
Downstream Task一般在右半部分只需要加上一层，甚至只需要一个全连接层就行了。你可以只训练这个FC。
![lecture_12, 页面 11](files/slides/CS231n/lecture_12.pdf#page=11)

一般来说，衡量pretext task中学习目标的好坏，还是通过性能来判断。
Transfer Learning and Downstream Task Performance 
Assess the utility of the learned representations by transferring them to a downstream supervised task.
![lecture_12, 页面 15](files/slides/CS231n/lecture_12.pdf#page=15)

## Pretext Tasks

但是，至少slides前面介绍的基于预测旋转角度、预测色彩（拼图/着色）的早期自监督方法，已经属于过时的技术了。
在 2015-2019 年左右，这些被称为 **Pretext Tasks** 的方法非常流行，比如Rotation , coloring ,etc.
![lecture_13, 页面 5](files/slides/CS231n/lecture_13.pdf#page=5)

Learned representations may be tied to a specific pretext task! 
Can we come up with a more general pretext task?
![lecture_12, 页面 66](files/slides/CS231n/lecture_12.pdf#page=66)

虽然早期的图像变换任务开启了自监督学习的大门，让模型学会了一些常识，但它们太依赖人工设计，且学到的东西往往太局限，不够通用。它们被后来居上的**对比学习 (Contrastive Learning)** 淘汰了，主要原因有两个：
1. 学到的特征太Domain Specific
    - **例子**: 通过预测旋转角度训练出来的模型，虽然对物体的**方向**很敏感，但它可能根本不在乎物体的**纹理**或**语义**。比如它能认出“倒着的车”，但可能分不清“倒着的车”和“倒着的盒子”。
    - 相比之下，对比学习（如 MoCo）和 MAE 学到的是更全面、更通用的语义特征，在下游任务（分类、检测）上的表现碾压了这些老方法。
2. 不仅没用，有时还有害
    - 在一些任务中，物体的颜色或方向其实是不重要的。如果你强迫模型去关注这些，反而会干扰它学习真正重要的特征。

--- 
### Masked Auto Encoders

[MAE的重建效果](files/slides/CS231n/lecture_12.pdf#page=52)
Those are not masked are given to the encoder to encode in two features that are then passed through decoder to generate the complete image.
而且大规模覆盖原图（75%）之后，重建图片很难。而这意味着模型需要学习更好的feature
![lecture_12, 页面 53](files/slides/CS231n/lecture_12.pdf#page=54)

> MAE encoder

Uses transformer blocks，Embeds the patches by linear projection and add positional embeddings. ViT
![lecture_12, 页面 55](files/slides/CS231n/lecture_12.pdf#page=55)

Decoder 本身也是一个 Transformer（通常比 Encoder 小很多，轻量级）。
最后Decoder通过一个简单的线性层，把特征向量变回具体的像素值，重画出整张图。
Decoder 的唯一用处就是帮 Encoder 进行预训练。
一旦训练结束，我们只需要那个训练好的，性能优秀的 Encoder 来做下游任务（比如分类），Decoder 直接扔掉。
这是一个**非对称**的自编码器设计(Encoder处理少量块，网络深。Decoder处理全部块，网络浅)。
![lecture_12, 页面 56](files/slides/CS231n/lecture_12.pdf#page=56)

---
#### Linear Probing vs Full Fine-tuning

使用预训练模型时最常见的策略：**Linear Probing (线性探测)** 和 **Full Fine-tuning (全量微调)**。

> **"The pre-trained model is fixed, and only one linear layer is added at the end..."**
> (预训练模型被**固定**住，只在末尾添加一个**线性层**...)

冻结 (Freeze)整个预训练好的 Encoder,只训练最后那个新加的分类头
目的: **"Assess the quality of representations"**（评估特征表示的质量）。
因为 Encoder 不动，所以最终分类的好坏，完全取决于 Encoder 本身提取的特征够不够好。
这是一种测验，用来测试预训练模型到底学到了什么本事。如果只加一个简单的线性层就能分得很准，说明特征本身非常线性可分、质量很高。

> **"Pre-trained model is further trained (not fixed)..."**
> (预训练模型会被**进一步训练**，而不是固定的...)

解冻整个 Encoder，所有层的参数都参与更新。通常会使用比预训练时更小的学习率。 
目的: **"Exploits models near-true potential"**（挖掘模型的真实潜力）。
这不仅是利用预训练的知识，还要让模型根据新的任务（新数据）进行自我调整和适应。
这通常能得到最高的准确率，是实际应用中最常用的方法。

![lecture_12, 页面 58](files/slides/CS231n/lecture_12.pdf#page=58)

---

> **"Pretext tasks focus on 'visual common sense'
>  e.g., predict rotations, inpainting, rearrangement, and colorization."**

这些任务的设计初衷是让 AI 学会像人一样的基本视觉逻辑。

> **"The models are forced to learn good features about natural images... in order to solve the pretext tasks."**

模型为了要在这些前置任务考试中拿高分，必须被迫去理解图片的**深层含义**（比如物体的形状、类别），而非只关注像素。

> **"We often do not care about the performance of these pretext tasks, but rather how useful the learned features are for downstream tasks..."**

*   **意思**: 我们不关心前置任务本身的成绩,我们只关注模型完成后完成下游任务的表现，这是自监督学习的核心逻辑。

> **Problems: 1) coming up with individual pretext tasks is tedious 
> and 2) the learned representations may not be general.**

1:设计好的任务很难。2：学习到的特征不通用。

![lecture_12, 页面 62](files/slides/CS231n/lecture_12.pdf#page=62)

---
## Contrastive representation learning

x是原图，x positive是正确的图像，x negative是无关的图像。
![lecture_12, 页面 70](files/slides/CS231n/lecture_12.pdf#page=70)

> This seems familiar -> Cross entropy loss for a N-way softmax classifier!

learn to find the only positive one sample from the N samples , other N-1 is negative samples.
![lecture_12, 页面 72](files/slides/CS231n/lecture_12.pdf#page=72)

L就是交叉熵损失函数，希望模型能找到那个正确的 1 positive，远离其他的N-1个negative。
最小化这个 Loss，等价于最大化 $f(x)与f(x^+)$ 之间的互信息（Mutual Information）的下界。

**MI (互信息)**: 衡量两个变量之间共享多少信息。如果$x和x^+$的特征互信息很高，说明通过$x$的特征能很好地预测$x^+$ 的特征，反之亦然。这正是我们想要的高质量特征。
**Lower Bound (下界)**: InfoNCE Loss 实际上是在优化互信息的**下界**。Loss 越小（-$L$越大），下界就越高，特征就越好。

> **"The larger the negative sample size (N), the tighter the bound"**  (负样本数量 N 越大，这个下界就越精确)

empirically，负样本越多越好，Batch Size越大越好。
科学解释一下的话，那就是更多的负样本意味着分母中的求和项更多，模型面临的干扰项更多，这逼迫模型必须学出更本质的特征才能在众多干扰中找到正确的正样本。
对比学习本质上是在做一个N 选 1 的选择题扰项越多，做对题目所需的理解能力（特征质量/互信息）就越高。
![lecture_12, 页面 75](files/slides/CS231n/lecture_12.pdf#page=75)

### SimCLR

> pull together the one that are similar, push apart the other that are dissimilar.

下面的步骤主要是：
1.数据增强(data augmentation)将原本图片x通过变换（pretext task里带那些技巧）变为两个正样本positive sample。
2.通过encoder f 提取特征。
3.投影头 (Projection Head g): 映射到对比空间。这是 SimCLR 的一个关键创新。它不直接用 $h$ 算 Loss，而是再加一个小型的神经网络 $g(\cdot)$（通常是两层 MLP），把特征 $h$ 映射到一个新的空间。
实验证明，在这个新空间里算对比损失效果更好，而之前的 $h$ 保留给下游任务（比如分类）用更好。这里有一些[解释](files/slides/CS231n/lecture_12.pdf#page=85&selection=17,0,17,6)。
4.对比损失 (Contrastive Loss): 拉近同类，推开异类
我们希望 $z_i$ 和 $z_j$（同一个图的两个分身）的相似度越高越好。这里用的是**余弦相似度 (Cosine Similarity)**。在这个batch中还有很多其他的图，我们希望与这些负样本的相似度越低越好。

**Maximize agreement**: ——最大化正样本对之间的一致性。
![lecture_12, 页面 76](files/slides/CS231n/lecture_12.pdf#page=76)

代码如下所示：
![lecture_12, 页面 80](files/slides/CS231n/lecture_12.pdf#page=80)

这里就是把N张原始图片用数据增强做出2N张，之后全部扔进编码器。
2N张图片是成对排列的，2k与2k+1是来源自同一张图片的正样本对。
之后算出它们2N-2N之间的相似度矩阵，然后要求模型在每一行中，把正样本（蓝色块）的相似度推到最高，把其他所有负样本（白色块）的相似度压到最低。
![lecture_12, 页面 82](files/slides/CS231n/lecture_12.pdf#page=82)

---
### MoCo

SimCLR有一些问题，it Need large batch size with lots of negatives!
SimCLR 想要好的效果，必须要有巨大的 Batch Size（为了凑够多的负样本）。
![lecture_12, 页面 86](files/slides/CS231n/lecture_12.pdf#page=86)

MoCo 提出了一种动量更新 + 队列机制，想要解决这个问题。

> MoCo 通过队列让你拥有很多负样本（效果好），通过**动量更新**让你不需要计算这海量负样本的梯度（省显存）。

> **"Keep a running queue of keys (negative samples)."**

*   **SimCLR**: 负样本必须来自同一个 Batch，如果 Batch Size 是 256，那负样本最多只有 510(512-2) 个。
*   **MoCo**: 搞一个巨大的队列，这个队列里存满了之前算好的特征向量（Keys）。
  每次训练完一个新的 Batch，把新的特征**入队**，最老的特征**出队**。
  负样本的数量不再受限于 Batch Size。即使 Batch Size 只有 32，我依然可以有很多个负样本！这解耦了 Batch Size 和负样本量之间的关系。

MoCo 使用了两个长得一模一样的网络，但它们的更新方式完全不同。
*   **Query Encoder (左边绿色的)**: 这是我们要训练部分。
    *   它接收当前的图片 $x^{query}$，输出 $q$。
    *   **"Compute gradients and update the encoder only through the queries"**: 所有的梯度反向传播只走这条路，用梯度下降正常更新参数 $\theta_q$。

*   **Momentum Encoder (右边蓝色的)**:
    *   它负责生成队列里的 Keys ($k_0, k_1, ...$)。
    *   **"no_grad"**: 这部分不算梯度！如果还要算这几万个负样本的梯度，显存早就爆了。

> **"The key encoder is slowly progressing... $\theta_k \leftarrow m\theta_k + (1-m)\theta_q$"**

但是如果右边的 Key Encoder 不算梯度，那它的参数怎么变呢？如果它一直不变，或者是直接复制左边的参数，会导致队列里的特征不一致（新的特征是用新参数算的，老的特征是用旧参数算的，没法比）。

于是，MoCo让 Key Encoder **缓慢地、平滑地**跟随 Query Encoder 变化。
$\theta_k$ (Key 参数) = $0.999 \times \theta_k$ (保持自己) + $0.001 \times \theta_q$ (学一点点 Query 参数)。
这就是**动量**。它保证了 Key Encoder 的参数变化非常平缓，使得队列里虽然存的是不同时刻算出来的特征，但它们在大致的分布上是一致的，可以放在一起比较。

![lecture_12, 页面 88](files/slides/CS231n/lecture_12.pdf#page=88)

> 可见，SimCLR确实需要很多显存

但是，MoCO V2吸取了很多SimCLR的优点。
SimCLR中的**Non-linear projection head**以及**strong data augmentation**真的很有用。MoCo V2都拿了过来。
而且解耦了Batch Size与negative samples之间的关系使其成本很低。

[MoCo V3](files/slides/CS231n/lecture_12.pdf#page=102&selection=17,0,17,5) ？你自己读paper去吧。
![lecture_12, 页面 93](files/slides/CS231n/lecture_12.pdf#page=93)

---
### Contrastive Predictive Coding (CPC)

> **基于实例 (Instance-level)** 和 **基于序列 (Sequence-level)**

实例就是前文提过的SimCLR,MoCo采用的方法。不关心图片内部的时间顺序，只关心整体的一致性。和空间概念相关。
序列则是与时间相关，要预测接下来的片段是什么。（这么一说好像也算是LLM的origin之一？）

![lecture_12, 页面 94](files/slides/CS231n/lecture_12.pdf#page=94)


> **"contrast between 'right' and 'wrong' sequences"**

给定前面的序列（比如图片里的数字 2, 3, 4, 5）。通过正负样本，使用Contrastive Learning让模型学习。

> **"the model has to predict future patterns given the current context."**

这是一个自回归 (Autoregressive) 的过程。
*   图中的 $C_t$ 是通过一些方法（RNN 或 CNN？） 聚合了前面所有信息（$x_{t-3}$ 到 $x_t$）的**上下文向量 (Context Vector)**。
*   模型需要利用这个 $C_t$ 去预测未来时刻 $t+k$ 的特征 $z_{t+k}$ 。模型通过这个任务提取feature。
-    训练好的Encoder可以去做下游任务。

[CPC的具体操作](files/slides/CS231n/lecture_12.pdf#page=98)我懒得做笔记了，你自己看吧。

![lecture_12, 页面 95](files/slides/CS231n/lecture_12.pdf#page=95)

---
### DINO (Self-Distillation with NO labels)

这张幻灯片介绍的是 **DINO (Self-Distillation with NO labels)**。
这是一种**自蒸馏 (Self-Distillation)** 的方法。

DINO 不需要像 SimCLR/MoCo 那样使用负样本，它只用正样本。

*   **输入**: 一张图片 $x$ 被裁剪成两个不同的视角 $x_1$ (给学生) 和 $x_2$ (给老师)。
*   **学生网络 ($g_{\theta s}$)**:
    *   这是我们主要训练的网络。它通过反向传播 (Backprop) 来更新参数，试图让自己的输出 $p_1$ 去匹配老师的输出 $p_2$。
*   **老师网络 ($g_{\theta t}$)**:
    *   结构和学生一模一样，但参数不同。
    *   老师不进行反向传播（图中 `sg` / `no_grad` 线条）。
    *   EMA (指数移动平均): 老师的参数是由学生的参数**缓慢地、平滑地**更新过来的（公式：$\theta_{teacher} \leftarrow \tau \theta_{teacher} + (1-\tau)\theta_{student}$）。这里的思想应该是来源于MoCo?

*   **Loss**: $-p_2 \log p_1$。这是一个标准的交叉熵损失。
*   在这里，**老师的输出 $p_2$ 被当作是标准答案**（尽管它也是猜的）。学生 $p_1$ 要尽力去模仿老师的概率分布。

> 既然没有负样本，只要求两张图特征一致，为什么模型不会偷懒，把所有图片的特征都输出成一模一样的常数（比如全 0 或全 1）？这叫**模型坍塌 (Collapse)**。

DINO 用两招来防止Collapse：

1.  **Centering (中心化)**:
    *   **操作**: 把老师的输出减去一个**均值**（这个均值是过去一段时间所有样本输出的平均）。
    *   **作用**: 防止**某个类别一家独大**。它强迫模型不要总是输出同一个特征维度。这就避免了模型把所有图都识别成同一类。

2.  **Sharpening (锐化)**:
    *   **操作**: 在 Softmax 中使用很低的温度系数 (Temperature)。
    *   **作用**: 让输出的概率分布变得**集中**（比如 [0.9, 0.05, 0.05] 而不是 [0.33, 0.33, 0.33]）。
    *   **目的**: 防止**均匀分布**。它强迫模型必须做出“自信”的判断，而不是模棱两可。

 Centering 防止大家缩到一个点，Sharpening 防止大家变成均匀噪声。这下，模型被迫学出有意义的特征聚类。

---

DINO V2学习了142M的数据后，表现的就更为强大了。DINO好处如下：
1.  **简单**: 不需要负样本，不需要SimCLR大的 Batch Size，也不需要MoCo复杂的队列。
2.  **Transformer 友好**: DINO 特别适合 Vision Transformer (ViT)。
3.  **涌现特性 (Emerging Properties)**: 神奇的是，DINO 训练出来的 ViT，其自注意力图（Attention Map）能自动把图片里的物体（比如一只鸟）完美地分割出来，即使训练时从来没给过任何分割标签！这是之前的有监督学习都很难做到的。

![lecture_12, 页面 104](files/slides/CS231n/lecture_12.pdf#page=104)