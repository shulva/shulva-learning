# 全局内存


对全局内存的访问将触发内存事务（memory transaction），也就是数据传输（data transfer）。从费米架构开始，有了 SM 层次的 L1 缓存和设备层次的 L2 缓存， 可以用于缓存全局内存的访问。

在启用了 L1 缓存的情况下，对全局内存的读取将先尝试经过 L1 缓存；如果未中，则接着尝试经过 L2 缓存；如果再次未中，则直接从DRAM读取。一次数据传输处理(内存事务)的数据量在默认情况下是**32字节**。

关于全局内存的访问模式，有合并（coalesced）与非合并（uncoalesced）之分。合并访问指的是一个线程束对全局内存的一次访问请求（读或者写）导致最少数量的数据传输， 否则称访问是非合并的。

> [!NOTE] 合并度
> 
> 定量地说，可以定义一个**合并度（degree of coalescing）**，它等于线程束请求的字节数除以由该请求导致的所有数据传输处理的字节数。
> 如果所有数据传输中处理的数据都是线程束所需要的，那么合并度就是 100%，即对应合并访问。所以，也可以将合并度理解为一种资源利用率。
> 利用率越高，核函数中与全局内存访问有关的部分的性能就更好；利用率低则意味着对显存带宽的浪费。

为简单起见，我们主要以全局内存的读取和仅使用 L2 缓存的情况为例进行下述讨论。 在此情况下，一次数据传输指的就是将32字节的数据从全局内存（DRAM）通过 32 字节的L2 缓存片段（cache sector）传输到 SM。

![](../../../../../files/images/MLsys/13-a/13-a-4-2-1.png)

为了回答这个问题，我们首先需要了解数据传输对数据地址的要求：在一次数据传输中，从全局内存转移到 L2 缓存的一片内存的首地址一定是一个最小粒度（这里是 32 字节） 的整数倍。如0-31,32-63字节等。

cudaMalloc分配的内存的首地址至少是 256 字节的整数倍。所以通过cudaMalloc保证内存地址的整数倍即可。

### 合并访问 

![](../../../../../files/images/MLsys/13-a/13-a-4-2-2.png)

下面我们通过几个具体的例子列举几种常见的内存访问模式及其合并度: 

```cpp

//顺序
void __global__ add(float *x, float *y, float *z) 
{ 
	int n = threadIdx.x + blockIdx.x * blockDim.x;
	z[n] = x[n] + y[n];
} 
add<<<128, 32>>>(x, y, z)

//乱序
void __global__ add_permuted(float *x, float *y, float *z) 
{ 
	// 位操作，效率很高，交换相邻的偶数ID和奇数ID
	int tid_permuted = threadIdx.x ^ 0x1;
	int n = tid_permuted + blockIdx.x * blockDim.x;
	z[n] = x[n] + y[n];
} 
add_permuted<<<128, 32>>>(x, y, z);
```

第一个函数线程块中的线程束将访问数组 x 中第 0-31 个元素，对应 128 字节的连续内存，而且首地址一定是 256 字节的整数倍。这样的访问只需要 4 次数据传输即可完成，所以是合并访问，合并度为 100%。

第二个函数线程块中的线程束将依然访问数组 x 中第 0-31 个元素，只不过线程号与数组元素指标不完全一致而已。这样的访问是乱序的（或者交叉的）合并访问，合并度也为 100%。

### 非合并访问

```cpp

//不对齐
void __global__ add_offset(float *x, float *y, float *z) { 
int n = threadIdx.x + blockIdx.x * blockDim.x + 1; 
z[n] = x[n] + y[n];
} 
add_offset<<<128, 32>>>(x, y, z);

//跨越式
void __global__ add_stride(float *x, float *y, float *z) { int n = blockIdx.x + threadIdx.x * gridDim.x;
z[n] = x[n] + y[n];
}
add_stride<<<128, 32>>>(x, y, z);

//广播式
void __global__ add_broadcast(float *x, float *y, float *z) { int n = threadIdx.x + blockIdx.x * blockDim.x;
z[n] = x[0] + y[n];
}
add_broadcast<<<128, 32>>>(x, y, z);
```

