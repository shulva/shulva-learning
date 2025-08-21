# CUDA流

CUDA 程序的并行层次主要有两个，一个是核函数内部的并行，一个是核函数外部的并行。

我们之前讨论的都是核函数内部的并行。**核函数外部的并行**主要指： 
1. 核函数计算与数据传输之间的并行。 
2. 主机计算与数据传输之间的并行。 
3. 不同的数据传输（`cudaMemcpy` 函数中的第4个参数）之间的并行。 
4. 核函数计算与主机计算之间的并行。 
5. 不同核函数之间的并行。

![](../../../../../files/images/MLsys/13-a/13-a-7-5.png)

一个 CUDA 流指的是由主机发出的在一个设备中执行的 CUDA 操作（即和 CUDA 有关的操作，如主机－设备数据传输和核函数执行）序列。除了主机端发出的流，还有设备端发出的流。

一个 CUDA 流中各个操作的次序是由主机控制的，按照主机发布的次序执行。然而，来自于两个不同 CUDA 流中的操作不一定按照某个次序执行， 而**有可能并发或交错地执行。**

任何 CUDA 操作都存在于某个 CUDA 流中，要么是默认流（default stream），也称为空流 （null stream），要么是明确指定的非空流。
在之前的章节中，我们没有明确地指定 CUDA 流， 所有的 CUDA 操作都是在默认的空流中执行的。

非默认的 CUDA 流（也称为非空流）是在主机端产生与销毁的。一个 CUDA 流由类型为`cudaStream_t`的变量表示

CUDA流可由如下函数产生和销毁：

```cpp
cudaError_t cudaStreamCreate(cudaStream_t*)
cudaError_t cudaStreamDestroy(cudaStream_t)
```

```cpp
cudaStream_t stream_1;
cudaStreamCreate(&stream_1);// 注意,传流的地址 
cudaStreamDestroy(stream_1);
```

为了实现不同 CUDA 流之间的并发，主机在向某个CUDA 流中发布一系列命令之后必须马上获得程序的控制权，不用等待该 CUDA 流中的命令在设备中执行完毕。这样，就可以通过主机产生多个相互独立的 CUDA 流。

为了检查一个 CUDA 流中的所有操作是否都在设备中执行完毕，CUDA运行时API提供了如下两个函数：
```cpp
cudaError_t cudaStreamSynchronize(cudaStream_t stream); cudaError_t cudaStreamQuery(cudaStream_t stream);
```

函数`cudaStreamSynchronize`会强制阻塞主机，直到 CUDA 流stream中的所有操作都执行完毕。

函数 `cudaStreamQuery` 不会阻塞主机，只是检查CUDA流 stream中的所有操作是否都执行完毕。若是，返回cudaSuccess，否则返回 cudaErrorNotReady。

### CUDA默认流加速-示例[^1]

然同一个 CUDA 流中的所有 CUDA 操作都是顺序执行的，但依然可以在默认流中重叠主机和设备的计算。

在数组相加的 CUDA 程序中与 CUDA 操作有关的语句如下：
```cpp
cudaMemcpy(d_x, h_x, M, cudaMemcpyHostToDevice); cudaMemcpy(d_y, h_y, M, cudaMemcpyHostToDevice); sum<<<grid_size, block_size>>>(d_x, d_y, d_z, N); cudaMemcpy(h_z, d_z, M, cudaMemcpyDeviceToHost);
```

从设备的角度来看，以上4个CUDA操作语句将在默认的 CUDA 流中按代码出现的顺序依次执行。从主机的角度来看，数据传输是阻塞的。

在进行数据传输时，主机是闲置的，不能进行其他操作。不同的是，核函数的启动是异步的（asynchronous），或者说是非阻塞的（non-blocking）， **主机发出命令之后，不会等待该命令执行完毕，而会立刻得到程序的控制权。主机紧接着会发出从设备到主机传输数据的命令cudaMemcpy。**

然而，该命令不会被立即执行，因为这是默认流中的 CUDA 操作，必须等待前一个 CUDA 操作（即核函数的调用）执行完毕才会开始执行。

所以，主机在发出核函数调用的命令之后，会立刻发出下一个命令。此时可以执行主机的计算的任务，那么主机就会在设备执行核函数的同时去进行一些计算，从而节省时间。可以通过如下的代码测试加速情况。

```cpp
	if (!overlap) {
		cpu_sum(h_x, h_y, h_z, N / ratio);
	}

	gpu_sum<<<grid_size, block_size>>>(d_x, d_y, d_z);

	if (overlap)
	{
		cpu_sum(h_x, h_y, h_z, N / ratio);
	}
```

