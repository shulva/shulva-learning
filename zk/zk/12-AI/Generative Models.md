# Generative Models

## intro

无监督学习的传统任务有：
- **聚类 (Clustering)**: K-Means, GMM。把数据分成几堆。
- **降维 (Dimensionality Reduction)**: PCA, t-SNE。把高维数据压扁到低维，方便可视化。
- **密度估计 (Density Estimation)**: 估计数据的概率分布。
![lecture_13, 页面 18](files/slides/CS231n/lecture_13.pdf#page=113)

---
### Generative,Discriminative,Conditional Generative Model

牢记，接下来x代表data数据，y代表label标签。

![lecture_13, 页面 23](files/slides/CS231n/lecture_13.pdf#page=23)

> Discriminative Models

In this case , we are learning a probabilistic model of y condition on x , which means that for every x, our model is predicting a probability distribution over all possible labels.
Possible labels for each image compete for probability. No competition between images.

其的缺点如下:
![lecture_13, 页面 26](files/slides/CS231n/lecture_13.pdf#page=26)

> Generative Models

We want to learn a distribution over all possible image x.
![lecture_13, 页面 29](files/slides/CS231n/lecture_13.pdf#page=29)

> Conditional Generative Model

Sometimes the y is very ill-defined(like just give you a picture or written text), then the question will become very complicated, it needs the model to have great reasoning ability.
![lecture_13, 页面 30](files/slides/CS231n/lecture_13.pdf#page=30)

理论上来说，我们可以通过贝叶斯公式组合Discriminative Model和Generative Model形成Conditional Generative Model ，
但是实际上大家还是从头训练Conditional Generative Model。
![lecture_13, 页面 32](files/slides/CS231n/lecture_13.pdf#page=32)

What is the most useful aspect of Conditional Generative Model is to generate data from labels.
You input y, and the model generative x with labels y.
Generative Model和Conditional Generative Model虽然都是Generative Model，但此两者不可混为一谈。
因为有不少人不喜欢写p(x|y)将其统一写成p(x)，注意，不要混淆。
![lecture_13, 页面 35](files/slides/CS231n/lecture_13.pdf#page=35)

### Why Generative Models?

当然，还可以文生图：Text to Image: Produce output image x from input text y
还可以图生视频：Image to Video: What happens next?
![lecture_13, 页面 37](files/slides/CS231n/lecture_13.pdf#page=37)

You can not compute P(x), you can only sample form P(x) , so it is called "implicit" density.
But, if the thing you really care about is sampling, then you maybe don't need to explicitly be able to see the value of density of input.
![lecture_13, 页面 47](files/slides/CS231n/lecture_13.pdf#page=47)

---
## Autoregressive Models

> Model can compute P(x) , and can really compute P(x)

Autoregressive自回归的字面意思是：**自己对自己的回归 (Self-Regression)**。
- 在一个序列中，当前时刻的某个值，可以**由这个序列自己过去时刻的值**来预测或解释。
- Auto (自): 指的是“自己”，即序列**自身**。
- Regressive (回归): 指的是“回归分析”，即用一个或多个变量预测另一个变量。
即，一个 Autoregressive 模型在生成序列中的当前元素时，会依赖于且仅依赖于它已经生成的所有“过去”的元素的序列。


> 应用广泛的思想：最大似然估计MLE

1.  目标设定：我们想找到一个数学函数 $f(x, W)$ 来描述数据 $x$ 的概率分布，其中 $W$ 是我们要寻找的模型参数。
2.  核心思想：最合理的参数 $W$，应该是能让这组**已经发生的训练数据**出现的概率（即“似然”）达到**最大**的那一组。
3.  计算假设：假设所有数据点是相互独立的，那么整个数据集出现的总概率就是每个数据点概率的**乘积**。
4.  Log Trick：因为连乘很难算且容易数值溢出，我们利用对数函数把“概率连乘”转换成了“对数概率**连加**”。
5.  最终形态：最大化这个“对数概率和”，在数学上等价于我们熟悉的**最小化损失函数**。
这就是为什么我们在训练神经网络时，要用梯度下降去优化损失函数——本质上就是在做最大似然估计，让模型尽可能逼近数据的真实分布。

![lecture_13, 页面 52](files/slides/CS231n/lecture_13.pdf#page=52)

Break data sample x into some sequence subparts in some way.
==That's going to input the previous part of the sequence and try to give us a probability distribution over the next part of the sequence.It is familiar with RNN... and even masked transformer==

![lecture_13, 页面 56](files/slides/CS231n/lecture_13.pdf#page=56)

Language is naturally a sequence of 1D, it is easy to break that. It is discrete.
Image is continuous. We need some tricks. We can treat image as a sequence of pixels. But it is too expensive!

![lecture_13, 页面 59](files/slides/CS231n/lecture_13.pdf#page=59)


> 自回归在图像生成领域的反击！

虽然扩散模型一度统治了图像生成，但最近像 VQ-VAE 和 Transformer 结合的自回归方法又重新崭露头角。

这种方法的核心思想是：**把生成图片变成像生成文本一样（Next Token Prediction）。**

首先，我们训练一个 VQ-VAE (Vector Quantized VAE)。通过Encoder:把一张高清图片压缩成一个Latent。Latent里的每个点，不再是连续的小数，而是被量化成了**离散的整数（Discrete Latents/Integers）**。相当于图像的Token。

有了这些离散的 Token，我们就可以把图片看作是一个长的**整数序列**。这样我们就可以我们用类似 GPT 的**自回归模型**来学习这些序列的规律。和LLM预测下一个Token一样，只是这里Token是图片罢了。

之后，让训练好的自回归模型生成一串新的 Token 序列。把这串 Token 扔给第一步训练好的Decoder。Decoder 把这些Token生成一张全新的高清图片。

只要我们能把图片有效地Token化，就能让自回归方法也能生图。

![lecture_14, 页面 121](files/slides/CS231n/lecture_14.pdf#page=121)

---
## VAE

> Model can compute P(x), but just Approximate P(x)

1.  **背景**：生成模型的目标是让模型生成的概率分布 $p(x)$ 最大化。
2.  **显式模型（如 PixelRNN）**：它们直接把 $p(x)$ 写成一串条件概率的乘积，公式明确，可以直接计算和优化。
3.  **VAE 的不同**：VAE 定义了一个包含**隐变量 $z$** 的概率模型，这使得计算变得更复杂。
4.  **遇到的困难**：在 VAE 中，真实的概率密度 $p(x)$ 需要对隐变量进行积分，这个积分通常是**不可解的（Intractable）**，没法直接算。
5.  **解决方案**：既然直接算 $p(x)$ 很难，我们就不直接算它了。
6.  **核心策略**：我们转而去优化 $p(x)$ 的一个**下界（Lower Bound）**，也就是著名的 **ELBO**。
7.  所以，只要把这个下界推得足够高，真实的概率也会跟着变高，从而达到训练模型的目的。

![lecture_13, 页面 61](files/slides/CS231n/lecture_13.pdf#page=61)

### (Non-Variational) Autoencoders


> Autoencoding = Encoding yourself
> Idea: Unsupervised method for learning to extract features z from inputs x, without labels

Features should extract useful information (object identity, appearance, scene type, etc) that can be used for downstream tasks. Encoder will extract those features.

> Problem: How can we learn without labels?
> Solution: Reconstruct the input data with a decoder.

Encoder and Decoder can be MLP, CNN, Transformer, …

这里，Decoder将重建x，使z变为x。这里input和output用损失函数优化，尽量相等。
但是，我们在这大费周章训练，最后就是一个identity function?
事实上，我们这里是想让NN在受限的情况下去学习一些non-trivial structure from data。
我们所需要做的就是赋予其一个bottleneck，这里就是让z的长度远比x小。
==训练好之后，就可以用Encoder去做下游任务，行self-supervised故事。==
![lecture_13, 页面 66](files/slides/CS231n/lecture_13.pdf#page=66)

> 反其道而行之

如果我们并不是想用Encoder去做提取feature的内容，而是想生成内容呢？
那我们就可以反其道而行之，丢掉Encoder，保留Decoder。只要我们能获取z，就能生成新的x。
但是问题是，z作为一个中间的生成物，并不好生成。我们没有z的dataset去训练。
所以，VAE想法是，我们可否强制这个z符合某种我们已知的分布呢？

![lecture_13, 页面 70](files/slides/CS231n/lecture_13.pdf#page=70)

###  Variational Autoencoder (VAE)

> So forcing these autoencoder to be probabilistic and to enforce a probabilistic structure on that latent space exactly is the VAE tries to do.

Intuition: x is an image, z is latent factors used to generate x: attributes, orientation, etc.
If we had a dataset of (x, z) then train a conditional generative model $p_{\theta}(x | z)$

我们假设latent factors隐变量服从某个简单的分布$p_{\theta}$，比如Gaussian标准正态分布。
我们把抽出来的 $(x,z)$ 喂给一个NN，这个网络代表条件概率 $p_{\theta}(x|z)$。我们将其训练为conditional generative model $p_{\theta}(x | z)$。
$p_{\theta}(x|z)$ we can compute this with the decoder。这个分布的参数$\theta$我们可以通过训练得知。

我们使用最大似然估计去训练模型，让它生成真实数据 $x$ 的概率 $p_{\theta}(x)$ 最大（最大似然估计）。
因为我们不知道每张图具体对应的 $z$ 是什么（$z$ 是未观测的），所以我们需要考虑**所有可能的 $z$**。
这就引入了积分公式：$p_{\theta}(x) = \int p_{\theta}(x|z)p_{\theta}(z) dz$。这个公式的意思是：把所有可能的 $z$ 都试一遍，看看它们生成 $x$ 的概率是多少，然后加起来（积分）。积分中分布$p_{\theta}$本身以及参数都是可知的，但是dz无法计算。

> **"Problem, we can't integrate over all z"**。
> $z$ 是一个高维向量，空间大得没边。要穷举所有可能的 $z$ 进行积分，计算量是无穷大的，根本算不完。

![lecture_13, 页面 80](files/slides/CS231n/lecture_13.pdf#page=80)

> 再尝试用贝叶斯

这里，$p_{\theta}(x|z)以及p_{\theta}(z)$都是可以计算的，但是$p_{\theta}(z|x)$难以计算。其代表**后验概率 (Posterior)**：给定图片x ,它是由哪个z生成的？
算不出来？那我们就再训练一个神经网络去近似它！
![lecture_13, 页面 86](files/slides/CS231n/lecture_13.pdf#page=86)



所以如下图所示，虽然看起来神经网络输出"ditribution"看起来很怪，但是我们只需要让他们输出分布的参数即可。

Decoder神经网络实际上输出的是这个分布的**均值** $\mu_{x|z}$（也就是生成的图片像素值）。方差 $\sigma^2$ 一般是固定的。
Encoder 神经网络输出两个向量：**均值 $\mu$** 和 **方差（或对角协方差）$\Sigma$**。$q$是学习出来的分布。
这就定义了一个概率分布，告诉我们：“这张图片的特征大概率在这个均值附近，不确定性是这么多”。

![lecture_13, 页面 91](files/slides/CS231n/lecture_13.pdf#page=91)

而且，Maximizing $logp_{\theta}(x|z)$  is equivalent to minimizing L2 distance between x and network output!
下文中，我们的z就可以看作是符合正态分布的随机噪声。
> [!question] 为什么两者是equivalent的？
> 均方误差损失函数（简称均方损失）可以用于线性回归的一个原因是： 我们假设了观测中包含噪声，其中噪声服从正态分布。
> $$y = \mathbf{w}^\top \mathbf{x} + b + \epsilon,\epsilon \sim \mathcal{N}(0, \sigma^2)$$
> $$\epsilon = y-\mathbf{w}^\top \mathbf{x} - b$$
>$$P(\epsilon) = \frac{1}{\sqrt{2 \pi \sigma^2}} \exp\left(-\frac{\epsilon ^2}{2 \sigma^2}\right).$$
> 如上可知$y与\epsilon 一一映射$，固定$\mathbf{x}$时，$y$的随机性由$\epsilon$决定，故有$$P(y \mid \mathbf{x}) = P(\epsilon)$$
> 则有：$$P(y \mid \mathbf{x}) = \frac{1}{\sqrt{2 \pi \sigma^2}} \exp\left(-\frac{1}{2 \sigma^2} (y - \mathbf{w}^\top \mathbf{x} - b)^2\right).$$
> 
> 根据极大似然估计法，参数w和b的最优值是使整个数据集的**似然**最大的值:$$P(\mathbf y \mid \mathbf X) = \prod_{i=1}^{n} p(y^{(i)}|\mathbf{x}^{(i)}).$$
> (使这个概率和最大，使得$\mathbf{y}$出现概率最大的那个参数值$\mathbf{X}$就是最合理的值)
> 
> 根据最大似然估计，我们最大化，相当于最小化负对数似然。
> 取最小化负似然对数方便计算，则有:$$-\log P(\mathbf y \mid \mathbf X) = \sum_{i=1}^n (\frac{1}{2} \log(2 \pi \sigma^2) + \frac{1}{2 \sigma^2} \left(y^{(i)} - \mathbf{w}^\top \mathbf{x}^{(i)} - b\right)^2)$$
>第一项不依赖于w和b，第二项与均方误差形式相同
> **平方误差损失函数背后隐含了一个数据噪声服从高斯分布的假设**

#### ELBO-数学部分

> 比较长，嫌烦可以不看

**Step 1: 利用贝叶斯公式展开**
$$
\log p_\theta(x) = \log \frac{p_\theta(x|z)p(z)}{p_\theta(z|x)}
$$

**Step 2: 引入近似后验 $q_\phi(z|x)$（分子分母同乘）**
$$
= \log \frac{p_\theta(x|z)p(z)q_\phi(z|x)}{p_\theta(z|x)q_\phi(z|x)}
$$

**Step 3: 利用对数性质拆分项**
$$
= \log p_\theta(x|z) - \log \frac{q_\phi(z|x)}{p(z)} + \log \frac{q_\phi(z|x)}{p_\theta(z|x)}
$$

**Step 4: 引入期望 (Expectation)**
$$
\log p_\theta(x) = E_{z \sim q_\phi(z|x)} [\log p_\theta(x)]
$$

**Step 5: 提取期望 (Expectation)**

$$
= E_{z} [\log p_\theta(x|z)] - E_{z} \left[ \log \frac{q_\phi(z|x)}{p(z)} \right] + E_{z} \left[ \log \frac{q_\phi(z|x)}{p_\theta(z|x)} \right]
$$

**Step6：引入 [KL散度](Linear%20Classification%20intro.md#KL散度)（最终的 ELBO 形式 + 误差项）**
$$
= E_{z \sim q_\phi(z|x)} [\log p_\theta(x|z)] - D_{KL}(q_\phi(z|x) \| p(z)) + D_{KL}(q_\phi(z|x) \| p_\theta(z|x))
$$

---
解释一下这个数学期望，如果我们不是求 $x$ 本身的平均值，而是求 $x$ 的某个函数 $g(x)$（比如 $\log p(x)$）的平均值：

$$ E_{x \sim P(x)}[g(x)] = \int g(x) \cdot P(x) \, dx $$

*   **直观理解**: 在 $P(x)$ 这个概率分布下，算出来的 $g(x)$ 平均是多少。
*   这就是为什么 $D_{KL}(Q||P) = \int Q(x) \log \frac{Q(x)}{P(x)} dx$ 可以写成 $E_{x \sim Q} [\log \frac{Q(x)}{P(x)}]$。
$logp_{\theta}(x)$完全不包括z，这里完全是一个常数，这个期望是为了**凑公式**。
因为上面的等式右边（Step 3）包含了很多跟 $z$ 有关的项（比如 $\log p_\theta(x|z)$）。为了对整个等式进行下一步的化简（特别是利用 KL 散度），我们需要把整个等式都放在“对 $z$ 求期望”的框架下。等会两边公式在数学上保持一致。

---
> 所以我们最终有：
$$ \log p_\theta(x) = \underbrace{E_{z \sim q_\phi(z|x)}[\log p_\theta(x|z)]}_{\text{Data Reconstruction}} - \underbrace{D_{KL}(q_\phi(z|x) \| p(z))}_{\text{Regularization}} + \underbrace{D_{KL}(q_\phi(z|x) \| p_\theta(z|x))}_{\text{Error}} $$

> 第一项：Data Reconstruction

$$
\underbrace{E_{z \sim q_\phi(z|x)}[\log p_\theta(x|z)]}_{\text{Data Reconstruction}}
$$

-   $z \sim q_\phi(z|x)$: 让 Encoder 根据图片 $x$ 猜出一个隐变量 $z$。
-   $\log p_\theta(x|z)$: 让 Decoder 根据这个 $z$ 把图片 $x$ 还原出来的概率。
-   x => encoder => decoder should reconstruct x. Can compute in closed form for Gaussians.
*   **直观理解**: 如果这一项很大，说明 Decoder 能很好地还原图片。这对应了自编码器里的 **Reconstruction Loss**

> 第二项：KL 散度正则化 (KL Divergence Regularization)

$$- \underbrace{D_{KL}(q_\phi(z|x) \| p(z))}_{\text{Regularization}}$$

The model is separately predicting distribution q of z given x , and we want those predicted distribution to match the simple Gaussian prior.
==So this is just measuring how much does that **latent space** that's learned by our model match the prior.==

这一项衡量了 Encoder 输出的分布 $q_\phi(z|x)$ 与我们设定的先验分布 $p(z)$有多大的差异。

>  第三项：Posterior Approximation

$$+ \underbrace{D_{KL}(q_\phi(z|x) \| p_\theta(z|x))}_{\text{Error}}$$

*   **含义**: 这是 Encoder 预测的分布 $q$ 与真实的后验分布 $p$ 之间的差距。很难计算
*   **关键点**:
    *   KL 散度永远 $\ge 0$。
    *   因此，如果我们把这一项扔掉（因为它很难算，且肯定是正的），剩下的部分（第一项 - 第二项）就一定 $\le \log p_\theta(x)$。
    *   剩下的这两项，就是我们要找的 **下界 (Lower Bound)**，也就是 **ELBO**。

**总结：**
我们无法直接最大化 $\log p(x)$，但我们可以最大化 **ELBO**：
**ELBO = 重建质量 (Reconstruction) - 正则化惩罚 (KL Divergence)**。
直觉上来讲，就是重建质量要高的同时，Encoder 输出的分布 $q_\phi(z|x)$ 与我们设定的先验分布 $p(z)$之间差异要尽量小。

![lecture_13, 页面 102](files/slides/CS231n/lecture_13.pdf#page=102)

#### VAE-Trainging

![lecture_13, 页面 103](files/slides/CS231n/lecture_13.pdf#page=103)

1. 编码
- 把图片 $x$ 喂给 Encoder 网络。 得到两个向量：**均值 $\mu_{z|x}$** 和 **方差$\Sigma_{z|x}$**。这样我们就确定了 $z$ 的概率分布 $q_\phi(z|x)$。

2. 计算 Prior Loss (KL 散度)
*  计算 Encoder 输出的这个分布 $N(\mu, \Sigma)$ 和标准正态分布 $N(0, I)$ 之间的 **KL 散度**。这一项有现成的数学公式，可以直接算出来，不需要采样。惩罚 Encoder，让它输出的分布尽量接近标准正态分布（正则化）。

3. 采样 (Sampling with Reparameterization Trick)
*   **问题**: 我们有了分布，需要从中采样一个 $z$ 给 Decoder。但随机采样`random()`是不可导的，反向传播会断掉。所以我们需要使用重参数化技巧。先从标准正态分布里采样一个噪声 $\epsilon \sim N(0, I)$。然后算 $z = \mu + \epsilon \cdot \Sigma^{1/2}$ （平移 + 缩放）。这样，$z$ 依然服从那个分布，但 $\epsilon$ 是常数，$\mu$ 和 $\Sigma$ 是变量，梯度就可以传回去了。

4. 解码 把采样得到的 $z$ 喂给 Decoder 网络。得到重建图片的参数，通常是图片的**均值 $\mu_{x|z}$**。

5. 计算 Reconstruction Loss (重建误差)。比较 Decoder 输出的重建图片 $\mu_{x|z}$ 和原始图片 $x$。
*   **计算**: 如果假设输出服从高斯分布，这等价于计算它们之间的 **L2 距离。

最后把 KL 惩罚和重建误差加起来作为总 Loss，反向传播更新参数。
![lecture_13, 页面 109](files/slides/CS231n/lecture_13.pdf#page=109)

---

> The loss terms fight against each other!

VAE 的总损失函数（ELBO）由两部分组成，它们对 Encoder 的要求是截然相反的：
*  重建损失的目标是想让 $z$ 包含关于 $x$ 的一切精确信息，这样 Decoder 才能完美复原图片。理想状态是方差 $\Sigma = 0$**：最好没有任何随机性，变成一个确定的点。**均值 $\mu$ 独特**：每张图片 $x$ 都要有一个独一无二的 $z$。
*  先验损失 (Prior Loss, 蓝色部分)想让 $z$ 看起来像是一个标准的,服从正态分布的随机噪声。

VAE 的训练过程就是在这两股力量之间寻找平衡点：
$z$ 既要有一定的规律性（服从正态分布，方便采样生成），又要包含足够的信息（均值和方差略有偏移，携带图片特征）。

**总结：** VAE 实际上是在做一个**有损压缩**。我们强迫编码器把图片压缩成一个“带有噪声的代码”，这种噪声迫使编码器只保留最重要的特征，从而学到了数据的本质结构。

当然，作为生成式模型，最后生成的时候从符合分布的z中sample，传递给训练好的decoder就可以了。
![lecture_13, 页面 110](files/slides/CS231n/lecture_13.pdf#page=110)

## Generative Adversarial Networks (GANs)

> Model Can not compute p(x) but can directly sample from P(x)

The GAN is trying to force the $p_{G}$ Generator distribution, which is induced by our generated Network. 
We want the $p_{G}$ distribution to match the true $p$ data distribution as close as possible.

但是如何使 $p_{G}$ 逼近 $p$ 呢？VAE以及自回归模型中，我们会使用一个可以优化的函数来让模型完成逼近分布这件事。
但是GAN中，则是训练两个互相对抗的神经网络。Generator G会生成符合$p_{G}$分布的，来源于符合分布 $p$ 的随机噪声$z$的假数据。
而Discriminator Network D则要分辨出这个生成的数据是真是假。两个网络在对抗中提升性。 
![lecture_14, 页面 15](files/slides/CS231n/lecture_14.pdf#page=15)

Discriminator D希望可以max最大化这个公式的值。
所以，左半部分肯定是$D(x)越接近1越好，辨别为真最好，这样log值大$。因为$x是从真实分布中p_{data}拿出来的新图$。
而右半部分则是$D(G(z))越接近0越好，辨别为假最好，这样log值大$，因为$G(z)是生成器G用z造出来的假图$。
![lecture_14, 页面 18](files/slides/CS231n/lecture_14.pdf#page=18)

左半部分和G无关，因为左半部分是discriminator D 负责分辨数据真假的部分。
G希望最小化这个值，所以G希望右半部分$D(G(z))越接近1越好，辨别为真最好，这样log值小$，因为$G(z)是生成器G用z$造出来的假图。$D(x)$将其辨别为真说明G成功骗过了D。
![lecture_14, 页面 19](files/slides/CS231n/lecture_14.pdf#page=19)

> GAN的问题

所以，我们可以把这整个公式写为$min_{G}max_{D}V(G,D)$ , G,D的梯度更新则有：
$D = D + \alpha_D \frac{dV}{dD}$ (最大化，所以是加号)。 $G = G - \alpha_G \frac{dV}{dG}$(最小化，是减号)。
但V毕竟不是正儿八经的损失函数，V得出来的值没有什么意义，我们不能像看其他损失函数得出来的值那样直接就能判断出来我们训练的到底好不好。

We are not minimizing any overall loss! No training curves to look at!
It is really hard to train, to tune, to make progress...

而且，从图中我们可以看到，Generator 一开始的曲线是很平滑的(Gradients for G are close to 0)，所以难以训练。
当然，训练完成过后我们把discriminator去掉，只使用generator生成即可。
![lecture_14, 页面 25](files/slides/CS231n/lecture_14.pdf#page=25)

> 为什么minimax函数是一个好的目标函数？

Inner Objective : 如果我们先把生成器 $G$ 固定住，生成的图水平已经不变了，那么**使V最大的判别器 $D_G^*(x)$ 是什么样的？**
那我们则有：
$$ D_G^*(x) = \frac{p_{data}(x)}{p_{data}(x) + p_G(x)} $$
这好像需要复杂的数学推导？如果从直觉的角度来讲，$D_G^*(x)$如果是0，说明生成的图是真实数据中基本没有的。如果是1，说明生成的图是生成器基本不生成，而真实数据中常有的。只有输出是0.5，也即$p_{G​}(x)=p_{data​}(x)$时，D是分不清生成器的图与真实图的区别的，这个时候，我们的目标也就达到了。

Outer Objective: 当$p_{G​}(x)=p_{data​}(x)$时，V取得最小。即当**生成器的分布完全变成了真实数据的分布**时，这个目标函数才能达到最小值。

> [!warning]
> *   理论假设 $G$ 和 $D$ 可以是任意函数。但实际上它们只是神经网络，能力有限，可能根本无法拟合出 $G$ 和 $D$。
> *   理论并不能指导我们如何使用有限的数据去converge到Solution。
> *   GAN 的训练非常不稳定，经常出现震荡、模式坍塌（Mode Collapse），很难收敛到这个理论最优解。

![lecture_14, 页面 29](files/slides/CS231n/lecture_14.pdf#page=29)

生成器D和G是神经网络，一般用CNN，也可以用更复杂的[结构](files/slides/CS231n/lecture_14.pdf#page=32)。

而且，GAN学到的噪声z所在的[隐空间](files/slides/CS231n/lecture_14.pdf#page=34)是smooth的。这是什么概念呢？也就是说：

1.  如果你找两个噪声点 $z_0$ 和 $z_1$，分别生成图片 $G(z_0)$ 和 $G(z_1)$。
2.  然后在 $z_0$ 和 $z_1$ 之间慢慢过渡（插值），得到一系列中间的 $z_t$。
3.  把 $z_t$ 给生成器，你会看到生成的图片也在**平滑地变形**（比如从一只猫慢慢变成另一只狗），而不是突然跳变或者变成乱码。
4.  这说明GAN真正的理解了图像的内在结构，而不是只关注在无聊的像素上。

> [!NOTE] VAE vs GAN
> So, what is the relationship between your training dataset and your latents?
> Generator gives you a mapping from latent space into data space, maps from z to x. But with GANs you in general have no way to map back from x to z.
> ==VAE will learn a explicit way mapping from z to x, but GAN have no such thing.==
> 
> In VAE, we get latent space, but we gave up density. In GAN, we seem to gave up latent vector, but we get much better samples. VAE's sample are always blurry, but GAN can get very crisp and clean samples.
> 
> VAE 的强项在于它能帮你得到一个非常规范、好用的隐空间 $z$（用来做特征提取、降维都很好）。放弃了density有点不准确(we have ELBO)，VAE确实有点blurry，可能是因为均方误差？或是MLE？
> 标准的 GAN 并没有一个 Encoder 网络。给你一张真图 $x$，你没法直接知道它对应的 $z$ 是什么。所以说它“放弃”了作为一个特征提取器的功能。GAN 强项在生成上。判别器逼着生成器去生成**极其清晰、锐利 (Crisp and Clean)** 的图片。因为只有足够清晰，才有可能骗过判别器。

日后，Diffusion Model取代了GAN。
![lecture_14, 页面 35](files/slides/CS231n/lecture_14.pdf#page=35)

---
## Diffusion

### intro

diffusion model现在的用处很多，例如：文生图以及文生视频。
![lecture_14, 页面 102](files/slides/CS231n/lecture_14.pdf#page=102)

Text-to-Video的训练很昂贵，因为相比于图，视频可以说直接多了一个时间序列，让训练sequence变的很长。
2025年可称之为[The Era of Video Diffusion Models](files/slides/CS231n/lecture_14.pdf#page=106)。
![lecture_14, 页面 105](files/slides/CS231n/lecture_14.pdf#page=105)

---

> [!danger]
> 注意！这部分的各种术语以及数学公式奇多！我们只能做一个基础的，直觉上的介绍！

1.  **定义噪声分布**：首先选择一个**噪声分布** $z \sim p_{noise}$，通常使用的是单位高斯分布（Unit Gaussian）。

2.  **前向过程**：考虑原始数据 $x$ 在不同的**噪声水平** $t$ 下被逐渐破坏（腐蚀），从而得到一系列带噪数据 $x_t$。
    *   对应右图：时间 $t$ 从 0 增加到 1，猫的图片从清晰（No noise）逐渐变成完全的噪点（Full noise）。

3.  **训练目标（学习去噪）**：训练一个神经网络，其任务是**去除一点点噪声**。这个网络表示为 $f_\theta(x_t, t)$。

4.  **推理过程（生成数据）**：在推理阶段，首先从噪声分布中采样得到一个初始噪声 $x_1$（对应右图底部的 Full noise）。然后**按顺序多次应用**训练好的神经网络 $f_\theta$，一步步去除噪声，最终生成一个无噪的样本 $x_0$。

![lecture_14, 页面 41](files/slides/CS231n/lecture_14.pdf#page=41)

---
### Rectified Flow 

> 扩散模型的一种新视角：Rectified Flow 。

$p_{noise}$ is something simple that we understand, we can sample from, we can compute integrals of. It is a very friendly distribution.

$p_{data}$ is something crazy. That's what the universe is using to give us images.

1.  假设两个分布：我们有一个简单的噪声分布 $p_{noise}$（蓝色椭圆，通常是高斯分布），以及真实的样本分布 $p_{data}$（红色椭圆）。
2.  训练迭代过程：在每一次训练迭代中，我们进行以下采样：从噪声分布中采样一个点 $z \sim p_{noise}$。从真实数据中采样一个点 $x \sim p_{data}$。从 0 到 1 之间均匀采样一个时间点 $t \sim Uniform[0, 1]$。
3.  定义插值路径与速度： **$x_t$ (插值点)**：我们在真实数据 $x$ 和噪声 $z$ 之间画一条直线，根据时间 $t$ 找到中间的一个点。公式为：
        $$ x_t = (1-t)x + tz $$
       **$v$ (速度/方向)**：这个向量代表从 $x$ 指向 $z$ 的方向。
        $$ v = z - x $$

4.  **训练目标**：训练一个神经网络 $f_\theta$ 来**预测这个速度向量 $v$**。损失函数是预测值与真实速度之间的均方误差：
    $$ L = \| f_\theta(x_t, t) - v \|_2^2 $$

![lecture_14, 页面 45](files/slides/CS231n/lecture_14.pdf#page=45)

> Core training loop is just a few lines of code!

```python
for x in dataset:
    z = torch.randn_like(x) # p_noise
    t = random.uniform(0, 1)
    xt = (1 - t) * x + t * z
    v = model(xt, t)
    loss = (z - x - v).square().sum() # z-x是实际值，v是model的预测值
```

> 推理阶段

但是，让模型预测这个v值有什么用？看起来不太直观。这也是diffusion model复杂于GAN的地方。

这里选了 $T=50$ 步。

1.  起点 (Sample x ~ p_noise) `sample = torch.randn(x_shape)`
    *   我们要从纯噪声开始。就像在一张白纸上先撒满随机的噪点。这就是图中的 **$x_1$** (注意这里的 1 代表时间 $t=1$)。

2.  循环倒推 (For t in [1, ..., 0] `for t in torch.linspace(1, 0, num_steps):`
    *   我们从时间 $t=1$ (纯噪声) 开始，一步步走向 $t=0$ (真图)。

3.  预测方向 (Evaluate v_t `v = model(sample, t)`
    *   让训练好的模型预测“我现在在 $x_t$ 这个位置，时间是 $t$，从真图指向噪声的箭头（速度 $v$）是多少？”

4.  迈出一步 (Step x = x - v_t/T) `sample = sample - v / num_steps`
    *   **关键点**: 因为模型预测的 $v$ 是从真图指向噪声的方向（正向），我们要**生成图片**，所以我们要**反着走**。
    *   我们要**减去**速度 $v$。但我们不能一步到位，所以我们只减去 $v$ 的一小部分 ($1/T$)。
    *   通过这一步，我们的噪点图就变得稍微像真图了一点点（比如从 $x_1$ 走到了 $x_{2/3}$）。

5.  重复这个过程 50 次，我们就会沿着那条直线，从蓝色的噪声区域一步步挪到红色的真实数据区域，最终得到 **$x_0$**，也就是生成的清晰图片。

---

![lecture_14, 页面 56](files/slides/CS231n/lecture_14.pdf#page=56)

> Conditional Rectified Flow

其实就是加上了label标签y。
![lecture_14, 页面 61](files/slides/CS231n/lecture_14.pdf#page=61)

但是，我们可否控制模型关注标签的程度？如果不行，那么模型可能有很多时候训练的并不如我们意。
所以，我们可以采用一种叫做Classifier-Free Guidance (CFG)的方法。

*   **常规操作**: 我们有训练数据对 `(x, y)`，其中 `x` 是图片，`y` 是描述这张图片的文本（Prompt）。
    `if random.random() < 0.5: y = y_null`
    *   在训练时，我们会以一定的概率（比如 50%），**故意把文本条件 $y$ 扔掉**，替换成一个空的条件 `y_null`。
    *  这迫使同一个模型学会两件事：根据label $y$ 生成图片，以及如同原来无标签label时生成图片。


在推理生成图片时，我们想加强文本 $y$ 的控制力。我们计算两个方向：

1.  **无条件方向 ($v^\emptyset$)**:   $v^\emptyset = f_\theta(x_t, y_\emptyset, t)$  以及**有条件方向 ($v^y$)**:$v^y = f_\theta(x_t, y, t)$
2.  **CFG 引导方向 ($v^{cfg}$)**:
    *   **公式**: $v^{cfg} = (1 + w)v^y - w v^\emptyset$ 或者写成更容易理解的形式：$v^{cfg} = v^\emptyset + (1 + w) \times (v^y - v^\emptyset)$。
    *   **含义**: 我们算出“有条件”相对于“无条件”的**差异**（$v^y - v^\emptyset$），然后把这个差异**放大**（乘以 $1+w$），再加回到无条件方向上。$w$是超参数。

代码如下：
```python
y = user_input()
sample = torch.randn(x_shape)
for t in torch.linspace(1, 0, num_steps):
    vy = model(sample, y, t)
    v0 = model(sample, y_null, t)
    v = (1 + w) * vy - w * v0
    sample = sample - v / num_steps
```

CFG Used everywhere in practice! Very important for high-quality outputs.
CFG有一个缺点，就是Doubles the cost of sampling…
![lecture_14, 页面 67](files/slides/CS231n/lecture_14.pdf#page=67)

> Optimal Prediction

   **$t=1$ (纯噪声)**: 这时候 $x_t$ 几乎就是噪声。所有真实数据的平均值大概就是整个数据集的中心。optimal v很好找
*   **$t=0$ (无噪声)**: 这时候 $x_t$ 就是真图。optimal v is mean of $p_{noise}$
*   **$t \approx 0.5$ (中间状态)**: 这时候最难。图片既不像真图也不像噪声，模糊不清，歧义最大（最 Ambiguous）。模型最容易在这里感到困惑。就像图上所示，难以找到最佳方向。

> **"There may be many pairs (x, z) that give the same x_t; network must average over them"**

看图，中间那个紫色的点 $x_t$（带噪数据）。它可以是由左下角的三角形 $x$ 加上某个噪声 $z$ 变成的。也可以是由右下角的正方形 $x$ 加上另一个噪声 $z$ 变成的。当模型只看到 $x_t$ 时，它不知道该选择什么方向去优化。

> **But we give equal weight to all noise levels! Use a non-uniform noise schedule**

`t = random.uniform(0, 1)`。我们在训练时，**均匀地**让模型去学简单阶段（$t=0, t=1$）和困难阶段（$t=0.5$）。
这显然不是最高效的。既然中间阶段最难、最有信息量，那我们就应该**多花点时间练中间阶段，少花点时间练两头**。

![lecture_14, 页面 79](files/slides/CS231n/lecture_14.pdf#page=79)

我们可以改变采样 $t$ 的分布（不再是均匀分布），让模型更多地在那些重要的，比较难的 $t$ 值上进行训练。这就是**非均匀噪声调度 (Non-uniform noise schedule)** 的意义。如图的蓝色分布是比较常用的。
![lecture_14, 页面 84](files/slides/CS231n/lecture_14.pdf#page=84)

---
### Latent Diffusion Models (LDMs)

LDMs的思路是，先训练Encoder+decoder将图片信息提取到隐空间。Encoder / Decoder are CNNs with attention.
训练diffusion的思路是，我们先用前面训练好的Encoder将图片信息提取至隐空间，之后再训练这个diffusion model去denoise这个noisy latent。
之后在推理的阶段，我们将random latent送至diffusion多次，得到一个去除了noise多次的clean sample in latent space。
之后再使用训练过的decoder，将这个clean latent转换为一个clean image。
![lecture_14, 页面 92](files/slides/CS231n/lecture_14.pdf#page=92)

> 如何训练Encoder和Decoder?

Encoder+Decoder部分我们使用VAE，因为VAE的latent space是比较平滑，规范，连续的。VAE对这里隐空间的约束详情请见[VAE-Trainging](Generative%20Models.md#VAE-Trainging)中对$z$的描述。
但是VAE的缺点在于:Decoder outputs often blurry，输出质量不高。所以在训练 VAE 的Decoder时，**加入 GAN 的判别器** ！Encoder: 继续用 VAE 的规则，保证隐空间平滑。Decoder: 用 GAN 的规则，保证生成的图片清晰锐利。

==Modern LDM pipelines use VAE + GAN + diffusion!==
![lecture_14, 页面 96](files/slides/CS231n/lecture_14.pdf#page=96)

---
###  Diffusion Transformer (DiT)

它的核心思想是：将diffusion中的CNN替换为Transformer
既然换成了 Transformer，我们面临的一个最大的问题就是：**如何把时间步 $t$、文本标签 $y$ 这些条件信息（Conditioning）喂给 Transformer？**

> Scale/Shift 自适应层归一化 (Adaptive Layer Normalization)。

这是 DiT 最标志性的做法。把条件信息（比如时间 $t$ 和标签 $y$）通过一个小型的 MLP 网络。MLP 输出两个参数：**缩放因子 $\gamma$ (Scale)** 和 **偏移量 $\beta$ (Shift)**。用这两个参数去调节 Transformer 内部 Layer Norm 层的输出。
 公式：$Output = \gamma \times Norm(x) + \beta$。条件信息通过控制整个神经网络层的缩放和偏移来影响图像生成的过程。

> Cross-Attention 

这是 Stable Diffusion 的做法。在 Transformer 块里插入一个新的层：Cross-Attention。
图像特征作为 Query，条件信息（文本 embedding）作为 Key 和 Value。这种方法适合处理很长的文本描述，因为 Cross-Attention 能让图像专注于文本中最相关的词。

> Concatenate (拼接) Joint Attention

把条件当成额外的 token。直接把条件信息的 embedding 拼接到图像 token 序列的开头或结尾。
![lecture_14, 页面 100](files/slides/CS231n/lecture_14.pdf#page=100)

> Diffusion Distillation 

Diffusion模型的生成图的过程较慢，即使是rectified flow也需要迭代个30-50次，所以我们可以采取蒸馏技术。
“So distillation is an algorithm are basic ways that you can take a diffusion model that normally would take 30-100 iterations at inference time to get good samples and then modify the model in some way such that you can take many fewer steps on inference and still get good samples.”
蒸馏技术牺牲了一点质量，压缩步骤，换来了更快的速度，下方有很多文献references推荐阅读，在此不详谈。
![lecture_14, 页面 108](files/slides/CS231n/lecture_14.pdf#page=108)

---
### Math and Explain of Diffusion

> Generalized Diffusion 泛化Rectified Flow中的参数

slides往下翻，有什么VP,VE,x-prediction,在此不一一列举。
![lecture_14, 页面 111](files/slides/CS231n/lecture_14.pdf#page=111)

> So... How do we choose these functions? Usually through some **mathematical formalism**

数学又回来了。以下有好几种对Diffusion Model的解释。

> Diffusion is a Latent Variable Model

从概率论的视角重新审视扩散模型（Diffusion Models），reference的论文指出它本质上是一种**隐变量模型 (Latent Variable Model)**，并且和 VAE 是亲戚。

*   **$x_0$**: 这是我们能看到的真实数据（比如那张人脸照片）。
*   **$x_1, x_2, ..., x_T$**: 这些中间状态和最终的噪声图，都是我们看不见的、或者说是为了生成 $x_0$ 而假设存在的**隐变量 (Latent Variables)**。这和 VAE 里的 $z$ 是一样的角色。

“We know the forward process: Add Gaussian noise”
*   **$q(x_t | x_{t-1})$**：这是前向过程。前向过程是不需要学习的，每一轮都按固定的比例往图上加高斯噪声。这相当于 VAE 中的 Encoder，但这回 Encoder 不需要训练，直接用公式算就行。

“Learn a network to approximate the backward process”

*   **$p_\theta(x_{t-1} | x_t)$**：这是后向过程（去噪）。这就是我们要训练的神经网络。它的任务是：给我一个现在的噪声图 $x_t$，请帮我重建上一时刻稍微清晰一点的图 $x_{t-1}$ 是什么样子的。这相当于 VAE 中的 Decoder。

“Optimize variational lower bound (same as VAE)”
*   既然它是隐变量模型，训练它的数学原理就和 VAE 一模一样：我们都要最大化数据的对数似然（Log-Likelihood）。
*   但是那个积分很难算（Intractable），所以我们退而求其次，去最大化它的下界 **ELBO**。

扩散模型不是旱地拔葱出来的，它在数学根基上和 VAE 是一家人。
*   **VAE**: 学习 Encoder (压缩) 和 Decoder (还原)。
*   **Diffusion**: Encoder 是固定的加噪公式 (毁图)，只学习 Decoder (修图)。而且这个修图过程被拆成了很多小步。

![lecture_14, 页面 116](files/slides/CS231n/lecture_14.pdf#page=116)

> Diffusion Learns the Score Function

理解扩散模型的第二个视角：基于分数生成的视角 (Score-based Generative Modeling)。
从数学本质上看，**扩散模型实际上是在学习数据的“分数函数 (Score Function)”**。

这个视角把生成图片的过程，看作是在高维空间中“顺着梯度往上爬”的过程。

> 什么是 Score Function？

我们想知道任何一张图片 $x$ 的真实度是多少，用概率密度 $p(x)$ 表示。
但 $p(x)$ 很难算，所以我们转而计算它的**对数梯度**，这就是 **Score Function**：
$$ s(x) = \nabla_x \log p(x) $$

*   **它的含义**：这是一个**向量场**。在数据空间的任何一点 $x$，它都提供了一个方向。
*   **它的作用**：这个方向指向 $p(x)$ **增长最快**的地方。也就是说，顺着这个方向微调图片像素，图片会变得更像真图。

我们怎么训练神经网络去算出这个梯度 $s(x)$ 呢？扩散模型做的事情本质上就是这个：

$$ \epsilon_\theta(x_t, t) \approx -\sigma \cdot \nabla_{x_t} \log p(x_t) $$

*   左边为神经网络预测出的噪声，右边为Score Function（梯度）的负方向。
*  当我们给图片加噪时，是把图片往“低概率、混乱”的方向推。神经网络学会了去除这个噪声，其实就是学会了**如果不加这个噪声，图片本来应该长什么样**。这恰恰就是指向数据真实分布的梯度方向。

一旦模型训练好，它就掌握了整个空间的地形图。生成过程就是 **Langevin Dynamics（郎之万动力学）**：

1.  **起点**：随机扔一个点 $x_0$（纯噪声），它在概率极低的地形图山谷中。
2.  **迭代**：让神经网络预测往哪走概率更高，模型计算出梯度 $\nabla_x \log p(x)$。我们让 $x$ 顺着这个梯度走小步。
3.  **终点**：重复很多步后，$x$ 就会爬到概率最高的山顶，也就是变成了真实的图片数据。

==扩散模型通过学习如何去噪，间接学习到了数据分布的**梯度场（Score Function）**。==
==生成过程就是利用这个梯度场，把随机噪声一步步推向真实数据分布的过程。==

![lecture_14, 页面 117](files/slides/CS231n/lecture_14.pdf#page=117)

> Diffusion Solves **Stochastic Differential Equations**

这里理解扩散模型的**第三个视角（也是最高级、最统一的视角）**：**随机微分方程 (Stochastic Differential Equations, SDE)**。

这个视角把之前的离散步骤（Step 1, Step 2...）变成了连续的时间流。

> 什么是 SDE

SDE 是描述**随机过程**的数学方程，公式：$d\mathbf{x} = f(\mathbf{x}, t)dt + g(t)d\mathbf{w}$
*   **$f(\mathbf{x}, t)dt$ (漂移项 / Drift)**:代表数据随时间变化的**确定性趋势**。
*   **$g(t)d\mathbf{w}$ (扩散项 / Diffusion)**: 代表随时间加入的**随机噪声**。

*   **前向过程 (加噪)**:
    *   这就是一个 SDE 过程。随着时间 $t$ 从 0 流向 $T$，图片 $x$ 不断受到漂移和扩散（噪声）的影响，最终变成纯噪声。
*   **反向过程 (生成)**:
    *   数学上有定理：**任何一个 SDE 都有一个对应的反向 SDE**。
    *   只要知道了某个时刻的**分数函数 (Score Function)**（也就是上面刚说的），我们就可以写出这个反向 SDE 的公式

> **"Diffusion learns a neural network to approximately solve this SDE"**

==训练扩散模型，本质上就是在学习那个**分数函数**。一旦学到了，我们就可以通过反向SDE逆向解决问题。==
通过神经网络，我们学会了如何把噪声重新变为图像。SDE 框架统一了之前所有的扩散模型变体。
所以，我们只要有噪声的分布和学习过的神经网络，我们就能随意地通过取样噪声无限输出图像。
![lecture_14, 页面 118](files/slides/CS231n/lecture_14.pdf#page=118)


