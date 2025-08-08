# CUDA错误检测

```
# cuda错误检查宏
#pragma once
#include <stdio.h>

#define CHECK(call)                                   \
do                                                    \
{                                                     \
    const cudaError_t error_code = call;              \
    if (error_code != cudaSuccess)                    \
    {                                                 \
        printf("CUDA Error:\n");                      \
        printf("    File:       %s\n", __FILE__);     \
        printf("    Line:       %d\n", __LINE__);     \
        printf("    Error code: %d\n", error_code);   \
        printf("    Error text: %s\n",                \
            cudaGetErrorString(error_code));          \
        exit(1);                                      \
    }                                                 \
} while (0)
```

所有 CUDA 运行时 API 函数都是以 cuda 为前缀的，而且都有一个类型为 cudaError_t的返回值，代表了一种错误信息。只有返回值为cudaSuccess时才代表成功地调用了 API 函数。

在使用该宏函数时，只要将一个 CUDA 运行时 API 函数当作参数传入该宏函数即可。 例如，如下宏函数的调用 `CHECK(cudaFree(d_x));` 调试比较方便。

### 核函数

用上述方法不能捕捉调用核函数的相关错误，因为核函数不返回任何值(必须要 void)。有一个方法可以捕捉调用核函数可能发生的错误，即在调用核函数之后加上如下两个语句：

```
CHECK(cudaGetLastError()); 
CHECK(cudaDeviceSynchronize());
```
``

其中，第一个语句的作用是捕捉第二个语句之前的最后一个错误，第二个语句的作用是同步主机与设备。

之所以要同步主机与设备，是因为核函数的调用是异步的，即主机发出调 用核函数的命令后会立即执行后面的语句，不会等待核函数执行完毕。

需要注意的是，上述同步函数是比较耗时的，如果在程序的较内层循环调用的话，很可能会严重地降低程序的性能。所以，一般不在程序的较内层循环调用上述同步函数。


