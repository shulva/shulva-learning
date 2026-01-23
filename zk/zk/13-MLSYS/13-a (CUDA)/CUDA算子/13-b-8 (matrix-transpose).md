# matrix-transpose[^1][^2]

矩阵转置

#### 初始版本

```cpp
// M为行数，N为列数
__global__ void mat_transpose_kernel_v0(const float* idata, float* odata, int M, int N) {
    const int x = blockIdx.x * blockDim.x + threadIdx.x;
    const int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (y < M && x < N) {
        odata[x * M + y] = idata[y * N + x];
    }
}


void mat_transpose_v0(const float* idata, float* odata, int M, int N) {
    constexpr int BLOCK_SZ = 16;
    dim3 block(BLOCK_SZ, BLOCK_SZ);
    dim3 grid((N + BLOCK_SZ - 1) / BLOCK_SZ, (M + BLOCK_SZ - 1) / BLOCK_SZ);
    mat_transpose_kernel_v0<<<grid, block>>>(idata, odata, M, N);
}
```

grid.x 就是水平方向(N)需要的线程数，grid.y 就是垂直方向(M)需要的线程数。

在 Version 0 的 kernel 中, 容易看出读取时 `idata[y * N + x]` 是访存合并的, 因为连续线程对应的 `x` 是连续的, 即访问矩阵同一行连续的列; 但是**写入时 `odata[x * M + y]` 并不是访存合并的**, 因为转置后连续线程写入的是同一列连续的行, 但由于内存布局是行主序的, 因此此时每个线程访问的地址实际上并不连续, 地址差 `N`, 因此对 GMEM 访存性能有很大影响.

### v1

V0的kernel 存在的问题是写入 GMEM 时访存不合并, 因此需要一种方式让写入 GMEM 时仍然保持线程的访存连续, 在 V1 中,便使用了SMEM用来中转来实现访存合并.

```cpp
#define Ceil(a, b) (((a) + (b) - 1) / (b))

-
template <int BLOCK_SZ>
__global__ void mat_transpose_kernel_v1(const float* idata, float* odata, int M, int N) {
    const int bx = blockIdx.x, by = blockIdx.y;
    const int tx = threadIdx.x, ty = threadIdx.y;

    __shared__ float sdata[BLOCK_SZ][BLOCK_SZ];

    int x = bx * BLOCK_SZ + tx;
    int y = by * BLOCK_SZ + ty;

    if (y < M && x < N) {
        sdata[ty][tx] = idata[y * N + x];
    }
    __syncthreads();

	// x与y在block层面上的偏移改变
    x = by * BLOCK_SZ + tx;
    y = bx * BLOCK_SZ + ty;
	
    if (y < N && x < M) {
        odata[y * M + x] = sdata[tx][ty];
    }
}

void mat_transpose_v1(const float* idata, float* odata, int M, int N) {
    constexpr int BLOCK_SZ = 16;
    dim3 block(BLOCK_SZ, BLOCK_SZ);
    dim3 grid(Ceil(N, BLOCK_SZ), Ceil(M, BLOCK_SZ));
    mat_transpose_kernel_v1<BLOCK_SZ><<<grid, block>>>(idata, odata, M, N);
}
```

