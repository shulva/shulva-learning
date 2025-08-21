# CUDA程序基本框架

###

一个典型的 CUDA 程序的基本框架如下：

```cpp
头文件包含  
常量定义（或者宏定义） 
C++ 自定义函数和 CUDA 核函数的声明（原型）

int main(void) { 
	分配主机与设备内存 
	初始化主机中的数据 
	将某些数据从主机复制到设备 
	调用核函数在设备中进行计算 
	将某些数据从设备复制到主机 
	释放主机与设备内存 
} 
C++ 自定义函数和 CUDA 核函数的定义（实现）

```

> [!example] add1.cu
> https://github.com/brucefan1983/CUDA-Programming/blob/master/src/03-basic-framework/add1.cu


### cudaMalloc() [^1]

正如在 C++ 中可由 malloc() 函数动态分配内存，在 CUDA 中，设备内存的动态分配可由 cudaMalloc() 函数实现。

```cpp
  cudaError_t cudaMalloc(void **address, size_t size);
  第一个参数 address 是待分配设备内存的指针。
  第二个参数 size 是待分配内存的字节数。
  返回值是一个错误代号。如果调用成功，返回 cudaSuccess，否则返回一个    代表某种错误的代号
```

注意：因为内存（地址）本身就是一 个指针，所以待分配设备内存的指针就是指针的指针，即双重指针。

```cpp
    const int N = 100000000;
    const int M = sizeof(double) * N;
    
    double *d_x, *d_y, *d_z;
    cudaMalloc((void **)&d_x, M);
    cudaMalloc((void **)&d_y, M);
    cudaMalloc((void **)&d_z, M);
    cudaMemcpy(d_x, h_x, M, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, h_y, M, cudaMemcpyHostToDevice);

	.... // 核函数计算
	
	cudaMemcpy(h_z, d_z, M, cudaMemcpyDeviceToHost);
	
	free(h_x);
    free(h_y);
    free(h_z);
    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_z);
```

调用函数 cudaMalloc() 时传入的第一个参数 `(void **)&d_x` 稍难理解。首先，我们知道 d_x 是一个 double 类型的指针，那么它的地址 &d_x 就是 double 类型的双重指针。 而 `(void **)` 是一个强制类型转换操作，将一个某种类型的双重指针转换为一个 void 类型的双重指针。

这种类型转换可以不明确地写出来，即对函数 cudaMalloc() 的调用可以简写为`cudaMalloc(&d_x, M)`

> [!question] cudaMalloc() 函数为什么需要一个双重指针作为变量?
> 因为该函数的功能是改变指针 d_x 本身的值（将一个指针赋值给 d_x），而不是改变 d_x 所指内存缓冲区中的变量值。在这种情况下，必须将 d_x 的地址&d_x 传给函 数 cudaMalloc() 才能达到此效果。
> 
> 从另一个角度来说，函数 cudaMalloc() 要求用传双重指针的方式改变一个指针的值，而不是直接返回一个指针，是因为该函数已经将返回值用于返回错误代号，而 C++ 不支持多个返回值。

正如用 malloc() 函数分配的主机内存需要用 free() 函数释放一样，用 cudaMalloc() 函数分配的设备内存需要用 cudaFree() 函数释放。

```cpp
cudaError_t cudaFree(void* address);
参数 address 就是待释放的设备内存变量（不是双重指针）。
返回值是一个错误代号。如果调用成功，返回 cudaSuccess。
```

### cudaMemcpy()[^2]

cudaMemcpy()是一个CUDA 运行时 API 函数。

```cpp
cudaError_t cudaMemcpy 
( 
	void *dst, 
	const void *src, 
	size_t count, 
	enum cudaMemcpyKind kind 
);
```

- 第一个参数 dst 是目标地址。 
- 第二个参数 src 是源地址。 
- 第三个参数 count 是复制数据的字节数。 
- 第四个参数 kind 一个枚举类型的变量，标志数据传递方向。

该函数的作用是将一定字节数的数据从源地址所指缓冲区复制到目标地址所指缓冲区。

![](../../../../../files/images/MLsys/13-a/13-a-1-2.png)
### 核函数中数据与线程的对应

将主机中的函数改为设备中的核函数是非常简单的,基本上就是去掉一层控制数据的循环。

在主机函数中，我们需要依次对数组的每一个元素进行操作，所以需要使用一个循环。在设备的核函数中，我们用**单指令-多线程 SIMT**的方式编写代码，故可去掉该循环，只需将数组元素指标与线程指标一一对应即可。