第三个函数的线程束需要访问数组 x 中第 1-32 个元素。一次读32字节，假如数组 x 的首地址为 256 字节（或是整数倍），计算出共5次读取，最后要单独读取x[32]（虽然仍然读取了32字节）。这样的访问属于不对齐的非合并访问，合并度为 4/5 = 80%。

第四个函数index以block的大小跨越，每一对数据都不在一个连续的 32 字节的内存片段，故该线程束的访问将触发 32 次数据传输。这样的访问属于跨越式的非合并访问，合并度为 4/32 = 12.5%。

第五个函数线程块中的线程束将一致地访问数组 x 中的第 0 个元素。这只需要一次数据传输（处理 32 字节的数据），但由于整个线程束只使用了4 字节(x[0])的数据，故合并度 为 4/32 = 12.5%。

这样的访问属于广播式的非合并访问。这样的访问（如果是读数据的话）适合采用[13-a-4(CUDA性能-内存)](13-a-4(CUDA性能-内存).md)中提到的常量内存。

### 矩阵转置[^1]

```cpp

//这两个函数都可以实现矩阵转置，但是性能却会有很大差异

__global__ void transpose1(const real *A, real *B, const int N)
{
    const int nx = blockIdx.x * blockDim.x + threadIdx.x;
    const int ny = blockIdx.y * blockDim.y + threadIdx.y;
    if (nx < N && ny < N)
    {
        B[nx * N + ny] = A[ny * N + nx];
    }
}

__global__ void transpose2(const real *A, real *B, const int N)
{
    const int nx = blockIdx.x * blockDim.x + threadIdx.x;
    const int ny = blockIdx.y * blockDim.y + threadIdx.y;
    if (nx < N && ny < N)
    {
        B[ny * N + nx] = A[nx * N + ny];
    }
}

const dim3 block_size(TILE_DIM, TILE_DIM); 
const dim3 grid_size(grid_size_x, grid_size_y);

transpose1<<<grid_size, block_size>>>(d_A, d_B, N);
transpose2<<<grid_size, block_size>>>(d_A, d_B, N);
```

我们来分析一下核函数中对全局内存的访问模式。对于多维数组，x 维度的线程指标 threadIdx.x 是最内层的（变化最快），所以相邻的 threadIdx.x 对应相邻的线程。从核函数中的代码可知，相邻的 nx 对应相邻的线程，也对应相邻的数组元素（对 A 和 B 都成立）。

可以看出，在核函数 transpose1 中，对矩阵 A 中数据的访问（读取）是顺序的，但对矩阵 B 中数据的访问（写入）不是顺序的。

在核函数 transpose2 中，对矩阵 A 中数据的访问（读取）不是顺序的，但对矩阵 B 中数据的访问（写入）是顺序的。

在不考虑数据是否对齐的情况下，我们可以说核函数 transpose1 对矩阵 A 和 B 的访问分别是合并的和非合并的，而核函数 transpose2 对矩阵 A 和 B 的访问分别是非合并的和合并的。

如果用 GeForce RTX 2080ti 测试相关核函数的执行时间（采用单精度浮点数计算）。核函数 transpose1 的执行时间为 5.3 ms，而核函数 transpose2 的执行时间为 2.8 ms。

> [!question] 以上两个核函数中都有一个合并访问和一个非合并访问，但为什么性能差别那么大呢？[^2]
> 
> 这是因为，在核函数 transpose2 中，读取操作虽然是非合并的，但利用了之前提到的只读数据缓存的加载函数`__ldg()`
> 
> 从帕斯卡架构开始，如果编译器能够判断一个全局内存变量在整个核函数的范围都只可读（如这里的矩阵 A），则会自动用函数 `__ldg()` 读取全局内存， 从而对数据的读取进行缓存，缓解非合并访问带来的影响。对于全局内存的写入，则没有类似的函数可用。这就是以上两个核函数性能差别的根源。
> 
> 所以，在不能同时满足读取和写入都是合并的情况下，一般来说应当尽量做到合并的写入。


![](../../../../../files/images/MLsys/13-a/13-a-4-2-3.png)


[^1]: https://github.com/brucefan1983/CUDA-Programming/blob/master/src/07-global-memory/matrix.cu

[^2]: [CUDA 编程：基础与实践_樊哲勇, 页面 76](files/books/MLSys/CUDA%20编程：基础与实践_樊哲勇.pdf#page=76&selection=102,2,102,7)