![v1](https://developer.nvidia.com/blog/wp-content/uploads/2012/11/sharedTranspose-1024x409.jpg)


V1 的核心思想可以使用上图进行表示, 中间的"tile" 即可理解为 SMEM 的数据分片。  

在读取矩阵阶段, 操作与 V0 一致, 区别在于将数据直接写入 SMEM 中, 对应上图橙色部分。一个线程写入smem和读出smem的数据不是同一块。

接着通过设置 `x = by * BLOCK_SZ + tx; y = bx * BLOCK_SZ + ty;` 两条语句进行了索引的重计算, **进行了线程块索引 `bx` 和 `by` 交换**, 对应上图右上角的数据分片转置后成为了左下角的数据分片。 
由于此时 `tx` 和 `ty` 并没有交换, 因此按照 `odata[y * M + x]` 写入 GMEM 时, 访存是合并的, 但需要读取 SMEM 时 `tx` 与 `ty` 进行交换(`sdata[tx][ty]`按列读取，`odata[y * M + x]`按行写入), 实现数据分片内的转置, 对应上图绿色部分.

### v2

在 V1 中, 引入了对 SMEM 的访存, 所以需要特别关注 bank conflict 的问题. 

`const int tx = threadIdx.x`
`const int ty = threadIdx.y`

对于 SMEM 的写入, `sdata[ty][tx]`, 由于 `BLOCK_SZ` 为 16, 32 个线程负责 SMEM 矩阵分片的两行 32 个元素, 对应 32 个 bank, 因此没有 bank conflict. 

而对于 SMEM 的读取, `sdata[tx][ty]`, 由于是按列读取 SMEM 的, `threadIdx` 差 1 的线程访问的数据差一个 `BLOCK_SZ=16`, 即导致`threadIdx` 相差2的线程访问的数据会落到同一bank 的不同地址, 从而**造成 16 路的 bank conflict**.

```cpp
template <int BLOCK_SZ>
__global__ void mat_transpose_kernel_v2(const float* idata, float* odata, int M, int N) {
    const int bx = blockIdx.x, by = blockIdx.y;
    const int tx = threadIdx.x, ty = threadIdx.y;

    __shared__ float sdata[BLOCK_SZ][BLOCK_SZ+1];    // padding

    int x = bx * BLOCK_SZ + tx;
    int y = by * BLOCK_SZ + ty;

    if (y < M && x < N) {
        sdata[ty][tx] = idata[y * N + x];
    }
    __syncthreads();

    x = by * BLOCK_SZ + tx;
    y = bx * BLOCK_SZ + ty;
    if (y < N && x < M) {
        odata[y * M + x] = sdata[tx][ty];
    }
}

void mat_transpose_v2(const float* idata, float* odata, int M, int N) {
    constexpr int BLOCK_SZ = 16;
    dim3 block(BLOCK_SZ, BLOCK_SZ);
    dim3 grid(Ceil(N, BLOCK_SZ), Ceil(M, BLOCK_SZ));
    mat_transpose_kernel_v2<BLOCK_SZ><<<grid, block>>>(idata, odata, M, N);
}
```

V2 的代码相比于 V1 仅在 SMEM 内存分配时进行了变动, 将大小改为了 `sdata[BLOCK_SZ][BLOCK_SZ+1]`, 即**列维度上加入了 1 元素大小的 padding**  
此时, 对于读取 SMEM 的 `sdata[tx][ty]`, `threadIdx` 相差1的线程访问的数据差 `BLOCK_SZ+1`, 即 17, 由于 17 与 32 互质, 因此不会有 bank conflict

对于写入MEM `sdata[ty][tx]`, 由于有 1 个 padding, warp 中 lane 31和lane 0 访问的元素恰好差 31+1=32 个元素, 会有 1 个 bank conflict 
以上会有一个轻微的bank conflict的原因是内存地址是这样跳变的(0,1......,15(0\*1+15)->17(1\*17+1)...32)，0%32=32%32，故而有一个bank conflict

整体上, V2 通过 padding 的方法有效避免了读取 SMEM 时的 bank conflict

### V3

```cpp
template <int BLOCK_SZ, int NUM_PER_THREAD>
__global__ void mat_transpose_kernel_v3(const float* idata, float* odata, int M, int N) {
    const int bx = blockIdx.x, by = blockIdx.y;
    const int tx = threadIdx.x, ty = threadIdx.y;

    __shared__ float sdata[BLOCK_SZ][BLOCK_SZ+1];

    int x = bx * BLOCK_SZ + tx;
    int y = by * BLOCK_SZ + ty;

    constexpr int ROW_STRIDE = BLOCK_SZ / NUM_PER_THREAD;

    if (x < N) {
        #pragma unroll
        for (int y_off = 0; y_off < BLOCK_SZ; y_off += ROW_STRIDE) {
            if (y + y_off < M) {
                sdata[ty + y_off][tx] = idata[(y + y_off) * N + x]; 
            }
        }
    }
    __syncthreads();

    x = by * BLOCK_SZ + tx;
    y = bx * BLOCK_SZ + ty;
    if (x < M) {
        for (int y_off = 0; y_off < BLOCK_SZ; y_off += ROW_STRIDE) {
            if (y + y_off < N) {
                odata[(y + y_off) * M + x] = sdata[tx][ty + y_off];
            }
        }
    }
}

void mat_transpose_v3(const float* idata, float* odata, int M, int N) {
    constexpr int BLOCK_SZ = 32;
    constexpr int NUM_PER_THREAD = 4;
    dim3 block(BLOCK_SZ, BLOCK_SZ/NUM_PER_THREAD);
    dim3 grid(Ceil(N, BLOCK_SZ), Ceil(M, BLOCK_SZ));
    mat_transpose_kernel_v3<BLOCK_SZ, NUM_PER_THREAD><<<grid, block>>>(idata, odata, M, N);
}
```

V3 相比于 V2, **增加了每个线程处理的元素个数**, 即由先前的每个线程处理 1 个元素的转置, 变为处理 `NUM_PER_THREAD` 个元素的转置

在实现上, 同样保持原本 256 线程的线程块大小, 设置每个线程处理 4 个元素, 则每个线程块数据分片的大小调整为 32×32, 而线程块的线程采取 8×32 的二维排布, 因此需要在行维度上需要迭代 4 次完成转置.

考虑 V3 相比于 V2 的优势, 主要是在保持线程块中线程数量不变的情况下, 处理的线程块数据分片大小变大, 这样会减少线程网格中启动的线程块数量, 而增大了每个线程的计算强度; 此外, 由于 `BLOCK_SZ` 变为 32, V2中写入 SMEM 的1个bank conflict也可以被避免.  
[笔者](https://zhuanlan.zhihu.com/p/692010210)主观的感觉是对于这种计算强度比较低的 kernel, 增加线程处理的元素个数即计算强度, 一定程度上能增大 GPU 中计算与访存的掩盖, 并配合循环展开提高指令级并行; 此外, 由于线程块数量的减少, 能在相对少的warp中完成计算, 减少 GPU 的线程块调度上可能也会带来性能的收益.

[^1]: https://developer.nvidia.com/blog/efficient-matrix-transpose-cuda-cc/
[^2]: https://zhuanlan.zhihu.com/p/692010210
