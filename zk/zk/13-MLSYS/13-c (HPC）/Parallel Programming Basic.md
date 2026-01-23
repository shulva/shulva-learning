# Parallel Programming Basic

## intro

我们创建一个并行的程序可分为以下几步：
- 确定可以并行执行的子问题 
- 对各个可独立执行的子问题分配计算资源（以及与子问题关联的数据的对应访存资源） 
- 管理数据访问、通信和同步
![04_progbasics, p.4](files/slides/CS149/04_progbasics.pdf#page=4&rect=0,0,1920,1080)

---
## Decomposition 问题分解

![L04-00-并行编程基础, p.10](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=10&rect=0,0,1024,768)

我们的主要目标之一是提高加速比（Speedup）,但是根据这个定律，我们的加速比是一定有个上限的。
![L04-00-并行编程基础, p.5](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=5&rect=0,0,1024,768)

---
### Example:N x N image

考虑对一个 N x N 图像进行两步计算：
第 1 步：让所有像素变为原来的双倍亮度（每个网格元素独立计算）
第 2 步：计算所有像素值的平均值
如果顺序计算，这两个步骤都需要 $N^2$时间，所以总时间是$2N^2$。
显然，第1步以及第2步都是可以并行的，假设我们有P个核，则计算加速如下，串行合并结果的部分未再优化。
![L04-00-并行编程基础, p.8](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=8&rect=0,0,1024,768)

问题分解的例子有了，流程也大概明白了，可是问题分解谁来做呢？现在的编译器还很难自己分析并完成任务分解。
![L04-00-并行编程基础, p.11](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=11&rect=0,0,1024,768)

---
## Assignment 任务指派

> Assignment: keep all workers busy

我们需要将分解过后的子任务分配给"workers"。这里的workers可以是线程/程序实例或是一个simd的vector lane。
目标是平衡各工人的工作量，降低沟通成本。可以静态执行，也可以在执行过程中动态执行。
虽然通常由程序员负责分解，但许多语言/运行时可以自行负责分配。
![04_progbasics, p.14](files/slides/CS149/04_progbasics.pdf#page=14&rect=0,0,1920,1080)

左侧代码是由按循环迭代分解工作，由程序员管理任务分配，是静态分配。以交错 (interleaved)的方式将迭代分配给 ISPC 程序实例。
右侧按也是循环迭代分解工作，`foreach` 结构向系统暴露了独立的工作，系统自己管理各个work(每个循环)到 ISPC 程序实例的分配（这种抽象为动态分配留出了空间，但目前的 ISPC 实现是静态的）。
目前的 ISPC 编译器很智能，它默认就会把 `foreach` 编译成左边那种交错分配的代码。
![04_progbasics, p.15](files/slides/CS149/04_progbasics.pdf#page=15&rect=0,0,1920,1080)

> ISPC也可以用launch去做多核并行

ISPC 运行时系统（对程序员不可见）会将任务分配给**线程池**中的工作线程。
任务分配给线程的实现方式：在完成当前任务后，工作线程会检查任务列表，并将**下一个未完成的任务**分配给自己。
其实就相当于把 100 个任务放在一个公共的池子里。谁干完了手里的活，就去池子里抢一个新的活干。
launch把大任务切成小块，分给不同的 CPU 核心（多线程）。foreach在每个小块内部，利用SIMD 指令（向量化）加速。
![04_progbasics, p.17](files/slides/CS149/04_progbasics.pdf#page=17&rect=0,0,1920,1080)

---
## Orchestration 任务协同 Mapping 硬件映射

这一步会包含：构建进程间的消息沟通；如有必要，需要额外添加同步，以保留依赖关系；在内存中组织数据结构；调度任务
目标是降低通信/同步的成本，保持数据引用的局部性，减少开销。
计算系统体系结构会影响其中的许多设计或编程决策。如果同步代价高昂（通信延迟或访存延迟开销大），我们可能会更少地使用调用进程间的同步。
![04_progbasics, p.19](files/slides/CS149/04_progbasics.pdf#page=19&rect=0,0,1920,1080)

硬件映射可能由程序员、系统（编译器、运行时、硬件）独自或共同承担。
![L04-00-并行编程基础, p.17](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=17&rect=0,0,1024,768)

---
## A parallel programming example:2D-grid based solver

### Decomposition

![L04-00-并行编程基础, p.18](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=18&rect=0,0,1024,768)

Step 1：分析依赖项，可以得出每行元素依赖于左边的元素，而且每列取决于前一列（脑测一下循环的计算过程）。
![04_progbasics, p.24](files/slides/CS149/04_progbasics.pdf#page=24&rect=0,0,1920,1080)

因为要想计算点`(i,j)`，必须先算出`(i,j-1)以及(i-1,j)`的值。
同一条对角线上的所有点，其依赖数据（左方和上方的值）均位于**上一条**对角线上（已计算完成），而它们彼此之间**互不依赖**，因此可以同时计算。
此时，一条对角线内的计算可以并行，但是不能多条对角线并行。
![L04-00-并行编程基础, p.21](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=21&rect=0,0,1024,768)

并行度没有那么高？更改算法！
为了并行化而修改算法（甚至牺牲一点点数值精确度），是并行编程中非常普遍且常规的操作。
![L04-00-并行编程基础, p.22](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=22&rect=0,0,1024,768)

解释这个算法为什么正确很复杂，你可以问问LLM。虽然中间过程（每一步迭代后的临时网格状态）和原方法不一样，但它们的终点是一样的。只是收敛速度不同。
![L04-00-并行编程基础, p.23](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=23&rect=0,0,1024,768)

---
### Assignment

这两种分配方式哪一个更好？事实上这取决于硬件的实现细节。
![04_progbasics, p.29](files/slides/CS149/04_progbasics.pdf#page=29&rect=0,0,1920,1080)

### Orchestration

别忘了，我们还需要考虑各组之间通信的成本。
![L04-00-并行编程基础, p.25](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=25&rect=0,0,1024,768)

![L04-00-并行编程基础, p.26](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=26&rect=0,0,1024,768)

---
### Programming

> Data parallel thinking

Decompostion：单独的网格元素构成独立的计算任务
Orchestration：不同组的协同由系统处理。
reduceAdd是内置的通信原语。而`for_all`循环结束处，则是所有的`for_all`块在回到顺序控制逻辑之前要隐式等待所有的`for_all`块都完成计算之后才能返回。
![04_progbasics, p.34](files/slides/CS149/04_progbasics.pdf#page=34&rect=0,0,1920,1080)

#### Shared address space

SPMD execution model
![L04-00-并行编程基础, p.28](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=28&rect=0,0,1024,768)

所以..程序中新加上的`barrier以及lock`到底在干嘛？
而且，能看出来潜在的问题吗？ 共享地址空间的优势还存在吗？这里我们在下面会解释性能问题。
![L04-00-并行编程基础, p.29](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=29&rect=0,0,1024,768)

线程之间的通信是通过读取共享地址空间中的共享变量来完成的。也就是说，如果有两个线程"同时"对这个变量做操作，是可能引发一些奇怪的问题的。
![04_progbasics, p.39](files/slides/CS149/04_progbasics.pdf#page=39&rect=0,0,1920,1080)

> Why?

这种交错执行会直接使其中一个线程的结果丢失（这里是T1）。
所以，线程的一行操作拆解为多条指令后，指令执行时中间绝对不能让别的线程插手。
![L04-00-并行编程基础, p.30](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=30&rect=0,0,1024,768)

所以，我们可以通过如下的方法来保证操作的原子性。
```cpp
1.通过Lock/unlock 保证关键指令或指令组的互斥

mylock.lock(); 
// critical section 
mylock.unlock();

2.一些编程语言对代码块的原子性有单独的支持
atomic { // critical section }

3.通过硬件支持的内建专用指令，来保障原子性的“读取-修改-写入”操作
atomicAdd(x, 10);
```

> 共享地址空间模型 (Shared Address Space Model)

- 线程通过以下方式进行通信：
    - 读/写共享地址空间中的共享变量:线程间的通信是**隐式**包含在内存加载 (loads) 和存储 (stores) 操作中的。
    - 操作同步原语:例如，通过使用锁 (locks) 来确保互斥。

---

但是，锁是有性能开销的。
代码这里通过在局部累加为部分和，然后在迭代结束时通过全局完成归约提高性能。如何提高性能的？
未改进的slides中的代码，在 for 循环内部，每算完一个点 (i,j)，就立刻去更新全局变量 diff：
```cpp
lock(myLock); 
diff += abs(A[i,j] - prev); // 每次循环都抢锁 
unlock(myLock);
```

这里，`mydiff`是每个线程私有的变量，私有变量更新不需要锁。
等线程把自己负责的所有点都算完了，再去抢一次锁，把自己的 `myDiff` 加到全局的 `diff` 里。
这样，锁的争用次数从 $N^2$ 次（网格点总数）降低到了 $P$ 次（线程总数）。
![04_progbasics, p.46](files/slides/CS149/04_progbasics.pdf#page=46&rect=0,0,1920,1080)

#### barrier

Barrier是阻塞式同步原语，形如`barrier(num_threads)`。
![L04-00-并行编程基础, p.34](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=34&rect=0,0,1024,768)

第一次 Barrier 在(循环开始前)在`diff = 0.f;` 之后，for 循环之前。这确保了所有线程的 `diff` 都已被清零。
*   **如果去掉会怎样？**
    *   假设线程 A 跑得很快，它已经把上一轮的 `diff` 清零了，甚至开始跑新一轮循环，并且算完了一部分，把新的 `myDiff` 加到了 `diff` 里（比如 `diff` 变成了 0.5）。
    *   此时，线程 B 跑得很慢，它才刚刚开始执行 `diff = 0.f`。结果线程 B 把线程 A 算出来的 0.5 给覆盖了。
    *   所以，必须等大家都已完成上面的所有工作，`diff` 不会再有其他改动再开始。

第二次 Barrier (计算结束后)。位置在`unlock(myLock);` 之后，`if` 判断之前。这是为了确保所有线程都已经把自己的 `myDiff` 加到了全局 `diff` 里。
*   **如果去掉会怎样？**
    *   线程 A 算完了，把自己的 `myDiff` 加进去了。它急着去执行 `if (diff/(n*n) < TOLERANCE)`。
    *   此时，线程 B 还没算完，它的 `myDiff` 还没加进去。线程 A 检查的是一个**不完整**的 `diff`（只包含部分线程的结果）。这会导致它做出错误的判断。

第三次 Barrier (判断结束后)。位置在`done = true;` 之后，`while` 循环结束前。这是为了确保所有线程都得知了`done`的值。
*   **如果去掉会怎样？**
    *   假设线程 A 发现误差很小，把 `done` 设为了 `true`，然后它就退出了 `while` 循环，结束了。
    *   线程 B 跑得慢，它还在检查 `if`。如果线程 A 跑得太快，直接进入了**下一阶段的代码**，而线程 B 还在用这块内存，程序就会出错。
![L04-00-并行编程基础, p.35](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=35&rect=0,0,1024,768)

> 多缓冲 (Multi-buffering)

之前的代码之所以需要 3 次 Barrier，是因为大家都在共用**同一个** `diff` 变量。
必须等大家都不会再改动了全部清0了才能往下走（Barrier 1）。必须等大家都写完了`mydiff`才能继续（Barrier 2）。

所以，为了改进性能，我们不共用一个 `diff` 了，我们搞3个 `diff`（`float diff[3]`）。
第 1 轮迭代，大家用 `diff[0]`。第 2 轮大家用 `diff[1]`。第 3 轮大家用 `diff[2]`。 第 4 轮大家又回到 `diff[0]`。
通过引入 `diff[3]`，我们解除了**当前轮次和下一轮次**之间的数据依赖。
代价是多用了 8 个字节的内存（微不足道）。收益却是每次循环少做 2 次 Barrier（巨大的性能提升，因为 Barrier 很慢）。
![L04-00-并行编程基础, p.36](files/slides/hias-parellel/L04-00-并行编程基础.pdf#page=36&rect=0,0,1024,768)
我们引入了 `diff[0]`, `diff[1]`, `diff[2]`。假设当前是第 `k` 轮迭代，使用 `diff[k % 3]`。

>  消除 Barrier 1（初始化等待）

*   **操作**：线程在第 `k` 轮结束时，执行 `diff[(k+1)%3] = 0`。即提前初始化**下一轮**的变量。
*   **分析**：
    *   当前所有线程都在第 `k` 轮，操作 `diff[k%3]`。最慢的线程可能还在第 `k-1` 轮，在if中操作 `diff[(k-1)%3]`。
    *   下一轮的变量 `diff[(k+1)%3]` 目前是空闲的（没有任何线程在读写它）。
    *   因此，跑得快的线程可以安全地清零 `diff[(k+1)%3]`，**不存在竞态条件**。不需要等待其他线程，所以 Barrier 1 可以移除。

> 消除 Barrier 3（跨轮次等待）

*   **操作**：线程 A 完成第 `k` 轮判断后，直接进入第 `k+1` 轮，开始累加 `diff[(k+1)%3]`。
*   **分析**：
    *   线程 A 操作的是 `diff[(k+1)%3]`。 线程 B（慢线程）还在第 `k` 轮，操作的是 `diff[k%3]`。
    *   **两个线程操作的是完全不同的内存地址。** 线程 A 的写入操作不会覆盖线程 B 正在读取的数据，也不会干扰线程 B 的计算。因此，**跨轮次的依赖被解除了**。线程 A 不需要等待线程 B 结束第 `k` 轮就可以开始第 `k+1` 轮。所以 Barrier 3 可以移除。

---

> Summary:两种编程模型

1. 数据并行编程模型 (Data-parallel programming model)
*   同步 (Synchronization)：单一的逻辑控制线程，但 `forall` 循环的迭代**可能**由系统并行化（在 `forall` 循环体结束时有**隐式屏障**）。
*   通信 (Communication)：在加载 (loads) 和存储 (stores) 中是**隐式**的（就像共享地址空间一样）。 特殊的内置原语用于更复杂的通信模式：例如，`reduce`（归约）。

1. 共享地址空间 (Shared address space)
*   同步 (Synchronization)：共享变量需要**互斥**（例如，通过锁）。使用**屏障 (Barriers)** 来表达计算阶段之间的依赖关系。
*   通信 (Communication)：在对共享变量的加载/存储中是**隐式**的。

数据并行模型通常更简单、更安全，你写个 `forall`，编译器自动帮你搞定所有线程的同步，你不用操心 Barrier。它把最难的同步问题藏起来了。而共享地址空间模型给了你最大的自由度，可以优化出高性能，但同时也给了你最多的 Bug。
![04_progbasics, p.50](files/slides/CS149/04_progbasics.pdf#page=50&rect=0,0,1920,1080)