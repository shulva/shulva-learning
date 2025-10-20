# swish

Swish(x) = x * σ(x)  
其中 σ(x) = 1 / (1 + e⁻ˣ) 是标准的 **Sigmoid** 函数。

- 性能通常优于ReLU，因为它解决了神经元死亡问题，并且更平滑。
- 非单调性被认为能增强模型的表达能力。
- 计算成本高，包含一个**Sigmoid**函数，而Sigmoid内部有一个昂贵的**指数运算 (e⁻ˣ)**。

```cpp
__device__ __forceinline__ float swish(float x) {
  return x / (1.0f + expf(-x));
}

__global__ void swish_f32x4_kernel(float *x, float *y, int N) {
  int idx = (blockIdx.x * blockDim.x + threadIdx.x) * 4;
  if (idx < N) {
    float4 reg_x = FLOAT4(x[idx]);
    float4 reg_y;
    reg_y.x = swish(reg_x.x);
    reg_y.y = swish(reg_x.y);
    reg_y.z = swish(reg_x.z);
    reg_y.w = swish(reg_x.w);
    FLOAT4(y[idx]) = reg_y;
  }
}

//  FP16
__device__ __forceinline__ half swish_half(half x) {
  return __hmul(x, __hdiv(__float2half(1.0f),
                          __hadd(__float2half(1.0f), hexp(__hneg(x)))));
}


__global__ void swish_f16x8_kernel(half *x, half *y, int N) {
  int idx = 8 * (blockIdx.x * blockDim.x + threadIdx.x);
  
  half2 reg_x_0 = HALF2(x[idx + 0]);
  half2 reg_x_1 = HALF2(x[idx + 2]);
  half2 reg_x_2 = HALF2(x[idx + 4]);
  half2 reg_x_3 = HALF2(x[idx + 6]);
  
  half2 reg_y_0, reg_y_1, reg_y_2, reg_y_3;
  
  reg_y_0.x = swish_half(reg_x_0.x);
  reg_y_0.y = swish_half(reg_x_0.y);
  reg_y_1.x = swish_half(reg_x_1.x);
  reg_y_1.y = swish_half(reg_x_1.y);
  reg_y_2.x = swish_half(reg_x_2.x);
  reg_y_2.y = swish_half(reg_x_2.y);
  reg_y_3.x = swish_half(reg_x_3.x);
  reg_y_3.y = swish_half(reg_x_3.y);
  
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


# hardswish

- **定义**:  
    HardSwish(x) = x * HardSigmoid(x) ,其中 HardSigmoid(x) = ReLU6(x + 3) / 6。

其在形状上与swish非常相似，完全避免了指数运算，只包含加法、乘法和比较操作。

形式上仍然是elementwise，只是计算不同。
```cpp

#define THRESHOLD_A 3.0
#define THRESHOLD_B -3.0

// FP32
__device__ __forceinline__ float hardswish(float x) {
  if (x >= THRESHOLD_A) {
    return x;
  } else if (x <= THRESHOLD_B) {
    return 0;
  } else {
    return x * (x + 3) / 6;
  }
}

// FP16
__device__ __forceinline__ half hardswish_half(half x) {
  if (x > __float2half(THRESHOLD_A)) {
    return x;
  } else if (x < __float2half(THRESHOLD_B)) {
    return __float2half(0.f);
  } else {
    return x * (x + __float2half(3.f)) / __float2half(6.f);
  }
}


__global__ void hardswish_f32x4_kernel(float *x, float *y, int N) {
  int idx = (blockIdx.x * blockDim.x + threadIdx.x) * 4;
  if (idx < N) {
    float4 reg_x = FLOAT4(x[idx]);
    float4 reg_y;
    reg_y.x = hardswish(reg_x.x);
    reg_y.y = hardswish(reg_x.y);
    reg_y.z = hardswish(reg_x.z);
    reg_y.w = hardswish(reg_x.w);
    FLOAT4(y[idx]) = reg_y;
  }
}

__global__ void hardswish_f16x8_kernel(half *x, half *y, int N) {
  int idx = 8 * (blockIdx.x * blockDim.x + threadIdx.x);
  half2 reg_x_0 = HALF2(x[idx + 0]);
  half2 reg_x_1 = HALF2(x[idx + 2]);
  half2 reg_x_2 = HALF2(x[idx + 4]);
  half2 reg_x_3 = HALF2(x[idx + 6]);
  half2 reg_y_0, reg_y_1, reg_y_2, reg_y_3;
  reg_y_0.x = hardswish_half(reg_x_0.x);
  reg_y_0.y = hardswish_half(reg_x_0.y);
  reg_y_1.x = hardswish_half(reg_x_1.x);
  reg_y_1.y = hardswish_half(reg_x_1.y);
  reg_y_2.x = hardswish_half(reg_x_2.x);
  reg_y_2.y = hardswish_half(reg_x_2.y);
  reg_y_3.x = hardswish_half(reg_x_3.x);
  reg_y_3.y = hardswish_half(reg_x_3.y);
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