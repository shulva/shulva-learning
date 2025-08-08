# thrust

Thrust 是一个实现了众多基本并行算法的 C++ 模板库，类似于 C++ 的标准模板库STL。该库自动包含在 CUDA 工具箱中。这是一个模板库，仅仅由 一些头文件组成。

Thrust 中的数据结构主要是矢量容器（vector container），类似于 STL 中的 std::vector。 在 Thrust 中，有两种矢量：一种是存储于主机的矢量 `thrust::host_vector<typename>` , 一种是存储于设备的矢量 `thrust::device_vector<typename>`

```cpp
//要使用这两种矢量，需要分别包含如下头文件
#incldue <thrust/host_vector.h> 
#incldue <thrust/device_vector.h>

thrust::device_vector<double> x(10, 0);//长度为10
```

Thrust 提供了 5 类常用算法，包括：

1. 变换（transformation）。讨论过的数组求和就是一种变换操作。 
2. 规约（reduction）。这是前面重点讨论过的算法。 
3. 前缀和（prefix sum）。
4. 排序（sorting）与搜索（searching）。 
5. 选择性复制、替换、移除、分区等重排（reordering）操作。


除了 thrust::copy，Thrust 算法的参数必须都来自于主机矢量或设备矢量。否则， 编译器会报错。

### thrust-前缀和示例

前缀和（prefix sum）也常称为扫描（scan）。

包含扫描（inclusive scan）操作将一个序列`x0,x1...`变为另一个序列`y0 = x0 y1 = x0+x1`

相比之下，非包含扫描（exclusive scan）的结果是`y0 = 0,y1 = x0,y2 = x0+x1`

示例如下:[^1]
```cpp
#include <thrust/device_vector.h>
#include <thrust/scan.h> //扫描算法库
#include <stdio.h>

int main(void)
{
    int N = 10;
    thrust::device_vector<int> x(N, 0);
    thrust::device_vector<int> y(N, 0);
    for (int i = 0; i < x.size(); ++i)
    {
        x[i] = i + 1;
    }
    thrust::inclusive_scan(x.begin(), x.end(), y.begin());
    for (int i = 0; i < y.size(); ++i)
    {
		//注意，y[i] 并不是普通整型的变量，需要强制转换为整型后才能          //用printf函数输出。
        printf("%d ", (int) y[i]);
    }
    printf("\n");
    return 0;
}
```

> [!question] 为什么需要强制转换？
> 因为 `y[i]` 返回的并不是一个标准的 `int`，而是一个名为 `thrust::device_reference<int>` 的“代理对象”（Proxy Object）。
> 
> `y` 是一个 `device_vector`，意味着它的数据（那一长串整数）存储在**GPU的物理显存**中。
> `main` 函数和 `printf` 是在**CPU**上运行的，它们在**主机的系统内存**中。    
> 
> CPU不能像访问普通RAM一样直接解引用一个指向GPU内存的指针。这两个是完全不同的物理地址空间。
> 
> 为了让用户能够像使用标准 `std::vector` 一样方便地写 `y[i]`，Thrust的设计者重载了中括号运算符 `operator[]`。但这个重载的运算符不能直接返回一个 `int` 或者一个 `int&`。
> 
> 如果返回 `int`，你就只能读，不能写。
> 如果返回 `int&`，这是不可能的，因为CPU无法创建一个指向GPU内存的本地引用。
> 
> `thrust::device_reference<int>` 到底是什么？你可以把它想象成一个**GPU内存元素的远程控制器**。这个对象本身存在于CPU上，但它内部知道自己代表的是GPU上哪个内存地址的那个int。
> 
> 这个**远程控制器**的关键在于它重载了两个关键的操作符：
> 
> **赋值操作符 (operator=)**:
> 当你写 `y[i] = 5;` 时，实际上是调用了 `thrust::device_freference` 的赋值操作符。
> 这个操作符的内部实现是：**发起一次 cudaMemcpy (Host-to-Device)，把值5从CPU拷贝到GPU上对应的内存地址**。
> 
> **类型转换操作符 (operator T())**:
> 当你试图读取`y[i]`的值时，比如 `int a = y[i];` 或者类似代码中的 `(int)y[i]`，实际上是调用了 `thrust::device_reference` 的类型转换操作符。
> 这个操作符的内部实现是：**发起一次 cudaMemcpy (Device-to-Host)，把GPU上那个地址的int值拷贝回CPU，并作为结果返回**。
> 
> 强制转换触发了我们上面所说的**类型转换操作符**，完成了一次从Device到Host的数据拷贝，得到了一个可以让 printf 理解和打印的 int 值。不强制转换会报错，因为编译器无法处理这个对象。

