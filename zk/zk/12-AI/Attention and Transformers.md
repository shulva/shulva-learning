# Attention and Transformers

![lecture_8, 页面 5](files/slides/CS231n/lecture_8.pdf#page=5)

## Attention
### the origin of Attention

> 引子：RNN encoder and RNN decoder

We can think the last hidden state of encoder as the summarizing , or encoding all of the information in the entire input sequence.

这里有一个问题，用来表达上下文信息的Context vector的大小是固定的，不会随着input的规模变化而变化。
![lecture_8, 页面 11](files/slides/CS231n/lecture_8.pdf#page=11)

> Solution: Look back at the whole input sequence on each step of the output.

> [!NOTE] Attention从何而来？
> What we want to do is not force a bottleneck in a fixed length vector between the input and the output.
> Instead, as we process the output sequence, we are going to give model the ability to look back at the input sequence.
> Every time it produces an output vector, we want to give network the opportunity to look back at the entire input sequence. 
> And if we do this, there is going to be no bottleneck, it will scale to much longer sequences. It will work better.
> ==So, that's the motivating idea that led to attention and transformers.==

Alignment scores: What is the similarity between the token of the input sequences with this initial decoder state s0.
之后，使用Softmax得到Normalize alignment scores.
之后将a与h相乘求和得到Compute context vector.
decoder仍然是RNN的架构,like lstm etc.

![lecture_8, 页面 19](files/slides/CS231n/lecture_8.pdf#page=19)

第二步，我们会重复一遍这个流程。
我们使用新生成的hidden state s1，做一遍与上文中s0相同的计算。
Compute new alignment scores $e_{2i}$,i and attention weights $a_{2i}$ ，生成新的context vector c2，继而生成新的s2。

![lecture_8, 页面 22](files/slides/CS231n/lecture_8.pdf#page=22)

> So, we solve the old problem : the fixed length context vector.

We are no longer bottlenecking the input sequence through a single fixed length vector.
==Instead, We have a new mechanism, where every time step of the decoder, the network look back at the entire input sequence, re-summarize the input sequence to generalize a new context vector on the fly for this one time step of the decoder, and then uses that to produce new outputs.==
我们不停地回顾，注意(attend)原来的输入，所以这个机制名为Attention.

![lecture_8, 页面 23](files/slides/CS231n/lecture_8.pdf#page=23)

> Visualize attention weights and Diagonal attention 

We can see "European Economic Area" has the different order with "zone économique européenne"!
So how does model figure out the grammar?haha, that's the mystery of deep learning. 
![lecture_8, 页面 27](files/slides/CS231n/lecture_8.pdf#page=27)

---
### How Attention work?

> There's a general operator hiding here

A query vector is a vector that we are trying to use to produce some piece of output.Here is decoder RNN states.
The output of the Attention operator were the context vectors.
So, What is the Attention operator doing? ==The Attention operator is taking a query vectors going back to the input data vectors, summarizing the data vectors in some new way to produce an output vector.==

![lecture_8, 页面 29](files/slides/CS231n/lecture_8.pdf#page=29)


> we want to make similarities function easier. So we no longer use $f_{att}$ instead of dot product.

![lecture_8, 页面 38](files/slides/CS231n/lecture_8.pdf#page=38)

> Multiple query vector is useful to process not one query vector at a time, but basically process a set of query vectors all in **parallel**. So $N_{Q}$ is the number of query vectors,$D_{Q}$ is the dimension.

Key Matrix和Value Matrix都是来自于Data Vectors。
The intuition like you want to separate what you are looking for from the answer you want in response to that query.
- The Query is what i am looking for.
- The Key is the record of data.
- The Value is what we want to match from the data vector.
You can think the $W_{k}$  and $W_{v}$  as the filters.
![lecture_8, 页面 40](files/slides/CS231n/lecture_8.pdf#page=40)

> It is sometimes called Cross Attention: Cross means it accept two different set of things: Query and Data.

一般来说，如果你拥有两种不同的，可以互相比较的输入序列，使用Cross-Attention是没有任何问题的。
![lecture_8, 页面 46](files/slides/CS231n/lecture_8.pdf#page=46)

---
### Self-Attention

Sometimes we only have one kind of  input sequence.So here we use self-attention.
在计算时，一般会将Q,K,V矩阵结合起来做矩阵乘法，这样在硬件上比较高效，具体如下:
Often fused to one matmul: $[Q K V] = X[W_{Q} W_{K} W_{V}]$  Dimension:   $[N * 3Dout] = [N * Din][Din * 3Dout]$
![lecture_8, 页面 47](files/slides/CS231n/lecture_8.pdf#page=47)

> Self-Attention is permutation equivariant: $F(σ(X)) = σ(F(X))$

This means self-attention does not care about the order of inputs. Computation don't depend on order.
If we change the order of inputs, we get the same outputs just shuffled in the same way.
So we can think self-attention actually not as operating on sequences of vectors.
Self-Attention works on **sets** of vectors instead of **sequence** of vectors.

![lecture_8, 页面 56](files/slides/CS231n/lecture_8.pdf#page=56)

但这引申出来一个问题,一般来说是加上位置编码，或者用rope
Question:Self-Attention does not know the order of the sequence
Solution: Add positional encoding to each input; this is a vector that is a fixed function of the index

---
### Masked and Multihead self-attention

> Masked:Don't let vectors "look ahead" in the sequence

This is an mechanism to let us control which inputs are allowed to interact with each other in the process of computation. We don't want to the network to look ahead the sequence , this is cheating!

![lecture_8, 页面 61](files/slides/CS231n/lecture_8.pdf#page=61)

---

> Multihead self-attention：head = layers?

现在在实际应用中的attention基本上都是Multiheaded Self-Attention。
![lecture_8, 页面 65](files/slides/CS231n/lecture_8.pdf#page=65)


In practice, compute all H heads in parallel using batched matrix multiply operations. 
Used everywhere in practice.
$H*D_{H}=D$ ， 我们把原始的总特征维度 D，分割成了 H 个独立的、维度为 Dʜ 的子空间。
QKV其实元素总量不变，仍然是$N*D,只是把其reshape成H*N*D_{H}$。
分割成H个之后，这些独立的QKV(维度为$N*D_{H}$)就可以进行各自独立地，并行地计算了。
计算完毕后将O1,O2...拼接回来再计算即可。
![lecture_8, 页面 66](files/slides/CS231n/lecture_8.pdf#page=66)


Q: How much **compute** does this take as the number of vectors N increases?  A: O(N^2)
Q: How much **memory** does this take as the number of vectors N increases? A: O(N^2)
Flash Attention通过减少数据的搬运从而降低了memory的复杂度。
![lecture_8, 页面 78](files/slides/CS231n/lecture_8.pdf#page=78)

## Transformer

> RNN:Not parallelizable
> CNN:Bad for long sequences
> Self-Attention:Although Expensive , but it is useful

而且有的时候more compute并不是绝对的坏事，毕竟more compute = more ability
![lecture_8, 页面 82](files/slides/CS231n/lecture_8.pdf#page=82)

如下是一个Transformer block的架构
![lecture_8, 页面 91](files/slides/CS231n/lecture_8.pdf#page=90)

堆叠Transformer 性能越来越强
![lecture_8, 页面 95](files/slides/CS231n/lecture_8.pdf#page=95)

[现代LLM的架构](files/slides/CS231n/lecture_8.pdf#page=99)会略有不同，一般会加上一个Embedding layer。

---
### Vision Transformers intro

Given an image, we basically divide the image up into patches separately into a vector.
But this process will lose the information of position, so we need add positional embedding.
一般来说，ViT会加上一个Special extra input: classification token (D dims, learned)，最终Transfomer输出所对应的这个token会用来分类。
![lecture_9, 页面 12](files/slides/CS231n/lecture_9.pdf#page=12)

这里我们不会用到Masked self-attention，图像毕竟不是语言，语言有sequence的特性。
这里与上一个图的ViT不同，上一个Vit用了一个classification token来分类，这一个则是最后做了一个平均池化变为一个向量后，再通过Softmax进行分类。
![lecture_9, 页面 19](files/slides/CS231n/lecture_9.pdf#page=19)

### 微调的Transformers

The Transformer architecture has not changed much since 2017. 
But a few changes have become common:

#### Pre-Norm Transformer

层标准化位于[残差连接的外部时](files/slides/CS231n/lecture_9.pdf#page=21)（Self-Attention底下没有这个Layer Normalization时），这个模型实际上无法学习恒等函数。
虽然这个现象很奇怪，但是我们可以将层标准化移动到自注意力和 MLP 之前，放到残差连接的内部。训练会更稳定。
而且可以看到，这里残差连接的流向也改变了，无需一定经过第二个Layer Norm。毕竟输出x经过Layer Norm之后就不能算将原始的输出原封不动的往下传输了。

![lecture_9, 页面 22](files/slides/CS231n/lecture_9.pdf#page=22)

#### RMSNorm

> **empirically** , it make the training more stable.

![lecture_9, 页面 23](files/slides/CS231n/lecture_9.pdf#page=23)

#### SwiGLU MLP

这里我们新加了一个矩阵$W_{3}$  , 通过Output的公式引入更多的非线性。即使层数很小也能明显地引入非线性。
![lecture_9, 页面 25](files/slides/CS231n/lecture_9.pdf#page=25)

#### MoE

> It is often used in very modern architecutures.

Instead of having one set of MLP layers, we can have multiple sets of MLP layers.
下方你也可以见到，W1和W2的维度多了一个E。
Each of those will be an expert. And what we do is through a router, the token will be routed to A of those experts.
A means active experts.==Increases params by E, But only increases compute by A.==
所以，MoE可以在不增加太多计算的前提下提升模型的稳定性。

![lecture_9, 页面 28](files/slides/CS231n/lecture_9.pdf#page=28)