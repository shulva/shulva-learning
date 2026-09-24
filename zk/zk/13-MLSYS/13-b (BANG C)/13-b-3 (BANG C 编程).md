# BANG C 编程

## 编程流程

使用 Cambricon BANG C 编写程序时，需要同时编写主机侧（Host）和设备侧（MLU）代码。

- 主机侧通过 CNRT 或 CNDrv 完成设备选择、内存管理、Host/Device 数据传输、任务队列管理、Kernel 启动、同步和资源释放；
- 设备侧由一个或多个 Kernel 组成，Kernel 之间可以串行执行，也可以并行执行，其调度由主机侧控制；
- BANG C 源文件以 `.mlu` 为后缀，头文件沿用 C/C++ 的 `.h`；异构程序必须包含 `bang.h`。

典型的 Cambricon BANG C 程序执行流程如下：

1. 通过 CNRT 接口选择硬件设备：

   ```cpp
   unsigned int count = 0;
   cnrtGetDeviceCount(&count);
   cnrtSetDevice(0);
   ```

2. 在主机侧准备输入数据，并为输出数据分配空间。

3. 在主机侧调用 CNRT 接口分配设备内存，并将输入数据拷贝到设备内存：

   ```cpp
   float *mlu_input;
   cnrtMalloc((void **)&mlu_input, bytes);
   cnrtMemcpy(mlu_input, host_input, bytes, cnrtMemcpyHostToDev);
   ```

4. 使用 `cnrtDim3_t` 设置 Kernel 的任务规模：

   ```cpp
   cnrtDim3_t dim;
   dim.x = 1;
   dim.y = 1;
   dim.z = 1;
   ```

5. 使用 `cnrtFunctionType_t` 设置任务类型，其值可以是 Block 或 UnionN（N = 1、2、4、8）：

   ```cpp
   cnrtFunctionType_t ktype = CNRT_FUNC_TYPE_BLOCK;
   ```

6. 通过 CNRT 接口创建任务队列：

   ```cpp
   cnrtQueue_t queue;
   cnrtQueueCreate(&queue);
   ```

7. 向任务队列中添加 Kernel：

   ```cpp
   Kernel<<<dim, ktype, queue>>>(...);
   ```

8. 调用 CNRT 接口等待任务队列执行完成：

   ```cpp
   cnrtQueueSync(queue);
   ```

9. 将计算结果拷贝回主机侧，必要时再进行数据类型转换：

   ```cpp
   cnrtMemcpy(host_output, mlu_output, bytes, cnrtMemcpyDevToHost);
   ```

10. 释放任务队列、设备侧内存和主机侧内存等资源：

    ```cpp
    cnrtQueueDestroy(queue);
    cnrtFree(mlu_input);
    cnrtFree(mlu_output);
    free(host_input);
    free(host_output);
    ```

流程可概括为：

```text
选择设备 → 准备 Host 数据 → 分配 MLU 内存 → H2D 拷贝
        → 配置 dim/ktype → 创建队列 → 启动 Kernel → 同步
        → D2H 拷贝 → 校验结果 → 释放资源
```

### 向量加法示例

设备侧 Kernel 的工作过程：

1. 用 `__mlu_entry__` 声明设备入口函数。
2. 用 `__nram__` 在 NRAM 中声明两个输入缓冲区和一个输出缓冲区。
3. 通过 `__memcpy(..., GDRAM2NRAM)` 将两个输入向量从 GDRAM 搬到 NRAM。
4. 使用 `__bang_add` 在 NRAM 中完成逐元素向量加法。
5. 通过 `__memcpy(..., NRAM2GDRAM)` 把结果写回 GDRAM。

完整代码如下：

