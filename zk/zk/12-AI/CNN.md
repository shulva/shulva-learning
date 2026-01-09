# CNN

> Two computational primitive that we can use to build convolutional Networks
> **Convolutional Layer and Pooling Layer**

![lecture_5, 页面 18](files/slides/CS231n/lecture_5.pdf#page=18)

原来最原始的图片分类方法只使用了Raw pixel value，但是图片自身是有自己的feature的
一个经典的feature representation/extractor是[Color Histogram](files/slides/CS231n/lecture_5.pdf#page=22&selection=13,0,13,7)，针对图片颜色的分布
另一个则是[Histogram of Oriented Gradients](files/slides/CS231n/lecture_5.pdf#page=23&selection=13,9,13,18)

> System A: feature extraction + learned network/linear classifier on top of your features
> System B: end to end neural networks

The difference is : A is designed by humans, B is learned via gradient descent.
本质上还是数据说话，Data-Driven Approach
![lecture_5, 页面 26](files/slides/CS231n/lecture_5.pdf#page=26)

> Interesting thing: Features depend on content , not on their location.

![lecture_5, 页面 106](files/slides/CS231n/lecture_5.pdf#page=106)

---
## CNN intro

尽管数据驱动方法非常有效，但是我们仍然需要设计神经网络的架构，比如computational graph中的opeartor sequence.

> if we transform the pixel of an image into a vector, the spatial structure of images is destroyed!
> image is two-dimensional

![lecture_5, 页面 28](files/slides/CS231n/lecture_5.pdf#page=28)

> Trained end-to-end with backprop + gradient descent

> [!NOTE] A bit of history
> Gradient-based learning applied to document recognition [LeCun, Bottou, Bengio, Haffner 1998]
> ImageNet Classification with Deep Convolutional Neural Networks (AlexNet) [Krizhevsky, Sutskever, Hinton, 2012]
> 2012 – 2020: ConvNets dominate [all vision tasks](files/slides/CS231n/lecture_5.pdf#page=35&selection=25,0,25,9)

![lecture_5, 页面 31](files/slides/CS231n/lecture_5.pdf#page=31)

> What happened after 2020?

![lecture_5, 页面 41](files/slides/CS231n/lecture_5.pdf#page=41)

## Convolutional Layer

当然，CNN仍有学习的价值。其一是可以帮助我们了解算法，建立直觉。其二是CNN仍然有广泛的应用。

So anything built on dot products is basically a template matching.
So the way that you should think about these fully connected layer is that we have a set of templates, each of the templates have the same size of the input. And the output is the template matching score between each one of our templates and the entire input.
所以在这里，$W$的每一行都可以看作是一个template。$y=Wx$相当于templates匹配的过程,全连接层就是一组可学习的模板匹配器

![lecture_5, 页面 47](files/slides/CS231n/lecture_5.pdf#page=47)

So CNN's templates is no longer to have the same shape as the input.
Instead, now our filters/templates will only look at a small subset of the input.
相比与将图像拉伸为一个向量，CNN会保留图像的空间信息。

we can think about that small fliter as a little chunk of image template.
**So we can transform problem to how much the sub part of the image match this template that we are learning in our 
convolutional fliter**

![lecture_5, 页面 51](files/slides/CS231n/lecture_5.pdf#page=51)

OK,fine.But deep learning need more compute...
当然，这里的number of filter and size of filter 都是超参数，属于我们在训练之前设置的。
filters就相当于Fully Connected Layer中的$W$,这些filters的初始化需要是随机的，不同的。如果都是相同的，那么在学习过程中这些filter也会一直是相同的。如果是初始化是不同的，他们则可以学习不同的image feature。

> Work on a batch of input images.it makes everything four-dimensional

![lecture_5, 页面 61](files/slides/CS231n/lecture_5.pdf#page=62)


> Simple ConvNet 

$C_{out}$ 参数大小取决于有多少个filter
但是上文的架构还有一个问题：Everything is all linear。所以我们需要通过激活函数引入非线性。

![lecture_5, 页面 65](files/slides/CS231n/lecture_5.pdf#page=65)

> What do Conv filters learn? we can **visualize** the first layer

The thing we see is that we often learn two kinds of filters in here.
One tends to be looking for colors.And the other category of filter we tend to see are looking for somehow the spatial structure of the images.But [Deep conv layers hard to visualize](files/slides/CS231n/lecture_5.pdf#page=69&selection=19,5,19,7).
![lecture_5, 页面 68](files/slides/CS231n/lecture_5.pdf#page=68)

> Solution of the shrink of Feature map
> we can add padding.It will cause problem on the borders, but it seems to be ok in a lot of cases.

![lecture_5, 页面 78](files/slides/CS231n/lecture_5.pdf#page=78)

---
### Receptive Fields

Each successive convolution adds K – 1 to the receptive field size 
With L layers the receptive field size is 1 + L * (K – 1)

So the **effective receptive fields** of a convolution is basically how many pixels in the original image has the opportunity to influence one activation of the network later on downstream.It grows linear with the number of layers.

![lecture_5, 页面 83](files/slides/CS231n/lecture_5.pdf#page=83)

So now, effective receptive fields is growing **exponentially** in the depth of the network.
![lecture_5, 页面 87](files/slides/CS231n/lecture_5.pdf#page=87)

---
### Convolution Summary and Example

Output volume size:32 = (32+2\*2-5)/1+1
Number of learnable parameters: Parameters per filter: 3\*5\*5 + 1 (for bias) = 76.10 filters, so total is 10 * 76 = 760
![lecture_5, 页面 93](files/slides/CS231n/lecture_5.pdf#page=93)

还有一些其他的，例如[Pytorch中的CNN](files/slides/CS231n/lecture_5.pdf#page=95),[1d convolution](files/slides/CS231n/lecture_5.pdf#page=97&selection=14,0,14,5),[3d convolution](files/slides/CS231n/lecture_5.pdf#page=97)
![lecture_5, 页面 94](files/slides/CS231n/lecture_5.pdf#page=94)

---
## Pooling Layer

池化层计算并不多，做的操作也是类似上文中提到的downsample
![lecture_5, 页面 101](files/slides/CS231n/lecture_5.pdf#page=101)

最常用的方法是这里的Max pooling,当然也有其他的算法。
池化层事实上是可能引入非线性的，Max pooling会引入，但Average pooling不会。
![lecture_5, 页面 102](files/slides/CS231n/lecture_5.pdf#page=102)

## CNN Architecture

### How to build CNN?

![lecture_6, 页面 9](files/slides/CS231n/lecture_6.pdf#page=9)

---
#### Normalization Layer

> scale / shift the input data

![lecture_6, 页面 11](files/slides/CS231n/lecture_6.pdf#page=11)

有多种不同的Norm方法如下，C的意思是Channel
![lecture_6, 页面 12](files/slides/CS231n/lecture_6.pdf#page=12)

---
#### Dropout

![lecture_6, 页面 15](files/slides/CS231n/lecture_6.pdf#page=15)

> How can this possibly be a good idea?

> [!NOTE] Another interpretation 
> Dropout is training a large ensemble of models (that share parameters). 
> Each binary mask is one model 
> An FC layer with 4096 units has 2\^4096 ~ 10\^1233 possible masks! Only ~ 10\^82 atoms in the universe...

drop out的一种解释是：防止特征（或神经元）之间形成过度依赖的关系。
![lecture_6, 页面 16](files/slides/CS231n/lecture_6.pdf#page=16)

> At test time all neurons are active always  
> We must scale the activations so that for each neuron: output at test time = expected output at training time

可以理解为因为dropout,神经元的输出能力被增强了, 测试时的输出比训练时的期望输出大了 `1/p` `倍。
为了让test time时的输出 = 训练时期望输出 ， 我们需要在下方代码predice时加上一个`*p`

```python
""" Vanilla Dropout: Not recommended implementation (see notes below) """

p = 0.5 # probability of keeping a unit active. higher = less dropout

def train_step(X):
    """ X contains the data """

    # forward pass for example 3-layer neural network
    H1 = np.maximum(0, np.dot(W1, X) + b1)
    U1 = np.random.rand(*H1.shape) < p # first dropout mask
    H1 *= U1 # drop!
    H2 = np.maximum(0, np.dot(W2, H1) + b2)
    U2 = np.random.rand(*H2.shape) < p # second dropout mask
    H2 *= U2 # drop!
    out = np.dot(W3, H2) + b3

    # backward pass: compute gradients... (not shown)
    # perform parameter update... (not shown)

def predict(X):
    # ensembled forward pass
    H1 = np.maximum(0, np.dot(W1, X) + b1) * p # NOTE: scale the activations
    H2 = np.maximum(0, np.dot(W2, H1) + b2) * p # NOTE: scale the activations
    out = np.dot(W3, H2) + b3
```

---
#### Sigmoid & Relu & Gelu

> Q: Where are activations used in CNNs?
>  A: Generally placed after linear operators (feedforward/linear layer, convolutional layer, etc.)

> Sigmoid:梯度消失问题
> if the coming input are Large positive or negative values, sigmoid can "kill" the gradients. 
> ==The gradient of  Sigmoid is very small on the graph of sigmoid when the value are Large positive or negative.==
> Many layers of sigmoids =  smaller and smaller gradients in practice

![lecture_6, 页面 23](files/slides/CS231n/lecture_6.pdf#page=23)

> Relu:逐渐替代了Sigmoid，但是存在神经元死亡问题(x<0时没有梯度)，可能导致神经元不再更新自己的参数

![lecture_6, 页面 26](files/slides/CS231n/lecture_6.pdf#page=26)

>Gelu:改进了上文提到的Relu的问题

![lecture_6, 页面 27](files/slides/CS231n/lecture_6.pdf#page=27)

#### Case Study:VGGNet,Smaller filters

[ImageNet winners](files/slides/CS231n/lecture_6.pdf#page=34),我们暂时只关注AlexNet和VGG

Small filters, Deeper networks 
==相比于AlexNet，VGG的fliter更小，网络层次更深==
8 layers (AlexNet) -> 16 - 19 layers (VGG16Net) 
Only 3x3 CONV stride 1, pad 1 and 2x2 MAX POOL stride 2 

11.7% top 5 error in ILSVRC’13 (ZFNet) -> 7.3% top 5 error in ILSVRC’14 

> Why use smaller filters? (3x3 conv)

你可以[计算一下](files/slides/CS231n/lecture_6.pdf#page=41),看看两者的effective receptive field是不是相同的。
So, stacking these 3\*3 layers is better than having just a large filter.

![lecture_6, 页面 43](files/slides/CS231n/lecture_6.pdf#page=43)

--- 
#### Case Study:ResNet,Revolution of Depth

层数更多的模型反而表现的没有浅层模型好？而且Training error更高表明这并不是因为过拟合？到底为什么？
![lecture_6, 页面 47](files/slides/CS231n/lecture_6.pdf#page=47)

> 理论上来说，层数更多的模型具有更多的参数，潜在能力一定是更好的
> 所以，这大概率是因为深层数的模型更难以去优化，==这事实上是一个优化问题==

所以，一个更深的模型，应该学习到什么，才能保证其表现至少和一个更浅的模型一样好？
一个构造性的解决方案是：将那个更浅层模型中已经学好的层直接复制过来，然后将所有新增加的层设置为“恒等映射”。
![lecture_6, 页面 49](files/slides/CS231n/lecture_6.pdf#page=49)

**恒等映射 identity mapping**，简单来说就是一个函数 f(x)=x，它的输出永远等于它的输入。
但在实际训练中，让一个由$W,bias$ 和**非线性激活函数**组成的复杂网络层去学习 f(x) = x 这个恒等映射是极其困难的。
这是一个empirical finding

> 使用神经网络层去拟合一个**残差映射**，而不是直接去尝试拟合一个期望的、潜在的映射。

这里的H(x)=x是我们期望学习到的功能，即Identity mapping。
引入残差连接之后，这两个卷积层的任务不再是直接拟合 H(x),而是去拟合**残差 (residual)** 。
即拟合F(x) = H(x) - x , 当F(x) = 0时，H(x) = x。
它将学习目标从困难的 H(x) = x，转变成了极其简单的 F(x) = 0。
对于神经网络来说，学习输出一个为零的 F(x) 是非常容易的。

![lecture_6, 页面 52](files/slides/CS231n/lecture_6.pdf#page=52)

> Very deep networks using residual connections

- 152-layer model for ImageNet, ==the first architecture beyond 100 layers==
- ILSVRC'15 classification winner (3.57% top 5 error)  
- Swept all classification and detection competitions in ILSVRC'15 and COCO'15!

![lecture_6, 页面 55](files/slides/CS231n/lecture_6.pdf#page=55)

---
#### How to initialize weights in neural network layers?

> 假设有一个 Forward pass for a 6-layer net with hidden size 4096 的神经网络

参数值太小不好，梯度最终会消失。参数值太大又[爆炸](files/slides/CS231n/lecture_6.pdf#page=63&selection=16,0,16,6)了。
![lecture_6, 页面 61](files/slides/CS231n/lecture_6.pdf#page=61)

> How to fix this? Depends on the size of the layer

见证黑魔法吧！当然，这只对CNN有效，不要生搬硬套到其他架构上。
![lecture_6, 页面 65](files/slides/CS231n/lecture_6.pdf#page=65)

---
###  How to train CNNs? (practical tips )

#### Data Preprocessing

![lecture_6, 页面 67](files/slides/CS231n/lecture_6.pdf#page=67)

#### Data augmentation

Dropout是一个典型的方法
![lecture_6, 页面 70](files/slides/CS231n/lecture_6.pdf#page=70)

在CV领域，常用的方法有[变换图像](files/slides/CS231n/lecture_6.pdf#page=71&selection=17,0,17,14),[反转](files/slides/CS231n/lecture_6.pdf#page=72),裁剪并缩放,[Color Jitter](files/slides/CS231n/lecture_6.pdf#page=74),[Cutout](files/slides/CS231n/lecture_6.pdf#page=75)
他们共同的特点就是让图片看起来与原来不一样的同时，也让我们易于去辨认图中的物体
![lecture_6, 页面 73](files/slides/CS231n/lecture_6.pdf#page=73)

---
#### Transfer Learning

迁移学习，学会借力，使用别人的模型和数据集。
![lecture_6, 页面 86](files/slides/CS231n/lecture_6.pdf#page=86)

> What if you don't have a lot of data? Can you still train CNNs?
> Yes, you can.But you need to be a little bit smart with how you do it.

冻结前面的层，只训练单独的一层，有点类似Lora。或者直接全部微调所有层。
![lecture_6, 页面 82](files/slides/CS231n/lecture_6.pdf#page=82)

不同情况下的抉择，肯定是数据越多越好。
![lecture_6, 页面 85](files/slides/CS231n/lecture_6.pdf#page=85)

---
#### Hyperparameter Selection

> Step3: Use the architecture from the previous step, use all training data, turn on small weight decay
> find a learning rate that makes the loss drop significantly within ~100 iterations 
> Good learning rates to try: 1e-1, 1e-2, 1e-3, 1e-4, 1e-5

![lecture_6, 页面 89](files/slides/CS231n/lecture_6.pdf#page=94)

[这里](files/slides/CS231n/lecture_6.pdf#page=90&selection=17,0,17,8)总结了几种不同的情况，比如overfitting以及underfitting的情况。

> 为什么随机搜索（Random Search）在超参数优化中通常比网格搜索（Grid Search）更有效

当你的超参数空间维度较高，且你事先不知道哪个参数更重要时
- 网格搜索是低效的，它在所有维度上均匀分配，但大部分算力都被浪费在了不重要的超参数上。
- 随机搜索虽然看起来随机，但它保证了在每个维度上探索的多样性，尤其是在那些真正重要的超参数上，它能探索到更多的可能性。(绿线是性能曲线)

![lecture_6, 页面 95](files/slides/CS231n/lecture_6.pdf#page=95)







