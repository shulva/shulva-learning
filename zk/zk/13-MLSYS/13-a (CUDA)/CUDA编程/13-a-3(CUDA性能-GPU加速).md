# CUDA性能

什么样的计算任务能够用 GPU 获得加速呢？

![](../../../../../files/images/MLsys/13-a/13-a-3-1.png)

### 数据传输的比例

假设有两个很长的数组`a[1000000],b[1000000]`需要做数组相加的操作，而且只需要在程序的开始和结束部分进行数据传输，那么数据传输所占的比例将可以忽略不计。此时，整个 CUDA 程序的性能就大为提高。

要获得可观的 GPU 加速，就必须尽量缩减数据传输所花时间的比例。有时候，即使有些计算在 GPU 中的速度并不高，也要尽量在 GPU 中实现，避免过多的数据经由 PCIe 传递。

如果花在数据传输（CPU 与 GPU 之间）上的时间比计算本身还要多很多,那么用GPU可能比CPU还慢。

> [!question] 为什么？
> GPU 计算核心和设备内存之间数据传输的峰值理论带宽要远高于 GPU 和 CPU 之间数据传输的带宽。典型 GPU 的显存带宽理论值为几百GB每秒，而常用的连接 GPU 和 CPU 内存的 PCIe x16 Gen3 仅有 16 GB/s 的带宽。
>
> 走PCIe花的时间太多了！

### 算数强度

数组相加的问题之所以很难得到更高的加速比，是因为该问题的**算术强度（arithmetic intensity）**不高。

一个计算问题的算术强度指的是其中算术操作的工作量与必要的内存操作的工作量之比。例如， 在数组相加的问题中，在对每一对数据进行求和时需要先将一对数据从设备内存中取出来， 然后对它们实施求和计算，最后再将计算的结果存放到设备内存。

这个问题的算术强度其实是不高的，因为在取两次数据、存一次数据的情况下只做了一次求和计算。在 CUDA 中， 设备内存的读、写都是代价高昂（比较耗时）的。

如果一个问题中需要的不仅仅是简单的单次求和操作，而是更为复杂的浮点数运算，那么就有可能得到更高的加速比(单次数据存取对应更多的计算量)。

```cpp
void __global__ add(redl *a,real *b,); //约20倍加速比
void __global__ arithmetic(real *d_x, const real x0, const int N) //约1100倍加速比
{
    const int n = blockDim.x * blockIdx.x + threadIdx.x;
    if (n < N)
    {
        real x_tmp = d_x[n];
        while (sqrt(x_tmp) < x0)
        {
            ++x_tmp;
        }
        d_x[n] = x_tmp;
    }
}
```

### 并行规模

另一个影响 CUDA 程序性能的因素是并行规模。并行规模可用 GPU 中总的线程数目来衡量。

从硬件的角度来看，一个 GPU 由多个SM（streaming multiprocessor） 构成，而每个 SM 中有若干 CUDA 核心。

每个 SM 是相对独立的。一个 SM 中最多能驻留（reside）的线程个数是 1024(图灵架构)。一块 GPU 中一般有几个到几十个 SM（取决于具体的型号）。所以，一块 GPU 一共可以驻留几万到几十万个线程。如果一个核函数中定义的线程数目远小于这个数的话，就很难得到很高的加速比。

![](../../../../../files/images/MLsys/13-a/13-d-2.png)

在图a中，大概当 N ≈ 10⁴时 ，计算时间终于增长到了可以和启动的固定开销（CPU准备数据、通过驱动程序向GPU发指令、GPU初始化计算网格等）差不多的时候。在这之前，当 N < 10⁴时，总时间被固定开销主导，性能无法完全发挥(之前[数据传输的比例](#数据传输的比例)中所提到的问题)。

在图b中，则是表明在N ≈ 10⁵，此时所有SM（流式多处理器）都**被完全填满，并且有足够的“后备”线程池来完美地进行延迟隐藏**。gpu利用率到达峰值，无法再提升效率了，所以加速比也无法再上升了。
### nvprof

在 CUDA 工具箱中有一个称为 nvprof 的可执行文件，可用于对 CUDA 程序进行更多的性能剖析。

我们可以对编译好的cuda文件执行命令：`nvprof ./a.out`

对程序 add3memcpy.cu[^2] 来说，在 GeForce RTX 2070 中使用上述命令，得到的部分结果如下(单精度浮点数版本):

![](../../../../../files/images/MLsys/13-a/13-d-1.png)
### cudaEvent

CUDA 提供了一种基于 CUDA 事件（CUDA event）的计时方式，可用来给一段 CUDA 代码（可能包含了主机代码和设备代码）计时。

为简单起见，仅介绍基于 CUDA 事件的计时方法。[^1]详情请见脚注。

```cpp
	cudaEvent_t start, stop;
	CHECK(cudaEventCreate(&start));
	CHECK(cudaEventCreate(&stop));
	CHECK(cudaEventRecord(start)); //记录代表开始的事件
	cudaEventQuery(start); //刷新cuda流软件队列

	add(x, y, z, N);

	CHECK(cudaEventRecord(stop)); //记录结束事件
	CHECK(cudaEventSynchronize(stop)); //等待事件stop被记录完毕
	
	float elapsed_time; //计算事件差
	CHECK(cudaEventElapsedTime(&elapsed_time, start, stop));
	printf("Time = %g ms.\n", elapsed_time);
```


> [!NOTE] nvcc编译
> 我们可以用条件编译的方式选择程序中所用浮点数的精度
> ```
>#ifdef USE_DP typedef double real; 
>const real EPSILON = 1.0e-15;
> #else 
> typedef float real; 
> const real EPSILON = 1.0e-6f;
> #endif
> ```
> 当宏 USE_DP 有定义时，程序中的 real 就代表 double，否则代表 float。该宏可以 通过编译选项定义。
>
> 我们通过`nvcc -O3 -arch=sm_75 -DUSE_DP add1cpu.cu`来编译cuda文件。我们将总是用 -O3 选项提高性能，并且通过**-D<MACRO_NAME>**切换精度。
> 
> 具体地说，如果将 -DUSE_DP 加入编译选项， 程序中的宏 USE_DP 将有定义，从而使用双精度浮点数，否则使用单精度浮点数。

> [!quote] cuda数学库
> http://docs.nvidia.com/cuda/cuda-math-api

### 实例-数组规约

[数组规约-全局内存](13-a-4-1%20(shared%20memory）.md#数组规约-全局内存)
[加速-线程同步函数](13-a-6（线程束Warp）.md#加速-线程同步函数[%201])
[加速-线程束函数](13-a-6（线程束Warp）.md#加速-线程束函数[%202])
[加速-提高线程利用率](13-a-6（线程束Warp）.md#加速-提高线程利用率[%205])
[加速-避免反复分配与释放设备内存](13-a-6（线程束Warp）.md#加速-避免反复分配与释放设备内存)

![](../../../../../files/images/MLsys/13-a/13-a-6-3.png)


[^1]: [线程索引](../../../../../files/books/MLSys/CUDA%20编程：基础与实践_樊哲勇.pdf#page=61)
[^2]: https://github.com/brucefan1983/CUDA-Programming/blob/master/src/05-prerequisites-for-speedup/add3memcpy.cu