```cpp
#include <bang.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define LEN 1024
#define EPS 1e-7f

// Device：GDRAM → NRAM → 向量加法 → GDRAM
__mlu_entry__ void VectorAddKernel(float *dst_gdram,
                                   float *lhs_gdram,
                                   float *rhs_gdram) {
    __nram__ float lhs_nram[LEN];
    __nram__ float rhs_nram[LEN];
    __nram__ float dst_nram[LEN];

    __memcpy(lhs_nram, lhs_gdram,
             LEN * sizeof(float), GDRAM2NRAM);
    __memcpy(rhs_nram, rhs_gdram,
             LEN * sizeof(float), GDRAM2NRAM);

    __bang_add(dst_nram, lhs_nram, rhs_nram, LEN);

    __memcpy(dst_gdram, dst_nram,
             LEN * sizeof(float), NRAM2GDRAM);
}

int main(void) {
    // 1. 选择设备并创建队列
    CNRT_CHECK(cnrtSetDevice(0));

    cnrtQueue_t queue;
    CNRT_CHECK(cnrtQueueCreate(&queue));

    // 2. 配置 Kernel：一个 Block、一个任务
    cnrtDim3_t dim = {1, 1, 1};
    cnrtFunctionType_t ktype = CNRT_FUNC_TYPE_BLOCK;

    // 3. 创建计时用 Notifier
    cnrtNotifier_t start;
    cnrtNotifier_t end;
    CNRT_CHECK(cnrtNotifierCreate(&start));
    CNRT_CHECK(cnrtNotifierCreate(&end));

    // 4. 分配并初始化 Host 内存
    const size_t bytes = LEN * sizeof(float);
    float *host_dst = (float *)malloc(bytes);
    float *host_lhs = (float *)malloc(bytes);
    float *host_rhs = (float *)malloc(bytes);

    if (host_dst == NULL || host_lhs == NULL || host_rhs == NULL) {
        fprintf(stderr, "Host memory allocation failed.\n");
        free(host_dst);
        free(host_lhs);
        free(host_rhs);
        CNRT_CHECK(cnrtNotifierDestroy(start));
        CNRT_CHECK(cnrtNotifierDestroy(end));
        CNRT_CHECK(cnrtQueueDestroy(queue));
        return 1;
    }

    for (int i = 0; i < LEN; ++i) {
        host_lhs[i] = (float)i;
        host_rhs[i] = (float)i;
    }

    // 5. 分配 Device（MLU）内存
    float *mlu_dst = NULL;
    float *mlu_lhs = NULL;
    float *mlu_rhs = NULL;
    CNRT_CHECK(cnrtMalloc((void **)&mlu_dst, bytes));
    CNRT_CHECK(cnrtMalloc((void **)&mlu_lhs, bytes));
    CNRT_CHECK(cnrtMalloc((void **)&mlu_rhs, bytes));

    // 6. 输入数据：Host → Device
    CNRT_CHECK(cnrtMemcpy(mlu_lhs, host_lhs, bytes,
                          cnrtMemcpyHostToDev));
    CNRT_CHECK(cnrtMemcpy(mlu_rhs, host_rhs, bytes,
                          cnrtMemcpyHostToDev));

    // 7. 在同一队列中依次放入起点、Kernel 和终点
    CNRT_CHECK(cnrtPlaceNotifier(start, queue));
    VectorAddKernel<<<dim, ktype, queue>>>(mlu_dst, mlu_lhs, mlu_rhs);
    CNRT_CHECK(cnrtPlaceNotifier(end, queue));

    // 8. 等待队列中的任务全部完成
    CNRT_CHECK(cnrtQueueSync(queue));

    // 9. 计算结果：Device → Host
    CNRT_CHECK(cnrtMemcpy(host_dst, mlu_dst, bytes,
                          cnrtMemcpyDevToHost));

    // 10. 校验结果：i + i = 2i
    int error_count = 0;
    for (int i = 0; i < LEN; ++i) {
        const float expected = 2.0f * (float)i;
        if (fabsf(host_dst[i] - expected) > EPS) {
            printf("index %d: expected %f, got %f\n",
                   i, expected, host_dst[i]);
            ++error_count;
        }
    }

    // 11. 读取设备执行时间；原示例将结果除以 1000 转为 ms
    float duration = 0.0f;
    CNRT_CHECK(cnrtNotifierDuration(start, end, &duration));
    printf("Total Time: %.3f ms\n", duration / 1000.0f);
    printf("Result: %s\n", error_count == 0 ? "PASS" : "FAIL");

    // 12. 释放全部资源
    CNRT_CHECK(cnrtNotifierDestroy(start));
    CNRT_CHECK(cnrtNotifierDestroy(end));
    CNRT_CHECK(cnrtQueueDestroy(queue));

    cnrtFree(mlu_dst);
    cnrtFree(mlu_lhs);
    cnrtFree(mlu_rhs);

    free(host_dst);
    free(host_lhs);
    free(host_rhs);

    return error_count == 0 ? 0 : 1;
}
```

> [!NOTE]
> - 向量计算的输入和输出需要位于 NRAM。示例先将数据从 GDRAM 拷贝到 NRAM，调用 `__bang_add` 完成计算，再将结果写回 GDRAM；
> - `Kernel<<<...>>>` 会将任务异步提交到队列，主机侧需要使用 `cnrtQueueSync` 等待队列执行完成后再读取结果；
> - 设备、内存、任务队列、同步和资源释放均由主机侧管理，设备侧 Kernel 只描述单个任务内部的计算；
> - 在同一队列中将起止 Notifier 放在 Kernel 两侧，可以使用 `cnrtNotifierDuration` 统计 Kernel 的执行时间。

## 编译流程

Cambricon BANG C 程序使用 CNCC 进行编译。CNCC 支持主机端和设备端混合程序的编译，可以将同时包含 Host 代码和 Device 代码的 `.mlu` 文件编译为能够在 Cambricon BANG 异构计算平台上运行的可执行程序。

CNCC 会对 `.mlu` 文件进行多次编译：

- 面向主机端编译时，忽略设备端代码；
- 面向设备端编译时，忽略主机端代码。