也可以直接用设备中的数组（指针）实现：[^2]
```cpp
#include <thrust/execution_policy.h>
#include <thrust/scan.h>
#include <stdio.h>

int main(void)
{
    int N = 10;
    int *x, *y;
    cudaMalloc((void **)&x, sizeof(int) * N);
    cudaMalloc((void **)&y, sizeof(int) * N);
    int *h_x = (int*) malloc(sizeof(int) * N);

    for (int i = 0; i < N; ++i)
    {
        h_x[i] = i + 1;
    }
    
    cudaMemcpy(x, h_x, sizeof(int) * N,        cudaMemcpyHostToDevice);

    thrust::inclusive_scan(thrust::device, x, x + N, y);

    int *h_y = (int*) malloc(sizeof(int) * N);
    cudaMemcpy(h_y, y, sizeof(int) * N, cudaMemcpyDeviceToHost);
    
    for (int i = 0; i < N; ++i)
    {
        printf("%d ", h_y[i]);
    }
    printf("\n");

    cudaFree(x);
    cudaFree(y);
    free(h_x);
    free(h_y);
    return 0;
}

```

相对于使用设备矢量的版本，函数`inclusive_scan`用了一个额外的表示执行策略（execution policy）的参数 `thrust::device`。要使用该参数，需要包含头文件` <thrust/execution_policy.h>`。

# cuBLAS

cuBLAS 是 BLAS 在 CUDA 运行时的实现。BLAS 的全称是 basic linear algebra subrou-tines，即基本线性代数子程序。

这一套子程序最早在 CPU 中通过 Fortran 语言实现。所以，后来的各种实现都带有 Fortran 的风格。最显著的风格是矩阵在内存中的存储是列主序（column-major order）的， 而不是像 C 语言中是行主序（row-major order）的。**行主序要求矩阵的每一行元素在内存中是连续的,而列主序要求矩阵的每一列元素在内存中是连续的。**考虑矩阵:
$$
\left( \begin{array}{cc} a & b \\ c & d \end{array} \right)
$$

在行主序的约定下，其元素在内存中的顺序为a b c d
在列主序的约定下，其元素在内存中的顺序为a c b d。cublas正是如此。

cuBLAS 库包含 3 个 API： 
- cuBLAS API：相关数据必须在设备。 
- cuBLASXT API：相关数据必须在主机。 
- cuBLASLt API：一个专门处理矩阵乘法的 API，在 CUDA 10.1 中才引入。

这里只对 cuBLAS API 进行介绍。该 API 实现了 BLAS 的 3 个层级的函数，第一层级的函数处理矢量之间的运算，如矢量之间的内积。第二层级的函数处理矩阵和矢量之间的运算，如矩阵与矢量相乘。第三层级的函数处理矩阵之间的运算，如矩阵与矩阵相乘。

### cuBLAS矩阵乘示例

考虑如下的矩阵乘：
$$

  \left(
    \begin{array}{ccc}
      0 & 2 & 4 \\
      1 & 3 & 5
    \end{array}
  \right)
  \left(
    \begin{array}{cc}
      0 & 3 \\
      1 & 4 \\
      2 & 5
    \end{array}
  \right)
  =
  \left(
    \begin{array}{cc}
      10 & 28 \\
      13 & 40
    \end{array}
  \right)

$$

