# relu elu gelu

#### relu[^3]

ReLU是深度学习时代最基础、最常用的激活函数。它的出现是解决深层网络训练困难（梯度消失）的关键突破。
- **定义**:  f(x) = max(0, x)
- **图像**: 一条在负半轴为0，在正半轴为 y=x 的折线。

以下代码其实形式与elementwise无异，只是计算的公式变了。

```cpp

#define HALF2(value) (reinterpret_cast<half2 *>(&(value))[0]) // 32位，两个half

__global__ void relu_f32_kernel(float *x, float *y, int N) {
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < N)
    y[idx] = fmaxf(0.0f, x[idx]);
}

__global__ void relu_f16x8_kernel(half *x, half *y, int N) {
  int idx = 8 * (blockIdx.x * blockDim.x + threadIdx.x);
  half2 reg_x_0 = HALF2(x[idx + 0]);
  half2 reg_x_1 = HALF2(x[idx + 2]);
  half2 reg_x_2 = HALF2(x[idx + 4]);
  half2 reg_x_3 = HALF2(x[idx + 6]);
  
  half2 reg_y_0, reg_y_1, reg_y_2, reg_y_3;
  reg_y_0.x = __hmax(__float2half(0.0f), reg_x_0.x);
  reg_y_0.y = __hmax(__float2half(0.0f), reg_x_0.y);
  reg_y_1.x = __hmax(__float2half(0.0f), reg_x_1.x);
  reg_y_1.y = __hmax(__float2half(0.0f), reg_x_1.y);
  reg_y_2.x = __hmax(__float2half(0.0f), reg_x_2.x);
  reg_y_2.y = __hmax(__float2half(0.0f), reg_x_2.y);
  reg_y_3.x = __hmax(__float2half(0.0f), reg_x_3.x);
  reg_y_3.y = __hmax(__float2half(0.0f), reg_x_3.y);
  
  if ((idx + 0) < N) {
    HALF2(y[idx + 0]) = reg_y_0;
  }
  if ((idx + 2) < N) {
    HALF2(y[idx + 2]) = reg_y_1;
  }
  if ((idx + 4) < N) {
    HALF2(y[idx + 4]) = reg_y_2;
  }
  if ((idx + 6) < N) {
    HALF2(y[idx + 6]) = reg_y_3;
  }
}
```

#### elu[^2]

ELU是针对ReLU缺点的一次重要改进，旨在解决**神经元死亡问题**并加速收敛。

ReLU(x) = max(0, x)。当输入x为负数时，ReLU的输出是0。在反向传播计算梯度时，ReLU'(x) 在x < 0时等于0。

如果一个神经元由于某些原因，其对于所有训练样本的输入都变成了负数，那么它的输出将永远是0。在反向传播时，流经这个神经元计算出的梯度由于relu'(x<0) = 0 ,计算出的梯度也将永远是0 。这个神经元的权重和偏置将**永远无法得到更新**，它对整个网络不再有任何贡献。

而且，ReLU的输出值要么是0，要么是正数。这意味着任何一个使用ReLU的隐藏层，其输出的**平均值（均值）必然是正数**。这被称为非零中心 (Non-zero-centered)的激活。

-  下一层的某个神经元，它的输入是z = w₁a₁ + w₂a₂ + ... + b，其中aᵢ都是上一层的ReLU输出（都是非负的）。
- 在反向传播计算权重梯度时，∂Loss/∂wᵢ = (∂Loss/∂z) * aᵢ。
- **关键问题**: 因为所有的aᵢ都是**非负**的，所以这一层所有权重wᵢ的梯度∂Loss/∂wᵢ的正负，将完全由值∂Loss/∂z的符号正负。

- 这意味着，在一次梯度更新中，这一层的所有权重w₁, w₂, ...要么一起增加，要么一起减小。
- 优化器（如梯度下降）无法做出更精细的、某些权重增加而另一些权重减少的更新。
- 这会导致权重更新的路径在参数空间中呈现出低效的Z型，从而减慢了收敛到最优解的速度。

---

- **elu定义**:
    - f(x) = x (如果 x > 0)
    - f(x) = α * (e^x - 1) (如果 x ≤ 0) (通常 α=1)

