# 规约

### 规约1

[数组规约-全局内存](13-a-4-1%20(shared%20memory）.md#数组规约-全局内存)
[加速-线程同步函数](13-a-6（线程束Warp）.md#加速-线程同步函数[%201])
[加速-线程束函数](13-a-6（线程束Warp）.md#加速-线程束函数[%202])
[加速-提高线程利用率](13-a-6（线程束Warp）.md#加速-提高线程利用率[%205])
[加速-避免反复分配与释放设备内存](13-a-6（线程束Warp）.md#加速-避免反复分配与释放设备内存)


![](../../../../../files/images/MLsys/13-a/13-a-6-3.png)

### 规约2[^1]

###### baseline版本

这部分与[数组规约-共享内存](13-a-4-1%20(shared%20memory）.md#数组规约-共享内存)相似，只是线程计算的数据位置不同。线程利用率会随着迭代而降低。但是这个版本的warp divergence会更严重。

```cpp
template<int BLOCK_SIZE>
__global__ void reduce_kernel_baseline(float* input, float* output, int n) {

    __shared__ float sdata[BLOCK_SIZE];
    int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    sdata[tid] = input[i];//这里其实缺少对于i<n的判断，可能会出错 
    __syncthreads();
	
    for(unsigned int s=1; s < blockDim.x; s *= 2) {
        if((tid & (2*s-1)) == 0) {
            sdata[tid]+=sdata[tid+s];
        }
        __syncthreads();
    }
    
    if(tid == 0) output[blockIdx.x] = sdata[0];
}
```


![](../../../../files/images/MLsys/13-b/13-b-1.jpg)

- s=1: (tid & 1) == 0 -> tid是偶数。活跃线程是0, 2, 4, ... 存在warp divergence
- s=2: (tid & 3) == 0 -> tid是4的倍数。活跃线程是0, 4, 8, ... 存在warp divergence
- s=4: (tid & 7) == 0 -> tid是8的倍数。活跃线程是0, 8, 16, ... 存在warp divergence

GPU中以Warp作为调度单位，每个Warp中包含32个thread，而每个thread负责一个元素的相加，这导致Warp中大部分thread处于空闲状态（也就是图中的白色格子线程什么也没做）， 这就是warp divergence问题。

由于s=32时，一个warp中由于严重的warp divergence，只有一个线程在工作，所以也不存在bank conflict了（一个线程访问一个Bank中的两个数据不会冲突）。
###### 优化1：warp divergence

优化的方法就是让工作的thread尽量都在一个warp中。所以在这个版本中，我们将thread与数据的对应给解耦合:
数据的计算方式保持不变， 但是给线程分配的情况变了，不再是数据下标和线程的下标一一对应，将线程尽可能的聚拢起来，减少warp divegence。
如果每个warp都有divergence，即使工作的线程数量相同，效率也是比不过没有warp divergence的程序的，因为warp内部会对divergence做[串行化执行](../13-c%20(数据并行体系结构）/13-c-2%20(GPU编程模型).md#^13-c-2-1)。

```cpp
template<int BLOCK_SIZE>
__global__ void reduce_kernel_v1(float* input, float* output, int n) {

    __shared__ float sdata[BLOCK_SIZE];
    int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + threadIdx.x;
	
    sdata[tid] = input[i];
    __syncthreads();
    
    for(unsigned int s=1; s < blockDim.x; s *= 2) {
            int index = threadIdx.x * 2 * s;
			
            //通过if限定tid 从而限定参与计算的线程
			//threadIdx.x < blockDim.x/(2*s)
			
            if(2*s*threadIdx.x < blockDim.x) {   
                sdata[index] += sdata[index + s];
            }
        __syncthreads();
    }
    
    if(tid == 0) output[blockIdx.x] = sdata[0];
}
```

![](../../../../files/images/MLsys/13-b/13-b-2.jpg)

thread:
- s=1: tid为从0-BLOCK_SIZE/2的所有线程，index为0,2,4.. warp没有divergence
- s=2: tid为从0-BLOCK_SIZE/4的所有线程，index为0,4,8.. warp没有divergence
- ... 直到tid为从0-32时，此时为一个warp，没有divergence。之后的才会出现divergence。

shared memory:
- s=1: (0,1) (2,3) (4,5) ...(index,index+s) 做计算，写入0,2,4..号单元
- s=2: (0,2) (4,6) (8,10) 做计算，写入0,4,8...号单元

在第k轮迭代中，被当作加数（`sdata[index + s]`）读取的内存单元，在下一轮（第k+1轮）迭代中，将不再被读取，也不会被写入。

###### 优化2：bank conflict

bank conflict是发生在同一个warp中，不同的线程对于同一个bank的访问。

但是优化1中的写法会有严重的bank conflict问题。当2\*s为32的整数倍时，不同线程会读取同一bank的地址，会产生严重的冲突。

以下代码与[数组规约-共享内存](13-a-4-1%20(shared%20memory）.md#数组规约-共享内存)思路相同。

```cpp
template<int BLOCK_SIZE>
__global__ void reduce_kernel_v2(float* input, float* output, int n) {

    __shared__ float sdata[BLOCK_SIZE]; 
    int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    
    sdata[tid] = input[i];
    __syncthreads();
    
    for(int i=blockDim.x/2; i > 0; i/=2) { // 用>>1效率更高
        if(threadIdx.x < i) {
            sdata[threadIdx.x] += sdata[threadIdx.x + i];
        }
        __syncthreads();
    }
    
    if(tid == 0) output[blockIdx.x] = sdata[0];
}
```

![](../../../../files/images/MLsys/13-b/13-b-3.jpg)

`sdata[threadIdx.x]`中所有的下标都是不同的，所以它们访问的Bank也都是不同的。
`sdata[threadIdx.x+i]`同理，没有bank conflict。

###### 优化3：计算访存并行

在之前的版本中，我们直接将数组直接从global memory全部load到shared memory中， 但是实际上，我们可以在load到shared memory的同时进行计算,如下图:

![](../../../../files/images/MLsys/13-b/13-b-4.jpg)

在循环中，线程的利用率是越来越低的(1/2,1/4....)。相比之下，在归约之前，将全局内存中的数据复制到共享内存的操作对线程的利用率是 100% 的。我们可以利用这部分的线程在规约前做一些操作。

这里的程序事实上与[加速-提高线程利用率](13-a-6（线程束Warp）.md#加速-提高线程利用率[%205])中的程序思想相同，链接中程序的效率甚至更高。

```cpp
template<int BLOCK_SIZE>
__global__ void reduce_kernel_v3(float *input, float* output, int n){

    __shared__ float sdata[BLOCK_SIZE];
    float *input_begin = input + blockDim.x * blockIdx.x * 2;
    //blockDim.x*2是说明处理的数据量是以前的两倍
    int tid = threadIdx.x;

	//blockDim.x相当于偏移量
    sdata[tid] = input_begin[tid] + input_begin[tid + blockDim.x];
    __syncthreads();
    
    for(int i=blockDim.x/2; i > 0; i/=2) {
        if(threadIdx.x < i) {
            sdata[threadIdx.x] += sdata[threadIdx.x + i];
        }
        __syncthreads();
    }
    
    if(tid == 0) output[blockIdx.x] = sdata[0];
}
```

###### 优化4：warp reduce

上述的计算流程中， 每一个step的结算结束后，我们都需要同步所有的warp，但实际上，当reduce到一个warp内部时已经不需要sync（warp内部线程simt天然同步）了，因此我们考虑在最后一个warp内部单独进行reduce。

```cpp
template<int BLOCK_SIZE>
__global__ void reduce_kernel_v4(float *input, float* output, int n){

    volatile __shared__ float sdata[BLOCK_SIZE];
    float *input_begin = input + blockDim.x * blockIdx.x * 2;
    int tid = threadIdx.x;
    
    sdata[tid] = input_begin[tid] + input_begin[tid + blockDim.x];
    __syncthreads();
    
    for(int i=blockDim.x/2; i > 32; i/=2) {
        if(threadIdx.x < i) {
            sdata[threadIdx.x] += sdata[threadIdx.x + i];
        }
        __syncthreads(); 
    }
    
    if(tid < 32) {
        sdata[tid] += sdata[tid + 32];
        sdata[tid] += sdata[tid + 16];
        sdata[tid] += sdata[tid + 8];
        sdata[tid] += sdata[tid + 4]; 
        sdata[tid] += sdata[tid + 2];
        sdata[tid] += sdata[tid + 1];
    }

    if(tid == 0) output[blockIdx.x] = sdata[0];
}
```

> [!question] volatile的作用？
> 
> 注意，这里还在sdata中添加了一个`volatile`关键字， 该关键字的作用是告诉编译器，让编译器不要帮我们使用寄存器重用来优化代码，而是每次都重新从shared memory中读取数据。
> 
> 只有 Warp 0 (tid 0-31) 会执行这个代码块。
> - 编译器的视角: 编译器(NVCC)在分析这段代码时，会发现线程 tid 在连续地、反复地读写 `sdata[tid]` 这个**地址固定**的内存位置。
> - 编译器的优化:
>     - 这个线程一直在用 `sdata[tid]`，没必要每次都去访问速度相对较慢的共享内存。
>     - 可以先把 sdata[tid] 的值加载到一个速度快的**私有寄存器**（比如 R1）里。
>     - 然后，所有的加法操作 R1 += ... 都在这个寄存器里完成。
>     - 等到最后，再把寄存器 R1 里的最终结果**一次性写回**到共享内存 `sdata[tid]` 中。
> 
> 但是，这个Warp内规约的正确性，依赖于一个**隐式的、跨线程的数据流**。例如，`sdata[0]` 在第k步的正确值，依赖于 `sdata[16]` 在第k-1步被正确更新。
> 
> 编译器优化后，每个线程只在自己的寄存器上计算，不会把结果及时地更新到共享内存，最后会导致其他需要这个结果的线程拿不到最新的数据，最终导致规约结果完全错误。

当然，也可以把for的循环变成if然后自己写， 减少编译生成的指令，降低icache miss。但是该算子的瓶颈并不是icache miss，而是访存带宽，性能几乎没有提升。

```cpp
// 假设循环代码：在 tid < 32 的分支内
for (int offset = WARP_SIZE / 2; offset > 0; offset >>= 1) {
    sum += __shfl_down_sync(0xFFFFFFFF, sum, offset);
}
```

> [!question] 循环展开的作用
> 1.消除循环开销，减少指令数量
> - 手动展开后，整个代码块变成了一个**线性的指令序列**。编译器可以直接将其翻译成一连串的SHFL和FADD指令，完全没有循环中需要的初始化、比较、分支和更新指令。
> - 结论: 对于一个迭代次数很少且固定的循环（如此处的5次），手动展开可以显著减少总的指令数量，从而降低执行周期。
>
> 2.为编译器提供更大的指令级并行 (ILP) 优化空间
> 
> - 指令级并行 (Instruction-Level Parallelism, ILP): 现代处理器（包括GPU）的流水线设计，允许它在同一个时钟周期内，同时执行多条没有相互依赖关系的指令。
>     
> - 循环版本的限制: 在一个循环体内，sum的值在上一行刚刚被更新，下一行就要立刻使用它 (sum += ...)。这种**写后读 (Read-After-Write, RAW) 的数据依赖**非常强，限制了编译器进行指令重排和优化的空间。编译器很难将不同迭代的指令交错执行。
>     
> - 展开版本的优势:  
>     当循环被展开成一个更长的、线性的指令序列后，编译器拥有了更大的视野。它可以分析整个指令序列中的数据依赖关系，并进行更智能的指令调度 (Instruction Scheduling)。
>     - 例如，编译器可能会发现，在等待一条SHFL指令的结果（从另一个线程取数有几个周期的延迟）时，它可以先去执行一些不相关的其他指令。
>     - 虽然在这个特定的规约例子中，数据依赖很强，ILP的潜力有限，但在更复杂的Warp级计算中，展开循环能给编译器提供重排指令以**隐藏延迟 (latency hiding)**的机会。它可以更好地安排指令，以避免流水线停顿。
> 
> 3.消除对循环计数器的寄存器占用
> - 循环版本: 需要一个额外的寄存器来存储循环变量offset。
> - 展开版本: 16, 8, 4, 2, 1 这些值都变成了**立即数 (immediate values)**，直接编码在指令中，**不需要占用宝贵的寄存器资源**。


在GPU编程中，寄存器是一种非常稀缺的资源。每节省一个寄存器，就可能意味着一个SM（流多处理器）可以容纳更多的活跃Warp，从而提升整体的**占用率 (Occupancy)**，这对于隐藏全局内存访问延迟至关重要。虽然只节省一个寄存器看起来不多，但在追求极致性能的场景下，积少成多。

在v3规约的最后几轮，整个线程块的所有Warp都必须在`__syncthreads()`处集合。即使只有Warp 0在工作，Warp 1到7也必须陪着它一起同步。这个**跨Warp的同步**是一个相对较慢的操作，会增加Warp 0不必要的等待时间。

v4使用`if(tid<32)`使其他warp提前退场。Warp 0可以独立地、无等待地完成自己的收尾工作。这就直接降低了Warp 0的等待延迟。于是warp能够更快的被调度，访存指令能够更快发射，导致带宽提升。

> [!NOTE]
> 从这里其实不难看出，reduce的性能瓶颈是memory bound而不是compute，但是如果由于数据依赖的原因导致warp stall，为了更快的发射出访存指令，减少同步关系才能够才来更大的收益。
> 
> 规约操作本身只是大量的加法，计算强度（每个字节内存访问对应的计算量）非常低。瓶颈永远在于**如何高效地从内存中读取数据并将其汇聚起来**。所以，它是一个典型的**访存密集型 (Memory-Bound)** 算法。
> 
> 即使是Memory-Bound，如果你不能持续地向内存系统发出请求，带宽也无法被充分利用。在v3中，`__syncthreads()`所代表的**数据依赖**（跨Warp依赖）就导致了Warp的停顿（stall）。

###### 优化5：使用shuffle指令在warp内部reduce

[`__shfl_down_sync`](../13-a%20(CUDA)/CUDA编程/13-a-6（线程束Warp）.md#线程束内的基本函数)是CUDA提供的一个warp级别的shuffle指令，用于在同一个warp内的线程之间直接交换数据，**无需通过shared memory**。详情流程请看注释。

warp reduce的次数取决于blocksize的大小，代码共进行了两次warp reduce。次数计算公式为$log_{32}(blocksize)$取上界。

```cpp
template<int BLOCK_SIZE>
__global__ void reduce_kernel_v5(float *input, float* output, int n){

    const int WARP_SIZE = 32;
    float sum = 0.f;
    float *input_begin = input + blockDim.x * blockIdx.x * 2;
    int tid = threadIdx.x;
	// 每个线程加载2个元素并在寄存器中求和
    sum = input_begin[tid] + input_begin[tid + blockDim.x];
	// 每个Warp独立地对自己的32个sum值进行规约
    sum += __shfl_down_sync(0xffffffff, sum, 16);
    sum += __shfl_down_sync(0xffffffff, sum, 8);
    sum += __shfl_down_sync(0xffffffff, sum, 4);
    sum += __shfl_down_sync(0xffffffff, sum, 2);
    sum += __shfl_down_sync(0xffffffff, sum, 1);

	//warpLevelSums数组中会存放所有Warp的部分和
    __shared__ float warpLevelSums[32];

    //laneId =0 -> tid = 0,32,64.. 将warp的sum和写入shared memory
    const int laneId = tid % WARP_SIZE;
    const int warpId = tid / WARP_SIZE;
    
    if(laneId==0) warpLevelSums[warpId] = sum;
    __syncthreads();
    
    if(tid < 32){
		// 从共享内存加载Warp级的部分和,数组元素不够则初始化为0，保证正确性
        sum = (tid < blockDim.x /32) ? warpLevelSums[tid] : 0.f;
        
		// 再次进行Warp内规约
        sum += __shfl_down_sync(0xffffffff, sum, 16);
        sum += __shfl_down_sync(0xffffffff, sum, 8);
        sum += __shfl_down_sync(0xffffffff, sum, 4);
        sum += __shfl_down_sync(0xffffffff, sum, 2);
        sum += __shfl_down_sync(0xffffffff, sum, 1);
    }
    
    if(tid == 0) output[blockIdx.x] = sum;
}
```

![](../../../../files/images/MLsys/13-b/13-b-5.jpg)

![](../../../../files/images/MLsys/13-b/13-b-6.jpg)

| 版本       | 带宽 (GB/s) | 耗时 (ms) | 说明                                   |
| -------- | --------- | ------- | ------------------------------------ |
| Baseline | 166.72    | 3.23ms  | 基准版本，存在warp divergence问题             |
| 优化一      | 232.72    | 2.32ms  | 解决warp divergence问题，但存在bank conflict |
| 优化二      | 239.72    | 2.25ms  | 解决bank conflict问题                    |
| 优化三      | 463.91    | 1.16ms  | 计算访存并行                               |
| 优化四      | 802.78    | 0.67ms  | warp reduce                          |
| 优化五      | 798.22    | 0.672ms | 循环完全展开                               |
| 优化六      | 863.39    | 0.619ms | shuffle reduce                       |


[^1]: https://zhuanlan.zhihu.com/p/17996548596