```cpp
const int n = blockDim.x * blockIdx.x + threadIdx.x;
// 线程块大小 * 线程块id + 线程id
```

### 核函数注意事项

- 核函数的返回类型必须是 void。所以，在核函数中可以用 return 关键字，但不可返回任何值。 
- 必须使用限定符 __global__。也可以加上一些其他 C++ 中的限定符，如 static。限定符的次序可任意。 
-  函数名无特殊要求，而且支持 C++ 中的重载（overload），即可以用同一个函数名表示具有不同参数列表的函数。 
- 不支持可变数量的参数列表，即参数的个数必须确定。 
- 可以向核函数传递非指针变量（如例子中的 int N），其内容对每个线程可见。 
- 除非使用统一内存编程机制，否则传给核函数的数组（指针）必须指向设备内存。 
- 核函数不可成为一个类的成员。通常的做法是用一个包装函数调用核函数，而将包装函数定义为类的成员。 
- 在计算能力 3.5 之前，核函数之间不能相互调用。从计算能力 3.5 开始，引入了动态并行（dynamic parallelism）机制，在核函数内部可以调用其他核函数，甚至可以递归。可参考《CUDA C++ Programming Guide》的附录 D。  
- 无论是从主机调用，还是从设备调用，核函数都是在设备中执行。调用核函数时必须指定执行配置，即三括号和它里面的参数。

> [!question] 定义的总线程数多于元素个数怎么办？
> ```cpp
> const int n = blockDim.x * blockIdx.x + threadIdx.x;
> if (n >= N) return; //跳过访问非法的内存地址
> z[n] = x[n] + y[n];
> ```
> 虽然核函数不允许有返回值，但还是可以使用 return 语句。没有这个if语句会出现数组越界问题。
>
> **启动的线程数（为了内存访问和执行效率，通常是block_size的整数倍）和实际需要处理的数据量（可以是任意数字）往往是不相等的。**
>
> 因此，在CUDA编程中，只要存在总线程数可能多于数据元素的情况，在Kernel内部添加边界检查是必须的。

### 自定义设备函数

核函数可以调用不带**执行配置**(即`<<<grid,block>>>`)的自定义函数，这样的自定义函数称为设备函数（device function）

**执行配置 (<<<...>>>)** 是从 **CPU 到 GPU** 的“发射指令”，用于启动一个**新**的、大规模的并行任务（Kernel）。

设备函数是 **GPU 内部** 的“工具函数”，被已经在运行的线程调用，用于代码复用和模块化，**不会**启动新的并行任务。

| 修饰符            | 执行位置         | 调用位置                                             | 调用方式                    |
| -------------- | ------------ | ------------------------------------------------ | ----------------------- |
| **__global__** | **设备 (GPU)** | **主机 (CPU)**                                     | **必须带执行配置 <<<...>>>**   |
| **__device__** | **设备 (GPU)** | **设备 (GPU)** (从 __global__ 或其他 __device__ 函数中调用) | **就像一个普通的C函数调用，不带执行配置** |
| **__host__**   | 主机 (CPU)     | 主机 (CPU)                                         | 普通C函数调用                 |


一个设备函数本质上是一个只能在GPU上运行的子程序或工具函数。它被设计出来的目的，就是为了让__global__内核函数能够重用代码、保持结构清晰。

用 \__device__ 修饰的函数叫称为设备函数，只能被核函数或其他设备函数调用，在设备中执行。

不能同时用 \__device\__ 和 \__global\__ 修饰一个函数，即不能将一个函数同时定义 为设备函数和核函数。\__host\__ 主机函数同理。


```cpp 
//带返回值
double __device__ add1_device(const double x, const double y)
{
    return (x + y);
}
//指针
void __device__ add2_device(const double x, const double y, double *z)
{
    *z = x + y;
}
//引用
void __device__ add3_device(const double x, const double y, double &z)
{
    z = x + y;
}
```

> [!example] add4device.cu
> https://github.com/brucefan1983/CUDA-Programming/blob/master/src/03-basic-framework/add4device.cu
> 

[^1]: [线程索引](../../../../../files/books/MLSys/CUDA%20编程：基础与实践_樊哲勇.pdf#page=42)

[^2]: [线程索引](../../../../../files/books/MLSys/CUDA%20编程：基础与实践_樊哲勇.pdf#page=44)