elu缓解了神经元死亡,输入为负时也有非零的输出和梯度，神经元可以继续学习。
输出更接近零中心,因为有负值输出，使得输出的均值更接近0，有助于加速网络收敛。

下面代码对于half的计算需要用内置的计算函数。形式依旧与elementwise相似，只是换了计算方式。
```cpp
// ELU 计算函数
// FP32
__device__ __forceinline__ float elu(float x) {
  return x > 0.f ? x : ALPHA * (expf(x) - 1.f);
}

// FP16
__device__ __forceinline__ half elu_half(half x) {
  return __hgt(x, __float2half(0.f))
             ? x
             : __hmul(__float2half(ALPHA), __hsub(hexp(x), __float2half(1.f)));
}

__global__ void elu_f32x4_kernel(float *x, float *y, int N) {
  int idx = (blockIdx.x * blockDim.x + threadIdx.x) * 4;
  if (idx < N) {
    float4 reg_x = FLOAT4(x[idx]);
    float4 reg_y;
    reg_y.x = elu(reg_x.x);
    reg_y.y = elu(reg_x.y);
    reg_y.z = elu(reg_x.z);
    reg_y.w = elu(reg_x.w);
    FLOAT4(y[idx]) = reg_y;
  }
}

__global__ void elu_f16x8_kernel(half *x, half *y, int N) {

  int idx = 8 * (blockIdx.x * blockDim.x + threadIdx.x);
  
  half2 reg_x_0 = HALF2(x[idx + 0]);
  half2 reg_x_1 = HALF2(x[idx + 2]);
  half2 reg_x_2 = HALF2(x[idx + 4]);
  half2 reg_x_3 = HALF2(x[idx + 6]);
  
  half2 reg_y_0, reg_y_1, reg_y_2, reg_y_3;
  reg_y_0.x = elu_half(reg_x_0.x);
  reg_y_0.y = elu_half(reg_x_0.y);
  reg_y_1.x = elu_half(reg_x_1.x);
  reg_y_1.y = elu_half(reg_x_1.y);
  reg_y_2.x = elu_half(reg_x_2.x);
  reg_y_2.y = elu_half(reg_x_2.y);
  reg_y_3.x = elu_half(reg_x_3.x);
  reg_y_3.y = elu_half(reg_x_3.y);
  if ((idx + 0) < N) {
    HALF2(y[idx + 0]) = reg_y_0;
  }
  if ((idx + 2) < N) {
    HALF2(y[idx + 2]) = reg_y_1;
  }
  if ((idx + 4) < N) {
    HALF2(y[idx + 4]) = reg_y_2;
  }
  if ((idx + 6) < N) {
    HALF2(y[idx + 6]) = reg_y_3;
  }
}
```
#### gelu[^1]

GELU是一种更现代、性能更强的激活函数，其设计思想更深刻，是顶尖Transformer模型（如BERT, GPT系列）的标配。

- **定义**:  
    GELU(x) = x * Φ(x)  其中 Φ(x) 是标准正态分布的累积分布函数 (CDF)(实践中通常使用tanh或sigmoid进行近似计算)。

但也可以使用近似计算`GELU(x) ≈ 0.5 * x * (1 + tanh[√(2/π) * (x + 0.044715 * x³)])`
非近似计算有`Φ(x) = 0.5 * (1 + erf(x / √2)) `，Φ(x)与erf函数有精确的数学关系。