### CUDA非默认加速流-重叠核函数执行

虽然在一个默认流中就可以实现主机计算和设备计算的并行，但是要**实现多个核函数之间的并行必须使用多个 CUDA 流**。这是因为，同一个CUDA 流中的 CUDA 操作在设备中是顺序执行的，故同一个 CUDA 流中的核函数也必须在设备中顺序执行。

我们仅讨论使用多个非默认流的情况。使用非默认流时，核函数的执行配置中必须包含一个流对象。一个名为 `my_kernel `的核函数只能用如下 3 种调用方式之一：

```cpp
my_kernel<<<N_grid, N_block>>>(函数参数); 
my_kernel<<<N_grid, N_block, N_shared>>>(函数参数); my_kernel<<<N_grid, N_block, N_shared, stream_id>>>(函数参数);
```

如果用第三种调用方式，则说明核函数在编号为stream_id 的 CUDA 流中执行，而且使用了 N_shared 字节的动态共享内存。

如下展示了如何使用非默认流重叠多个核函数执行[^2]。该程序使用了若干CUDA流，存放在一个数组 streams[] 中，在程序的开头定义。这些 CUDA 流的产生与销毁都在主函数中执行。我们这里仅关注与核函数并发执行有关的代码。

```cpp
void __global__ add(const real *d_x, const real *d_y, real *d_z)
{
    const int n = blockDim.x * blockIdx.x + threadIdx.x;
    if (n < N1)
    {
        for (int i = 0; i < 100000; ++i)
        {
            d_z[n] = d_x[n] + d_y[n];
        }
    }
}

void timing(const real *d_x, const real *d_y, real *d_z, const int num){

	for (int n = 0; n < num; ++n)
	{
		int offset = n * N1;
		add<<<grid_size, block_size, 0, streams[n]>>>
		(d_x + offset, d_y + offset, d_z + offset);
	}
}
```

![](../../../../../files/images/MLsys/13-a/13-a-7-2.png)

这里，每个流启动同样的核函数。每个核函数使用 N1 个线程。图11.1a展示了当 N1 = 1024 时所有流中的核函数执行完毕需要的时间随 CUDA 流数量的变化关系。随着 CUDA 流数量的增多，总的计算任务量（核函数的个数）也成比例地增多，但总的时间一开始并没有成比例地增多。这就说明，使用多个流相对于使用一个流有了加速。

这个加速比可以定义为在同样的任务量下使 用单个流所用时间与使用多个流所用时间之比，见图 11.1b。由图b可知，当流的数目超过 15 时，加速比就接近饱和了。

Tesla K40 有 15 个 SM，而每个 SM 理论上可常驻 2048 个线程，那么理论上可以支持 30 个核函数的并发。但从测试结果来看，似乎一个核函数就占用了一个 SM。

无论如何，这里的测试说明，利用 CUDA 流并发多个核函数可以提升 GPU 硬件的利用率，减少闲置的 SM，从而从整体上获得性能提升。

![](../../../../../files/images/MLsys/13-a/13-a-7-1.png)

在上述测试中，制约加速比的因素是 **GPU 的计算资源**，当所有 CUDA 流中对应核函数的线程数的总和超过某一个值时，再增加流的数目就不会带来更高的加速比了。

在使用 CUDA 流的程序中，还有另外一个制约加速比的因素，即**单个 GPU 中能够并发执行的核函数个数的上限**。该上限在不同的 GPU 架构中有不同的值。Tesla K40 所能支持的最大核函数并发数目为32。该图说明，在使用 32 个 CUDA 流时，程序的性能达到最高，继续增加 CUDA 流的个数，反而可能降低程序性能。

### CUDA非默认流加速-重叠核函数的执行与数据传递

![](../../../../../files/images/MLsys/13-a/13-a-7-6.png)

要实现核函数执行与数据传输的并发（重叠），必须让这两个操作处于不同的非默认流，而且数据传输必须使用 `cudaMemcpy`函数的异步版本，即` cudaMemcpyAsync` 函数。异步传输由 GPU 中的DMA直接实现，不需要主机参与。

如果用同步的数据传输函数，主机在向一个流发出数据传输的命令后，将无法立刻获得控制权，必须等待数据传输完毕，无法去调用核函数。

```cpp
cudaError_t cudaMemcpyAsync ( 
	void *dst, 
	const void *src, 
	size_t count, 
	enum cudaMemcpyKind kind, 
	cudaStream_t stream );
// cudaMemcpyAsync 只比 cudaMemcpy 多一个参数。该函数的最后一个参数就是 所在流的变量。
```