![CNCC 混合编译流程](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/hybridprogram.png)

具体的编译流程如下：

1. CNCC 根据设备端程序的属性标识区分 Host 代码和 Device 代码；
2. 无论编译主机端还是设备端，CNCC 都会先调用 Clang 前端，将 Cambricon BANG C 程序转换为 LLVM IR；
3. 对于主机端代码，CNCC 调用 LLVM 进行优化，并生成主机架构对应的目标文件；
4. 对于设备端代码，CNCC 调用 LLVM 生成面向寒武纪硬件的 MLISA 汇编代码；
5. CNAS 汇编器将 MLISA 汇编代码处理为设备端目标文件；
6. 面向不同设备架构的目标文件经过链接，形成 CNFatbin 文件；
7. CNCC 调用本地链接器，将设备端 CNFatbin、运行时库和主机端目标文件链接为最终的可执行程序。

```text
                         ┌→ Host LLVM IR → LLVM 优化 → Host 目标文件 ─┐
.mlu → Clang 前端 ───────┤                                         ├→ 本地链接器 → 可执行程序
                         └→ Device LLVM IR → MLISA → CNAS → CNFatbin ┘
                                                  + 运行时库
```

### 目标架构

设备端目标文件面向特定的硬件架构，面向架构 A 编译的目标文件不能直接在架构 B 上运行。编译时可以通过以下两种方式指定目标硬件：

- `--bang-mlu-arch=<arch>`：指定一个具体的 MLU 架构；
- `--bang-arch=<compute>`：指定计算能力，生成包含该计算能力下多个架构目标文件的 fatbin，运行时会根据实际硬件选择对应的程序。

例如，指定具体架构 `mtp_372`：

```bash
cncc main.mlu -o main.out --bang-mlu-arch=mtp_372
```

Cambricon BANG 异构并行计算平台保证硬件特性的兼容性。例如，面向 `compute_20` 编写的程序通常无需修改或只需少量修改即可适配 `compute_30`。

> [!NOTE]
> CNCC 定义了仅能在设备端使用的 `__BANG_ARCH__` 宏，用于根据目标架构进行条件编译。该宏的值与目标架构对应，例如目标架构为 `mtp_372` 时，`__BANG_ARCH__ = 372`。

### CNCC 常见编译选项

在 Linux 系统中，CNCC 以二进制命令的形式使用，基本语法如下：

```bash
cncc 输入文件名 [-编译选项1] [-编译选项2] [...]
```

| 编译选项 | 作用 |
| --- | --- |
| `--help` | 查看 CNCC 帮助信息 |
| `-o <输出文件名>` | 指定输出目标文件名 |
| `--bang-mlu-arch=<arch>` | 指定目标架构型号 |
| `--bang-arch=<compute>` | 指定目标计算能力编号 |
| `-S` | 输出主机端或设备端汇编指令 |
| `--bang-device-only` | 仅编译设备侧程序，通常与 `-S` 配合生成 MLISA 汇编代码 |
| `--bang-host-only` | 仅编译主机侧程序 |
| `-O3`、`-O2`、`-O1`、`-O0`、`-Os` | 设置编译优化级别；默认使用 `-O0`，不进行自动编译优化 |
| `-g` | 生成带调试信息的可执行程序，目前只能与 `-O0` 配合使用 |

例如，将同时包含主机侧和设备侧代码的 `main.mlu` 编译为能够在 `mtp_270` 架构上运行的可执行程序：

```bash
cncc main.mlu -o main.out --bang-mlu-arch=mtp_270 -O3
```

## CNBin 与 CNFatbin

CNBin 是一种基于 ELF（Executable and Linkable Format，可执行与可链接格式）结构的文件，其中包含面向某一特定架构的设备侧程序代码，以及相关的符号、重定位和调试信息。

CNFatbin 中包含一种或多种不同架构的 CNBin。CNRT 或 CNDrv 可以在运行时根据实际硬件加载对应架构的设备侧代码，从而实现一次编译、多处运行。

| 文件 | 内容 | 适用范围 |
| --- | --- | --- |
| CNBin | 单个目标架构的设备侧代码及其符号、重定位和调试信息 | 只能在对应架构上运行 |
| CNFatbin | 一个或多个不同架构的 CNBin | 运行时根据硬件选择合适的 CNBin |

CNCC 可以使用 `--bang-fatbin-only` 直接生成 CNFatbin。下面的命令将 `device_code.mlu` 编译为同时支持 `mtp_270`、`mtp_372` 和 `mtp_592` 的 CNFatbin：

```bash
cncc --bang-fatbin-only \
  --bang-mlu-arch=mtp_270 \
  --bang-mlu-arch=mtp_372 \
  --bang-mlu-arch=mtp_592 \
  device_code.mlu \
  -o device_code.cnfatbin \
  -O3
```

> [!NOTE]
> CNFatbin 可以通过 CNDrv 的 Module 管理系列接口进行动态加载和执行。
