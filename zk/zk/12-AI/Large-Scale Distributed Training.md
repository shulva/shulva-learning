# Large-Scale Distributed Training

> 幽默CloseAI

这里的主要例子是Llama3-405B，其他模型确实性能更强，但是没有技术报告，不知道细节。
![lecture_11, 页面 4](files/slides/CS231n/lecture_11.pdf#page=4)

## GPU Hardware

研究对象是A100，我们先关注A100上的compute core。
一般来说，compute core会配备80 GB of HBM Memory and 3352 GB/sec bandwidth to cores.
一个compute core中有50MB 的 L2 Cache 以及132个SM。理论上一般是144个，但是众所周知，芯片生产是难以尽善尽美的，总会有一些坏掉的部分，所以一般是132个。
![lecture_11, 页面 12](files/slides/CS231n/lecture_11.pdf#page=12)

可见，Tensor Cores的Flop远高于Fp32 Cores。
而且，Tensor Cores一般使用混合精度。
It takes low precision,16-bit input, and produce the outputs in a higher precision 32-bit.
![lecture_11, 页面 16](files/slides/CS231n/lecture_11.pdf#page=16)

> major driver of the explosion of deep learning.

![lecture_11, 页面 19](files/slides/CS231n/lecture_11.pdf#page=19)

---

### GPU cluster

> Goal: Train one giant neural network on this cluster

Total Cluster Stats 
24,576 GPUs 
1.875 PB of GPU memory 
415M FP32 cores 
13M Tensor Cores 
24.3 EFLOP/sec = 24.3 x 10\^18

这个8xGPU,2 Server的数字部分一般是取决于机柜以及数据中心是怎么设计的。
当然，还有除了Nvidia之外的其他芯片，比如[Google TPU,AMD,AWS](files/slides/CS231n/lecture_11.pdf#page=26)，在此不详谈了。
![lecture_11, 页面 25](files/slides/CS231n/lecture_11.pdf#page=24)

### 衡量性能:HFU and MFU

HFU简单来说就是浮点计算的运用率，一般来说无法我们百分百发挥硬件的算力。可以用pytorch的benchmark去计算。
但是HFU有一个问题，就是不够细粒度，有很多data augmentation, optimizer, etc的运算被计算进去了。
我们有的时候只关心最重要的那几个花费在训练模型上的计算，这个时候就需要使用MFU去衡量。
![lecture_11, 页面 107](files/slides/CS231n/lecture_11.pdf#page=107)

简单来说，MFU就是：
1.计算出硬件的理论性能，这里只取GEMM，无视nonlinearities, normalization, elementwise这些在FP32 cores上的。
2.计算出理论的$FLOP/sec_{theoretical}$
3.计算出理论时间
4.做实验，测量出实际时间
5.按slides上的公式，得出实际的MFU
![lecture_11, 页面 110](files/slides/CS231n/lecture_11.pdf#page=110)

一般来说，MFU>40%已经是非常卓越了。
一个有趣的现象就是A100的MFU通常会低于H100，可以解释这个现象的一个假说是，计算能力的增长速度高于卡与卡之间
通信能力增长的速度。
![lecture_11, 页面 113](files/slides/CS231n/lecture_11.pdf#page=113)

---
## How to train on lots of GPUs

这一切基于transformer，毕竟是最常用的架构。
A transformer is a stack of L layers, **L** layers operate on a three-dimensional tensor of size **(Batch, Sequence, Dim)**.
所以，以下四种并行便是操控这四个维度来进行并行计算。
![lecture_11, 页面 30](files/slides/CS231n/lecture_11.pdf#page=30)

对于大部分人，HSDP + Activation checkpointing 已经足够了。
CP,PP,TP需要非常多的卡才能运用。至于如何优化如此多的参数(FSDP大小，HSDP的参数大小)，请运用MFU。
![lecture_11, 页面 102](files/slides/CS231n/lecture_11.pdf#page=102)

LLama3这样的大模型，将GPU分成多个维度使用这些技巧来进行分布式训练。
![lecture_11, 页面 146](files/slides/CS231n/lecture_11.pdf#page=146)

---
### Data Parallelism (DP)

We can split up the $MN$ minibatch into a smaller minibatch of $N$ samples that goes on $M$ GPUs.
![lecture_11, 页面 36](files/slides/CS231n/lecture_11.pdf#page=36)

Each of those GPUs actually maintain its own separate copy of the neural network weights of the optimizer state and of the gradients.

Step 5 is where we do an **all reduce** operation. Every GPU need to send its gradient to all the other GPUs.
So at this point, each GPUs has it own independent but identical copy of the gradient ==across the entire macro batch of data.== Then we can update the weights.
![lecture_11, 页面 43](files/slides/CS231n/lecture_11.pdf#page=43)

> [!NOTE] 并行由何而来
> 因为反向传播（Step 4）是按层（Layer-wise）进行的，而梯度平均（Step 5）也可以按层进行。这意味着我们不需要等整个网络反向传播全部做完，就可以开始同步已经算好梯度的层的梯度。而前向传播（Step 3）必须从头到尾按顺序走完，才能计算 Loss，所以中间没有机会进行并行通信，而且需要全部计算的按公式只需要Loss和gradient，没有必要在此All-reduce 。
> 
>  为什么反向传播（Step 4）和梯度平均（Step 5）可以流水线并行？
> 
> 1.  反向传播的顺序: 是从最后一层（输出层）往前算到第一层（输入层）。
>     *   先算出最后一层 `W_Last` 的梯度，再算出倒数第二层 `W_Last-1` 的梯度。以此类推。
> 
> 2.  梯度平均的需求: 只要**某一层**的梯度在所有 GPU 上都算出来了，我们就可以立刻对这一层的梯度进行全局平均（All-Reduce 操作），不需要等待更前面的层（靠近输入的层）算好。
> 
> 3.  流水线并行（Pipeline）:
>     *   时刻 T1: 所有 GPU 算完了**最后一层**的梯度。
>     *   时刻 T2: 所有 GPU 开始算**倒数第二层**的梯度。通信 (并行): 同时，后面的层开始传输并平均**最后一层**的梯度。
>     *   时刻 T3: 所有 GPU 开始算**倒数第三层**的梯度。通信 (并行): 同时，后面的层开始传输并平均**倒数第二层**的梯度。
> 
> 这就是重叠通信与计算（Overlapping Communication and Computation）的优势所在。
> 通过这种机制，我们掩盖了昂贵的网络通信时间。当我们在 GPU 上计算前面层的梯度时，后面层的梯度已经在同步了。

#### Fully Shared Data Parallelism (FSPD)

> Problem: Model size constrained by GPU memory.

Each weight needs 4 numbers (weight, grad, Adam β1, β2).  Adam指优化器的参数.
Each number needs 2 bytes. 1B params takes 8GB; 10B params fills up 80GB GPU. (16-bit的精度)
GPU的存储容量限制了模型参数量的大小，怎么办？

**Solution: Split model weights across GPUs**

FSPD步骤较多，一步一步介绍。FSPD的核心思想就是将参数分割，每个卡只存一小部分，不用存储全部参数。
==FSPD前向和反向传播两次参数，增加了通信开销。用通信的时间去换显存，某种程度上是经典的时间换空间思想。==

GPU 1 是 $W_1 和 W_2$ 的拥有者，GPU 2 是 $W_3 和 W_4$ 的拥有者。GPU 1 平时**只存** $W_1, W_2，不存 W_3, W_4$ ，这极大节省了显存。

> 前向传播过程

1.当计算进行到第 i 层时，所有 GPU 都需要这一层的 $W_i$ 才能做计算。$W_i$ 's Owner GPU把它broadcast发给所有其他的 GPU。
当然，在计算$W_i$ 时就可以提前预取(pre-fetch)$W_{i+1}$ 了，这类似一个流水线流程，从而掩盖传播的时长。

2.所有 GPU 收到了完整的$W_i$，进行前向计算。计算一完成，所有非Owner的GPU**立即删除**刚刚收到的 $W_i$，节省并释放显存。

![lecture_11, 页面 50](files/slides/CS231n/lecture_11.pdf#page=50)

> 反向传播过程

3.反向传播也要用到权重 $W_i$ 来算梯度。现在再广播一次。Owner 再次把 $W_i$发给所有人。这一步和前向传播时相同。

Optimization: don't delete last weight at end of forward to avoid immediately resending it
对于最后一层，前向算完紧接着就是反向，中间没有间隔，所以可以暂时不删除，省去一次重新发送的开销。

4.所有 GPU 拿着完整的 $W_i$ 计算出自己这部分数据的**局部梯度** $dL/dW_i$ 。算完梯度后，再次删除权重的副本$W_i$。

5.现在每个 GPU 都有了一份针对layer i  的局部梯度 $dL/dW_i$  。大家把这些局部梯度全部发送给 $W_i$ 的Owner 。
Owner 把收到的所有梯度加起来（Reduce），得到完整的全局梯度。非Owner GPU 删除掉自己的局部梯度（释放显存）。

6.只有Owner GPU 拥有完整的梯度和优化器状态，它会更新自己管理的那部分权重 $W_i$。

7.对下一批数据，重复此流程。Repeat with next batch of data . Data was being pre-fetched during forward+backward
![lecture_11, 页面 61](files/slides/CS231n/lecture_11.pdf#page=61)

同样，反向传播也可以像流水线一样预取。
当我们在算第 i+1 层的梯度时，GPU可以去获取第 i 层的参数 $W_i$。
当我们在算第 i-1 层的梯度时，通信模块负责把算好的第 i 层梯度 $dL/dW_i$ 发送给$W_i$的Owner，并且使Owner更新权重 $W_i$ 。

slides中的All at the same time就是一个很好的例子：
此时，GPU1正在反向传播，计算$W_2$的梯度。
$W_3$的梯度已经计算完成，通信模块将其发送给Owner GPU2，并让GPU2更新权重$W_3$ 。
而且此时，GPU1也正在向GPU2预取$W_1$ 。

**尽量把通信（下载参数、上传梯度）这种行为安排在计算（GPU 矩阵运算）这种核心工作的间隙里或者同时进行，让昂贵的 GPU 永远不空转，不浪费时间，同时也尽量地掩盖通信时间的开销。**

如果理解有困难，请直接从头到尾看一遍[slides](files/slides/CS231n/lecture_11.pdf#page=46&selection=12,0,12,5)。


---
####  Hybrid Shared Data Parallel (HSDP)

FSDP通信太频繁了，前向传播+反向传播+传播梯度一共三次。
如果是一个Server中的GPU，通信cost不会太高(高速互联)。但是Server之间的通信成本可能就很高了。

所以，HSDP将所有GPU分组。一个组里有K个GPU，共有M个组。
组内仍然采用FSDP，组件则采用正常的DP策略。
这样，组内FSDP对应Server的维度，通信成本不会太高。（Slide中：Keep them in the same node / pod）
组件使用DP，DP不需要传播模型参数，只需要在反向传播后同步一下梯度就好。这样减少了Server间的通信开销。
(Slides:Can use slower communication.)
![lecture_11, 页面 67](files/slides/CS231n/lecture_11.pdf#page=67)

#### Activation Checkpointing

在计算反向传播时，我们需要前向传播时计算出来的中间激活值。
但是对于过大的模型来说，储存中间激活值就把存储耗尽了。
所以，既然存储过多，那么我就不存了。需要用的时候再计算一遍，也是时间换空间。
![lecture_11, 页面 70](files/slides/CS231n/lecture_11.pdf#page=70)

如果我们储存全部激活值，那么，Peak Memory就直接和层数深度相关。
![lecture_11, 页面 76](files/slides/CS231n/lecture_11.pdf#page=76)

如果我们在不储存Activation，直接重新计算，那么就例如G4计算时，直接从A1->A2->A3->A4重新计算一遍。
14 = A(4+3+2+1) + G(1+1+1+1) 则有 O(N^2+N) = O(N^2)
Peak Memory为2($G_i 和 A_i$) ，容易得出Compute的时间复杂度为O(N^2)。

O(N^2)并不好，太高了！所以我们可以采取Checkpoint策略，我们将N层的网络划分为C段，我们只在显存中**永久保存**这 
C个分段点的激活值。段内部的激活值算完就扔。
也就是说，计算G最多也只需要  1+2+...+(N/C) ，即 O(N^2/C)的时间复杂度。Pytorch取$C=√𝑁$

![lecture_11, 页面 101](files/slides/CS231n/lecture_11.pdf#page=101)

---

### Context Parallelism (CP) intro

Transformers输入是sequence，天然可以考虑拆分。让不同的GPU处理不同的sequence。
Norm以及残差连接很容易并行，这两者都是对token独立操作的，`x1与x2,x3`之间不会互相影响。
MLP也容易并行，但是这是有权重的。所以MLP部分需要像DP一样，每个 GPU 都保存一份完整的 MLP 权重。
前向传播时，各自算各自的 token。反向传播后，大家通信同步梯度（All-Reduce），更新权重。
Attention的token之间会相互影响，需要单独讨论。

![lecture_11, 页面 119](files/slides/CS231n/lecture_11.pdf#page=119)

> Ring Attention and Ulysses

QKV计算的时候不难，只是训练有反向传播的时候要像DP一样传播各自计算出来的梯度并进行计算。
Ring Attention and Ulysses slides介绍的不够，详情可以看这两篇文章：[Ring Attention](https://infrasys-ai.github.io/aiinfra-docs/05Infer04LongInfer/02RingAttention.html)and [Ulysses](https://infrasys-ai.github.io/aiinfra-docs/05Infer04LongInfer/03Ulysses.html) 

### Pipeline Parallelism (PP) intro

把层分开给GPU计算，看起来也是个很直观的想法。
但是，GPU的前向以及反向传播是存在层与层之间的依赖性的。传数据是要花费时间的。
可以从这个流水线表看出来，单纯的计算一次，GPU利用率是很低的。
所以，我们可以学习体系结构中的思想，CPU解决Bubble的问题是流水线，发射多条指令。
所以在这里，我们是处理多个batch，形成流水线挤压空泡。

![lecture_11, 页面 132](files/slides/CS231n/lecture_11.pdf#page=132)

如图所示，很类似于cpu的流水线。
![lecture_11, 页面 133](files/slides/CS231n/lecture_11.pdf#page=133)

### Tensor Parallelism (TP) intro

这个想法则是我们把权重矩阵切开，$GPU_i负责存W_i$
虽然计算可以并行，但如果你想用完整的 Y 做下一层的计算，就必须进行一次 **All-Gather** 通信，把分散在各个 GPU 上的 Y1, Y2, Y3, Y4 拼起来。这个通信必须发生在计算之后，没法像 FSDP 那样很好地重叠，所以会阻塞计算。

![lecture_11, 页面 138](files/slides/CS231n/lecture_11.pdf#page=138)

> 解决方案: With 2 consecutive TP layers, shard first over row and second over column to avoid communication

这是一个非常经典的优化技巧（Megatron-LM 中使用的）,在连续的两层中做计算：

1. **第一层 (Column Parallel)**: 按**列**切分权重 W_A。
    - 每个 GPU 算出部分的输出 Y_part。
    - 不要急着通信合并 Y_part！保持它切分的状态。
2. **第二层 (Row Parallel)**: 按**行**切分权重 W_B。
    - 根据矩阵乘法规则，第一层的输出正好对应第二层的行输入。
    - 每个 GPU 直接拿自己手里的局部输出 Y_part 去乘第二层对应的局部权重 U。
    - 这一步计算依然不需要通信。
3. **最后**:
    - 两层算完后，进行一次 **All-Reduce**（求和），类似矩阵的内积，就能得到最终正确的结果。
        

No need for communication after XW=Y ! Each GPU computes one term of Z, then broadcasts to all other GPUs

![lecture_11, 页面 143](files/slides/CS231n/lecture_11.pdf#page=142)
