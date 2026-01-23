# embedding[^1]

embedding执行的是一个查表（Table Lookup）的功能：根据输入的索引，从一个巨大的权重矩阵中，并行地、高效地抽取出对应的向量。

idx是索引数组，weight是嵌入权重矩阵，output为查询结果。
```cpp

#define LDST128BITS(value) (reinterpret_cast<float4 *>(&(value))[0])

// 默认blocksize = emb_size
__global__ void embedding_f32x4_kernel(const int *idx, float *weight,
                                       float *output, int n, int emb_size) {
  int tx = threadIdx.x * 4;
  int bx = blockIdx.x;
  
  int offset = idx[bx] * emb_size;// 每个Block负责一个索引的查询 第bx个线程块，负责处理输入中的第bx个索引。
  
  output[bx * emb_size + tx] = weight[offset + tx];
  output[bx * emb_size + tx + 1] = weight[offset + tx + 1];
  output[bx * emb_size + tx + 2] = weight[offset + tx + 2];
  output[bx * emb_size + tx + 3] = weight[offset + tx + 3];
}

__global__ void embedding_f16x8_pack_kernel(const int *idx, half *weight,
                                            half *output, int n, int emb_size) {
  int tx = threadIdx.x;
  int bx = blockIdx.x;
  int tid = bx * blockDim.x + tx;
  int offset = idx[bx] * emb_size;
  LDST128BITS(output[bx * emb_size + 8 * tx]) = LDST128BITS(weight[offset + 8 * tx]);
}
```


[^1]: https://github.com/xlite-dev/LeetCUDA/blob/main/kernels/embedding/embedding.cu
