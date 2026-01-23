# Why Parallelism? Why Efficiency?

> [!quote]
> Slides from Stanford CS149

> Course theme 1: 设计与编写并行程序……而且是可扩展的 (Scale)！

并行思维 (Parallel Thinking)
1. 任务分解：将工作拆解成可以安全地（无数据冲突）并行执行的片段。
2. 任务分配：将工作分配给不同的处理器。
3. 通信管理：管理处理器之间的通信/同步，确保这些开销不会限制**加速比 (Speedup)**。

执行上述任务的抽象/机制
- 使用流行的并行编程语言编写代码（如 C++ with ISPC, CUDA, pthread 等）。

这里的 **"Scale" (可扩展性)** 是并行计算的关键。写一个能用2核跑的程序不难，难的是写一个给它 100 个核，它的速度真的能提升 50-100 倍的程序。

> Course theme 2:并行计算机的硬件实现：并行计算机是如何工作的

▪ 用于高效实现抽象的机制
- 各种实现的性能特征（比如：cache有多大？读global memory要多少个周期？）。
- 设计权衡 (Trade-offs)：性能 vs. 编程难易性 vs. 成本。

▪ 为什么我需要了解硬件？
- 因为机器的特性真的很重要（回想一下CUDA通信速度）。
- 因为你在乎效率和性能。

> Course theme 3: Thinking about efficiency

==快 (FAST) ≠ 高效 (EFFICIENT)==

- 仅仅因为你的程序在并行计算机上跑得比单机更快，并不意味着它在高效地利用硬件。
    - (比如你用了 100 个核，速度只提升了2 倍，虽然变快了，但效率极低。)
- 程序员的视角：充分利用机器提供的能力（榨干硬件性能）。
- 硬件设计者的视角：选择将哪些正确的功能放入系统中（考虑性能/成本之比）。这里的成本指：硅片面积，功耗等等。

---
## Why Parallelism?

在1985-2003年间，Single-threaded CPU的性能大约18月便能翻一倍，但现在显然不行了。
那个时候提升处理器性能的方法主要是这两个：
- instruction-level parallelism 指令级并行-ILP
- Increasing CPU clock frequency 提升CPU频率

所以让我们回顾一下计算机体系结构的知识：

**什么是计算机程序？（从处理器的角度来看）** 它是一份待执行的指令列表！
**什么是指令？** 它描述了处理器需要执行的一个操作。执行一条指令通常会修改计算机的**状态**。
**当我谈论计算机的“状态”时，指的是什么？** 一般指的是程序数据的值，这些数据存储在处理器的寄存器或内存中。

> This program has five instructions, so it will take five clocks to execute, correct? Can we do better?

这里，我们如果是多核，就可以利用指令级并行。
这里的概念是使用多个不同的Fetch/Decode以及Exec单元去接受多发射的指令并执行。
![01_whyparallelism_huXfOJ4, p.44](files/slides/CS149/01_whyparallelism_huXfOJ4.pdf#page=44&rect=0,0,1920,1080)

处理器会自动在指令序列中找出相互独立的指令，并在多个执行单元上并行执行它们！
![02_basicarch_xX3ssOi, p.11](files/slides/CS149/02_basicarch_xX3ssOi.pdf#page=11&rect=0,0,1920,1080)
在一个典型的程序片段里，真正能互不干扰、同时去做的指令，通常平均下来只有 **3 到 4 条**。
也可以看出来，大部分程序也不改变写法，超标量同时发射并处理再多指令也没用。
一个4发射的处理器，就已经榨干了绝大多数可用的 ILP。16-issue的CPU成本极高，但却获得不了什么提升。
![01_whyparallelism_huXfOJ4, p.50](files/slides/CS149/01_whyparallelism_huXfOJ4.pdf#page=50&rect=0,0,1920,1080)

增加频率必须增加电压导致功耗爆炸性增长，再往上提频率已经不划来了。
1.6GHz->4.8GHz，功耗增长了11倍！功耗墙限制了现代处理器的设计与发展。
![01_whyparallelism_huXfOJ4, p.54](files/slides/CS149/01_whyparallelism_huXfOJ4.pdf#page=54&rect=0,0,1920,1080)

如右图，频率被功耗锁死，ILP已经被榨干了。不过，摩尔定律还在正常运行（虽然马上就要结束了）。
所以，架构师现在通过增加并行运行的单元（或者专用的DSA）来提升速度。
==软件必须写成并行的才能获得性能提升。软件开发者再也没有免费的午餐了！==
![01_whyparallelism_huXfOJ4, p.55](files/slides/CS149/01_whyparallelism_huXfOJ4.pdf#page=55&rect=0,0,1920,1080)

---
## Why Efficient?

> But in modern computing software must be more than just parallel…
> IT MUST ALSO BE **EFFICIENT**

使用DSA在现代体系结构中很常见。例如Google的TPU。

### Cache

> Achieving efficient processing almost always comes down to accessing data efficiently.

小小复习一下Memory的知识。

Stalls是处理器因为等待数据而被迫停止工作的状态。 最常见的原因是**内存访问**：当 CPU 执行计算指令需要用到内存中的数据时，由于内存读取速度极慢（需要几百个时钟周期），在数据传回之前，CPU 只能空转等待。
![01_whyparallelism_huXfOJ4, p.73](files/slides/CS149/01_whyparallelism_huXfOJ4.pdf#page=73&rect=0,0,1920,1080)

所以cache应运而生。cache是一种硬件实现细节，不影响程序输出结果，只影响性能。
它是**片上存储（On-chip storage）**，保存了内存（DRAM）中一部分数据的副本。利用了程序的局部性原理。
cache里已有的数据，CPU就无需访存，只需要访问cache即可，快的多。
![01_whyparallelism_huXfOJ4, p.75](files/slides/CS149/01_whyparallelism_huXfOJ4.pdf#page=75&rect=0,0,1920,1080)

下面是cache的例子，以及在这个访问序列中存在两种形式的“**数据局部性**”：
1.  **空间局部性 (Spatial locality)**：
    加载一个**缓存行 (cache line)** 中的数据，相当于preload了后续访问所需的、位于**同一行内不同地址**的数据，从而促成了缓存命中 (cache hits)。
2.  **时间局部性 (Temporal locality)**：对**同一个地址**的重复访问会导致缓存命中。
![01_whyparallelism_huXfOJ4, p.76](files/slides/CS149/01_whyparallelism_huXfOJ4.pdf#page=77&rect=0,0,1920,1080)

L1-L2-L3-Memory的Memory Arch.L1:L2:L3:DRAM访存花费的时间约为1:3:10:60.
可见，cache减少了访存的延迟，而且带宽还更高，是一个非常成功的**efficient**的设计。
![01_whyparallelism_huXfOJ4, p.79](files/slides/CS149/01_whyparallelism_huXfOJ4.pdf#page=79&rect=0,0,1920,1080)