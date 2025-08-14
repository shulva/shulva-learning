# CUDA基础


> [!quote] Compute Unified Device Architecture
> [CUDA C++ Programming Guide](https://docs.nvidia.com/cuda/cuda-c-programming-guide)
> [CUDA C++ Best Pracitces Guide](https://docs.nvidia.com/cuda/cuda-c-best-practices-guide)
> [Turing架构优化](https://docs.nvidia.com/cuda/turing-tuning-guide)

### grid和Block


首先，我们要知道，GPU 只是一个设备，要它工作的话还需要有一个主机(host)给它下达命令。这个主机一般来说CPU。

所以，一个真正利用了 GPU 的 CUDA 程序既有主机代码，也有设备代码（可以理解为需要设备执行的代码）。

主机对设备的调用是通过核函数（kernel function）来实现的。所以，一个典型的、简单的 CUDA 程序的结构具有下面的形式：

```cpp
int main(void) { 
	主机代码 
	核函数的调用 
	主机代码 
	return 0; 
}
```

CUDA 中的核函数与 C++ 中的函数是类似的，但一个显著的差别是：它必须被限定词 （qualifier）__global__ 修饰。另外，核函数的返回类型必须是空类型，即 void。

以下是一段代码示例：[^1]

---
```cpp
#include <stdio.h> 
__global__ void hello_from_gpu() { 
	//线程索引
	const int b = blockIdx.x;  //blockIdx的范围取决于grid_size
	const int tx = threadIdx.x;//threadIdx的范围取决于block_size
	const int ty = threadIdx.y; 

	//会以并行方式Print 1*2*4条语句
	printf("Hello World from block-%d and thread-(%d, %d)!\n", b, tx, ty);  
	} 

int main(void)  { 
	const dim3 block_size(2, 4); // block中线程数为2*4=8
	
	//<<<grid_size,block_size>>
	hello_from_gpu<<<1, block_size>>>(); 
	
	cudaDeviceSynchronize(); //同步主机与设备,能够促使缓冲区刷新
	return 0; 
}
```

一块 GPU 中有很多计算核心，从而可以支持很多线程（thread）。主机在调用一个核函数时，必须指明需要在设备中指派多少个线程，不然设备不知道如何工作。

三括号中的数就是用来指明核函数中的线程数目以及排列情况的。核函数中的线程常组织为若干线程块（thread block）：三括号中的第一个数字 可以看作线程块的个数，第二个数字可以看作每个线程块中的线程数。一个核函数的全部线程块构成一个网格（grid），而线程块的个数就记为网格大小（grid size）。每个线程块中含有同样数目的线程，该数目称为线程块大小（block size）。

我们也可以用结构体 dim3 定义“多维”的网格和线程块：

```cpp
dim3 grid_size(Gx, Gy, Gz); 
dim3 block_size(Bx, By, Bz);

dim3 grid_size(2, 2); // 等价于 dim3 grid_size(2, 2, 1); 
dim3 block_size(3, 2); // 等价于 dim3 block_size(3, 2, 1);
```

![](../../../../../files/images/MLsys/13-a-1.png)

一个线程块中的线程还可以细分为不同的线程束（thread warp）。

一个线程束（即一束线程）是同一个线程块中相邻的 warpSize 个线程。warpSize 也是一个内建变量，表示线程束大小，其值对于目前所有的 GPU 架构都是 32。所以，一个线程束就是连续的 32 个线程。

![](../../../../../files/images/MLsys/13-a-2.png)

> [!NOTE] 大小限制
> CUDA 中对能够定义的网格大小和线程块大小做了限制。
> 
> 网格大小在 x、y 和 z 这 3 个方向的最大允许值分别为 2^31-1、65535 和 65535； 
>
> 线程块大小在 x、y 和 z 这 3 个方向的最大允许值分别为 1024、1024 和 64。另外还要求线程块总的大小，即 blockDim.x、blockDim.y 和 blockDim.z 的乘积不能大于 1024。也就是说，不管如何定义，一个线程块最多只能有 1024 个线程。
> 

> [!question] cuda的编译[^3]
> CUDA 的编译器驱动（compiler driver）**nvcc** 会先将全部源代码分离为主机代码和设备代码。主机代码完整地支持 C++ 语法，但设备代码只部分地支持 C++。
> 
> nvcc 先将设备代码编译为 PTX（Parallel Thread eXecution）伪汇编代码，再将 PTX 代码编译为二进制的 cubin目标代码。
> 
> 在将源代码编译为 PTX 代码时，需要用选项 -arch=compute_XY 指定一个虚拟架构的计算能力，用以确定代码中能够使用的 CUDA 功能。
> 
> 在将 PTX 代码编译为 cubin 代码时，需要用选项 -code=sm_ZW 指定一个真实架构的计算能力，用以确定可执行文件能够使用的 GPU。
> 
> 真实架构的计算能力必须等于或者大于虚拟架构的计算能力。例如:
> 
> ```
> -arch=compute_35 -code=sm_60 //正确
> -arch=compute_60 -code=sm_35 //报错
> ```
> 选项 -code=sm_ZW 指定了 GPU 的真实架构为 Z.W。对应的可执行文件只能在主版本号为 Z、 次版本号大于或等于W的GPU 中运行。


[^1]: [线程索引](../../../../../files/books/MLSys/CUDA%20编程：基础与实践_樊哲勇.pdf#page=27)

[^3]: [cuda编译](../../../../../files/books/MLSys/CUDA%20编程：基础与实践_樊哲勇.pdf#page=34)
