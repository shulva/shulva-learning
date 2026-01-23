# SPMD

![L03_progmodel, p.4](files/slides/hias-parellel/L03_progmodel.pdf#page=4&rect=0,0,720,540)

程序以**单线程**开始执行，当调用 SPMD 函数时，会分裂出多个并行的**逻辑实例**（Instances），这些实例运行**同一段代码**但处理**不同的输入数据**。任务完成后，所有实例汇合，程序恢复为单线程继续执行。
简而言之，就是主线程发起 -> 多实例并行处理 -> 汇合返回的过程。
![03_multicore2-ispc, p.50](files/slides/CS149/03_multicore2-ispc.pdf#page=50&rect=0,0,1920,1080)

---
##  Case Study:sin(x) in ispc version 1

我们还是以计算sin(x)的Taylor 展开表达式为样例:
泰勒循环展开terms位，对于 N 个浮点数数组`x[N]`中的每个元素，求解`sin(x[i])`，把N个结果对应存储到`result[N]`中
```cpp
void sinx(int N, int terms, float* x, float* result) { 
	for (int i=0; i<N; i++) {
	    float value = x[i]; 
	    float numer = x[i] * x[i] * x[i];
	    int denom = 6;// 3! 
	    int sign = -1; 
		
	    for (int j=1; j<=terms; j++) { 
		    value += sign * numer / denom;
		    numer *= x[i] * x[i];
		    denom *= (2*j+2) * (2*j+3);
		    sign *= -1; 
		}
		 
		result[i] = value; 
	} 
}
```
使用 Intel SPMD Program Compiler (ISPC)来对程序进行并行化改造。
SPMD 程序抽象: 调用 ISPC 函数会产生一组"gang"的ISPC 程序实例（program instances） 
所有实例并发运行 ISPC 代码 ，每个实例都有自己对于local variable(blue variables in code)的拷贝。
函数return返回时，所有实例都已完成。看看ispc程序的样子，cuda是不是很像它？
![03_multicore2-ispc, p.32](files/slides/CS149/03_multicore2-ispc.pdf#page=32&rect=0,0,1920,1080)

以下是对于关键术语`programCount,programIndex,uniform`的解释。
uniform use is purely an optimization. Not needed for correctness.
![L03_progmodel, p.7](files/slides/hias-parellel/L03_progmodel.pdf#page=7&rect=0,0,720,540)

SPMD programming abstraction上文已解释过，不用看这里的，专注右边就好。
![L03_progmodel, p.8](files/slides/hias-parellel/L03_progmodel.pdf#page=8&rect=0,0,720,540)

其实具体怎么指派取决于你程序怎么写。
![L03_progmodel, p.9](files/slides/hias-parellel/L03_progmodel.pdf#page=9&rect=0,0,720,540)

> 对于所有程序实例,一条单独的"packed vector load"指令 `vmovaps *` 可以高效地实现：`float value = x[idx];`

因为这 8 个值在内存中是**连续的**。`i=0`时，这 8 个实例正在同时访问内存地址 0, 1, 2, 3, 4, 5, 6, 7
CPU 看到你要读这 8 个连续的数，它不需要发 8 次 load 指令。它只需要发一条 `vmovaps` (Vector Move Aligned Packed Single-precision) 指令。这条指令能一次性把 256 位的数据从内存搬到向量寄存器里，很好地利用了 SIMD 硬件。
![03_multicore2-ispc, p.39](files/slides/CS149/03_multicore2-ispc.pdf#page=39&rect=0,0,1920,1080)

---
## Case Study:sin(x) in ispc version 2

再看另一个元素到实例的阻塞分配(Blocked assignment)的例子。
```cpp
export void sinx(
    uniform int N,
    uniform int terms,
    uniform float* x,
    uniform float* result)
{
    // assume N % programCount = 0
    uniform int count = N / programCount;
    int start = programIndex * count;
    for (uniform int i=0; i<count; i+=programCount)
    {
        int idx = i + programIndex;
        float value = x[idx];
        float numer = x[idx] * x[idx] * x[idx];
        uniform int denom = 6; // 3!
        uniform int sign = -1;

        for (uniform int j=1; j<=terms; j++)
        {
            value += sign * numer / denom;
            numer *= x[idx] * x[idx];
            denom *= (2*j+2) * (2*j+3);
            sign *= -1;
        }
        result[idx] = value;
    }
}
```

程序示例负责处理的元素与交叉指派不同，其实怎么分配取决于你程序怎么写。但是事实上，不同的分配是虽然最终结果都是正确的，但是最后的性能却是不同的。
![L03_progmodel, p.12](files/slides/hias-parellel/L03_progmodel.pdf#page=12&rect=0,0,720,540)

现在，对于所有程序实例，它们访问的是内存中 8 个**不连续**的值。这是便需要使用 **"gather" (收集)** 指令`vgatherdps` 来实现（gather 是一种更复杂、开销更大的 SIMD 指令……）。所以这里显然交错分配性能更好。
而且如果这个数据之间间隔太长，超过了cache line的容纳范围，我们的性能还会进一步下降。
![03_multicore2-ispc, p.40](files/slides/CS149/03_multicore2-ispc.pdf#page=40&rect=0,0,1920,1080)

## Abstraction&Implementation:for-each

> Abstraction vs. Implementation

*   **不能混淆抽象的语义（含义）与其实现的细节。**

*   **抽象 (Abstraction)**：
    *   给定一个程序，并给定所使用操作的语义，该程序将计算出的**答案是什么**？
    *   **语义 (Semantics)**：编程模型提供的操作意味着什么？

*   **实现 (Implementation)（又称调度 Scheduling）**：
    *   这个答案将**如何在并行机器上被计算出来**？程序的各个操作将以什么（潜在的并行）顺序被执行？这些操作将由哪个线程计算？由哪个执行单元计算？由向量指令的哪个通道 (lane) 计算？

*   你的目标应当是给定一个程序，并了解并行编程模型是如何实现的，你能在脑海中trace并行计算机的每个部分在程序执行的每一步中正在做什么。
---

*   **单程序多数据 (SPMD)是外在的编程模型**
    *   程序员所认为的：运行一个程序组就是生成 `programCount` 个逻辑指令流（每个流都有不同的 `programIndex` 值）。
    *   这就是编程抽象 (abstraction)。程序是基于这种抽象编写的。

*   **单指令多数据 (SIMD)才是底下的实现**
    *   ISPC 编译器生成**向量指令**（例如 AVX2, ARM NEON），这些指令负责执行 ISPC 程序组所需的逻辑。
    *   ISPC 编译器负责将**条件控制流**（如 if-else）映射到向量指令（通过**屏蔽向量通道 (masking vector lanes)** 等方式）。

*   **ISPC 的语义可能很棘手**
    *   SPMD 抽象 + **uniform** 值（这允许实现细节稍微透过抽象层暴露出来一点点）。其通过对程序抽象的高性能实现使程序整体性能到达计算峰值
![03_multicore2-ispc, p.49](files/slides/CS149/03_multicore2-ispc.pdf#page=49&rect=0,0,1920,1080)

我们可以使用 foreach 提高抽象级别。
假设程序员只想把循环交给编译器，让他去做并行化。循环中只要正常以串行逻辑去写代码，类似如下代码就好：
```cpp
foreach (i = 0 ... N) { 
	float val = x[i]; 
	float result; 
	// do work here to compute 
	// result from val 
	y[i] = result; 
}
```

foreach: 关键 ISPC 语言结构 n 用来声明并行循环迭代。
程序员指明，for-each的代码是程序组中的程序实例必须协同执行的迭代。程序员将具体的实现交给ispc编译器去做(不用去指定`programCount,programIndex`)。
ISPC 的实现将各个迭代分别分配给程序组中的各个程序实例
当前的 ISPC 的实现将执行静态交错分配（static interleaved assignment） 但抽象（abstraction ）允许不同的分配方式。
具体的实现也完全可能是以下的形式。
![03_multicore2-ispc, p.42](files/slides/CS149/03_multicore2-ispc.pdf#page=42&rect=0,0,1920,1080)

在简单场景下，通过 `foreach` 结构，程序员可以像编写串行代码一样思考，只需关注“对每个元素独立执行操作”，除了需要注意 `uniform` 变量和跨实例通信（如 `reduceAdd`）外，几乎没有并行编程的负担
然而，ISPC 本质上仍是一种low-level language，它通过暴露 `programIndex` 和 `programCount`，赋予了程序员对每个并行实例行为和数据访问的精确控制权，我们确实可以通过这些变量写出性能[更好更优秀的代码](files/slides/CS149/03_multicore2-ispc.pdf#page=53)。
但这也意味着程序员可能写出存在竞态条件或依赖特定硬件宽度（仅在特定 `programCount` 下正确）的脆弱代码。
![03_multicore2-ispc, p.52](files/slides/CS149/03_multicore2-ispc.pdf#page=52&rect=0,0,1920,1080)

---
## Case Study:reduction

在左边代码这里，**sum 的类型是 float**，对于所有程序实例，它是**不同的变量** ，是原来变量的多份拷贝。
无法将一个变量的“多份拷贝”返回给调用它的 C 代码，因为 C 代码只期望收到一个 float 类型的返回值，8个实例8个sum，该返回哪一个呢？所以最后会产生类型错误。
    
右边的代码中，**sum 的类型是 uniform float**，对于所有程序实例，它是**同一个变量**。
但是`x[i]` 是一个 varying 的值（因为每个实例读到的 `x[i]` 都不一样）。
这里，你试图把 8 个不同的值**同时**加到 1 个共享变量sum 里。这在并行编程中不仅仅是竞态条件 (Race Condition)，在 ISPC 的类型系统中更是直接禁止的(没有对应的simd操作，会生成低效的串行加法指令序列)。     
![03_multicore2-ispc, p.46](files/slides/CS149/03_multicore2-ispc.pdf#page=46&rect=0,0,1920,1080)

正确的方法如下。
每个程序实例累积一个私有的部分元素的和（无通信） 
使用 reduce_add()跨实例通信原语将部分和(partial)加在一起。结果是所有程序实例的总和相同（reduce_add() 返回统一的浮点数）。ISPC跨示例的操作有[这些](files/slides/CS149/03_multicore2-ispc.pdf#page=48)。
ISPC 代码`sum_summary_AVX()`将以类似于将手写 C代码 + AVX内建指令进行融合，程序员很难手动写这种代码。
![03_multicore2-ispc, p.47](files/slides/CS149/03_multicore2-ispc.pdf#page=47&rect=0,0,1920,1080)

ISPC 程序组的抽象是通过多条 SIMD 指令在**一个**计算核心上实现完成的。 所以前面slides中显示的所有代码只会在处理器的一个计算核心上执行。 ISPC 包含另一个抽象——task：用于完成对多核的程序执行（multi-core execution）。
task在此不详谈。