> [!question] 不可分页内存
> 在使用异步的数据传输函数时，需要将主机内存定义为不可分页内存（non-pageable memory）或者固定内存（pinned memory）。不可分页内存是相对于可分页内存（pageable memory）的。操作系统有权在一个程序运行期间改变程序中使用的可分页主机内存的物理地址。相反，若主机中的内存声明为不可分页内存，则在程序运行期间，其物理地址将保持不变。
> 
> 如果将可分页内存传给 `cudaMemcpyAsync` 函数，**则会导致同步传输，达不到重叠核函数执行与数据传输的效果。** 主机内存为可分页内存时，数据传输过程在使用GPU中的 DMA 之前必须先将数据从可分页内存移动到不可分页内存，从而必须与主机同步。主机无法在发出数据传输的命令后立刻获得程序的控制权，从而无法实现不同 CUDA 流之间的并发。
> 
> 不可分页主机内存的分配可以由以下两个 CUDA 运行时 API 函数中的任何一个实现：
> ```cpp
> cudaError_t cudaMallocHost(void** ptr, size_t size); cudaError_t cudaHostAlloc(void** ptr, size_t size, size_t flags);
> 
> //由以上函数分配的主机内存必须由如下函数释放：
> 
> cudaError_t cudaFreeHost(void* ptr);
> ```

假如在一段 CUDA 程序中，我们需要先从主机向设备传输一定数量的数据（我们将此 CUDA 操作简称为 H2D），然后在 GPU 中使用所传输的数据做一些计算（我们将此 CUDA 操作简称为 KER，意为核函数执行），最后将一些数据从设备传输至主机（我们将此 CUDA 操作简称为 D2H）。

两个流中相同的操作不能并发地执行（受硬件资源的限制），但第二个流的操作可以和第一个流中不同的操作并发地执行。

下面，我们从理论上分析使用 CUDA 流可能带来的性能提升。我们可以引入流水线的思想，如果 H2D、KER、和D2H 这 3 个 CUDA 操作的执行时间都相同，那么就能有效地隐藏一个 CUDA 流中两个 CUDA 操作的执行时间：

![](../../../../../files/images/MLsys/13-a/13-a-7-3.png)

**GPU硬件调度器会自动地、尽可能地将你提交的这些来自不同流的独立命令以流水线的方式重叠执行**
不难理解，随着流的数目的增加，在理想情况下的加速比将趋近于 3。

接下来给出了一个使用 CUDA 流重叠核函数执行和数据传输的例子。
当使用 num 个 CUDA 流时，每个 CUDA 流处理 N1 = N / num 对数据。主机向每一个流发布任务，包括数据传输和核函数执行。

数据传输的带宽大概是 GPU 显存带宽的几十分之一,为了让核函数所用时间与数据传输时间相当，程序故意让核函数中的求和操作重复 40 次。由 Tesla K40 得到的结果如图 11.3 所示:

```cpp
void __global__ add(const real *x, const real *y, real *z, int N)
{
    const int n = blockDim.x * blockIdx.x + threadIdx.x;
    if (n < N)
    {
        for (int i = 0; i < 40; ++i)//重复40次
        {
            z[n] = x[n] + y[n];
        }
    }
}

void timing
(
    const real *h_x, const real *h_y, real *h_z,
    real *d_x, real *d_y, real *d_z,
    const int num
){
for (int i = 0; i < num; i++)
{
	int offset = i * N1;
	CHECK(cudaMemcpyAsync(d_x + offset, h_x + offset, M1, cudaMemcpyHostToDevice, streams[i]));
	CHECK(cudaMemcpyAsync(d_y + offset, h_y + offset, M1, cudaMemcpyHostToDevice, streams[i]));

	int block_size = 128;
	int grid_size = (N1 - 1) / block_size + 1;
	add<<<grid_size, block_size, 0, streams[i]>>>
	(d_x + offset, d_y + offset, d_z + offset, N1);

	CHECK(cudaMemcpyAsync(h_z + offset, d_z + offset, M1, 
cudaMemcpyDeviceToHost, streams[i]));
	}
}
```

![](../../../../../files/images/MLsys/13-a/13-a-7-4.png)

没有得到最高的加速比的原因主要有两个：第一，在我们的例子中以上 3 种 CUDA 操作的执行时间并不完全一样。例如，从主机到设备传输的数据量是从设备到主机传输的数据量的 2 倍。第二，每个流中的第一个 CUDA 操作都是从主机向设备传输数据，它们无法并发地执行。



[^1]: https://github.com/brucefan1983/CUDA-Programming/blob/master/src/11-stream/host-kernel.cu

[^2]: https://github.com/brucefan1983/CUDA-Programming/blob/master/src/11-stream/kernel-kernel.cu