以下是代码示例：[^3]
```cpp
#include "error.cuh" 
#include <stdio.h>
#include <cublas_v2.h>

void print_matrix(int R, int C, double* A, const char* name);

int main(void)
{
    int M = 2;
    int K = 3;
    int N = 2;
    int MK = M * K;
    int KN = K * N;
    int MN = M * N;

    double *h_A = (double*) malloc(sizeof(double) * MK);
    double *h_B = (double*) malloc(sizeof(double) * KN);
    double *h_C = (double*) malloc(sizeof(double) * MN);
	
    for (int i = 0; i < MK; i++)
    {
        h_A[i] = i;//cublas中以列主序存储
    }
    print_matrix(M, K, h_A, "A");
    for (int i = 0; i < KN; i++)
    {
        h_B[i] = i;//cublas中以列主序存储
    }
    print_matrix(K, N, h_B, "B");
    for (int i = 0; i < MN; i++)
    {
        h_C[i] = 0;
    }

    double *g_A, *g_B, *g_C;
    CHECK(cudaMalloc((void **)&g_A, sizeof(double) * MK))
    CHECK(cudaMalloc((void **)&g_B, sizeof(double) * KN))
    CHECK(cudaMalloc((void **)&g_C, sizeof(double) * MN))

    cublasSetVector(MK, sizeof(double), h_A, 1, g_A, 1);
    cublasSetVector(KN, sizeof(double), h_B, 1, g_B, 1);
    cublasSetVector(MN, sizeof(double), h_C, 1, g_C, 1);

    cublasHandle_t handle;
    cublasCreate(&handle);
    double alpha = 1.0;
    double beta = 0.0;
    
    cublasDgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N,
        M, N, K, &alpha, g_A, M, g_B, K, &beta, g_C, M);
    cublasDestroy(handle);

    cublasGetVector(MN, sizeof(double), g_C, 1, h_C, 1);
    print_matrix(M, N, h_C, "C = A x B");

    free(h_A);
    free(h_B);
    free(h_C);
    CHECK(cudaFree(g_A))
    CHECK(cudaFree(g_B))
    CHECK(cudaFree(g_C))
    return 0;
}
```

目前，使用 cuBLAS 时建议包含 <cublas_v2.h>。

函数将矩阵初始化之后，将数据复制到对应的设备矩阵 g_A、 g_B 和 g_C。该复制过程是由如下函数实现的：

```cpp
cublasStatus_t cublasSetVector 
( 
	int n, 
	int elemSize, 
	const void *x, 
	int incx, 
	void *y, int incy 
);
```

该函数从主机数组 x 复制 n 个元素到设备数组 y 。参数 `elemSize` 是每个元素的字节数，` incx` 表示对数组 x 进行访问时每 incx 个数据中取一个， `incy` 表示对数组 y 进行访问时每 incy 个数据中取一个。例如，当 incx 等于 2 时，将使用 x[0]、x[2] 等元素。

矩阵乘法部分，需要定义一个 `cublasHandle `类型的变量并用`cublasCreate()` 函数初始化，然后调用`cublasDgemm` 函数做矩阵相乘的计算，最后用 `cublasDestroy `销毁刚刚定义的 `cublasHandle `类型的变量。

该函数中的 D 指 double。类似的还有 S（单精度实数）、C（单精度复数）和 Z（双精度复数）。 该函数中的 gemm 指 GEneral Matrix-Matrix multiplication，该函数的原型为：

```cpp
cublasStatus_t cublasDgemm 
( 
	cublasHandle_t handle, 
	cublasOperation_t transa, 
	cublasOperation_t transb, 
	int m, 
	int n, 
	int k, 
	const double *alpha,
	const double *A, 
	int lda, 
	const double *B, 
	int ldb, 
	const double *beta, 
	double *C, 
	int ldc 
);
```

该函数实施如下计算： 
$$
C = alpha * transa(A) * transb(B) + beta * C
$$


- alpha 和 beta 是标量参数。 
- A、B 和 C 是列主序的矩阵。
- transa(A) 是对矩阵 A 做一个变换之后得到的矩阵，维度是 m和k；
- transa(B) 是对矩阵B 做一个变换之后得到的矩阵，维度是 k和n。
- C 的维度是 m和n。 
- 对矩阵A来说，transa 为 CUBLAS_OP_N 时，transa(A) 等 于 A； 
- transa 为 CUBLAS_OP_T 时，transa(A)等于A的转置；
- transa 为 CUBLAS_OP_C 时，transa(A)等于A的共轭转置。 
- lda、ldb 和 ldc 分别是矩阵 transa(A)、transa(B) 和 C 的主维度。 对于列主序的矩阵，主维度就是矩阵的行数。

做完矩阵乘法之后，再用 `cublasGetVector()` 函数将设备数组 g_C 中的数据复制到主机数组 h_C。该函数与` cublasSetVector() `函数类似，只不过数据传递的方向相反。



[^1]: https://github.com/brucefan1983/CUDA-Programming/blob/master/src/14-libraries/thrust_scan_vector.cu

[^2]: https://github.com/brucefan1983/CUDA-Programming/blob/master/src/14-libraries/thrust_scan_pointer.cu

[^3]: https://github.com/brucefan1983/CUDA-Programming/blob/master/src/14-libraries/cublas_gemm.cu