代码需要先对gelu的计算写函数，输入的参数也要做上溢下溢处理。
```cpp

#define WARP_SIZE 32
#define INT4(value) (reinterpret_cast<int4 *>(&(value))[0])
#define FLOAT4(value) (reinterpret_cast<float4 *>(&(value))[0])
#define HALF2(value) (reinterpret_cast<half2 *>(&(value))[0])
#define BFLOAT2(value) (reinterpret_cast<__nv_bfloat162 *>(&(value))[0])
#define LDST128BITS(value) (reinterpret_cast<float4 *>(&(value))[0])
#define MAX_EXP_F32 88.3762626647949f
#define MIN_EXP_F32 -88.3762626647949f
#define MAX_EXP_F16 __float2half(11.089866488461016f)
#define MIN_EXP_F16 __float2half(-9.704060527839234f)
#define SQRT_2_PI M_SQRT2 *M_2_SQRTPI * 0.5f
#define HALF_1 __float2half(1.0f)
#define HALF_2 __float2half(2.0f)
#define HALF_DIV2 __float2half(0.5f)
// to clear the error among self defined gelu and pytorch gelu. Calculate
// $\sqrt{\frac{\pi}{2}}$ by $\sqrt{2 * \pi} / 2$
#define HALF_SQRT_2_PI                                                         \
  __float2half(M_SQRT2) * __float2half(M_2_SQRTPI) * HALF_DIV2
#define HALF_V_APP __float2half(0.044715f)

#define HALF_GELU_OPS gelu_tanh_approximate
#define GELU_OPS gelu_tanh_approximate

__inline__ __device__ half gelu_tanh_approximate(half x) {
  half x_cube = x * x * x;
  // compute mid value : inner = 0.7978845608 * (x + 0.044715 * x * x * x)
  half inner = HALF_SQRT_2_PI * (x + HALF_V_APP * x_cube);
  // compute tanh 
  //tanh(z) = (e^(2z) - 1) / (e^(2z) + 1)
  return HALF_DIV2 * x *(HALF_1 +((hexp(inner * HALF_2) - HALF_1) / (hexp(inner * HALF_2) + HALF_1)));
}

__inline__ __device__ float gelu_tanh_approximate(float x) {//使用tan做近似拟合
  return 0.5f * x * (1.0f + tanhf(SQRT_2_PI * (x + 0.044715f * x * x * x)));
}

__inline__ __device__ float gelu_none_approximate(float x) {//erff 精确，速度慢
  return x * 0.5 * (1 + erff(x * M_SQRT1_2));
}

__global__ void gelu_f32x4_kernel(float *x, float *y, int N) {
  int idx = (blockIdx.x * blockDim.x + threadIdx.x) * 4;
  float4 reg_x = FLOAT4(x[idx]);
  float4 reg_y;

  reg_x.x = fminf(fmaxf(reg_x.x, MIN_EXP_F32), MAX_EXP_F32);
  reg_x.y = fminf(fmaxf(reg_x.y, MIN_EXP_F32), MAX_EXP_F32);
  reg_x.z = fminf(fmaxf(reg_x.z, MIN_EXP_F32), MAX_EXP_F32);
  reg_x.w = fminf(fmaxf(reg_x.w, MIN_EXP_F32), MAX_EXP_F32);

  reg_y.x = GELU_OPS(reg_x.x);
  reg_y.y = GELU_OPS(reg_x.y);
  reg_y.z = GELU_OPS(reg_x.z);
  reg_y.w = GELU_OPS(reg_x.w);

  if ((idx + 0) < N) {
    FLOAT4(y[idx]) = reg_y;
  }
}

// pack f16x8
__global__ void gelu_f16x8_pack_kernel(half *x, half *y, int N) {
  int idx = (blockIdx.x * blockDim.x + threadIdx.x) * 8;

  // temporary register(memory), .local space in ptx, addressable
  half pack_x[8], pack_y[8]; // 8x16 bits=128 bits.
  // reinterpret as float4 and load 128 bits in 1 memory issue.
  LDST128BITS(pack_x[0]) = LDST128BITS(x[idx]); // load 128 bits

#pragma unroll
  for (int i = 0; i < 8; ++i) {
    half v = __hmin(__hmax(pack_x[i], MIN_EXP_F16), MAX_EXP_F16);
    pack_y[i] = HALF_GELU_OPS(v);
  }
  // reinterpret as float4 and store 128 bits in 1 memory issue.
  if ((idx + 7) < N) {
    LDST128BITS(y[idx]) = LDST128BITS(pack_y[0]);
  }
}
```

[^1]: https://github.com/xlite-dev/LeetCUDA/blob/main/kernels/gelu/gelu.cu

[^2]: https://github.com/xlite-dev/LeetCUDA/blob/main/kernels/elu/elu.cu

[^3]: https://github.com/xlite-dev/LeetCUDA/blob/main/kernels/relu/relu.cu
