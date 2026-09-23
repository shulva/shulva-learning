# BANG C 编程模型

## Kernel

在 Cambricon BANG 异构并行编程模型中，CPU 作为主机侧的控制设备，用于完成复杂的控制和任务调度；而设备侧的 MLU 则用于大规模并行计算和领域相关的计算任务。

在 Cambricon BANG 异构并行编程模型中，在 MLU 上执行的程序称作 Kernel。每个 Task 都执行一次对应的 Kernel 函数。在 MLU 上可以同时执行多个并行的 Kernel。

在 Cambricon BANG C 语言中，设备侧的 Kernel 是一个带有 `__mlu_entry__` 属性的函数，该函数描述一个 Task 需要执行的所有操作。在 Kernel 内部还可以通过 `taskId` 等内建变量获得每个 Task 唯一的 ID，从而实现不同 Task 的差异化处理。此外，类似的内建变量还包括 `clusterId` 、`taskIdX` 、`taskIdY` 等。

以下示例定义了一个用于实现向量加法的 Kernel 函数，该示例将一个完整的向量加法操作拆分成多个可以独立的任务，每个任务实现64个元素的加法。
```cpp
 #define SIZE_PER_TASK 64

 __mlu_entry__ void Kernel(half* dst, half* src1, half* src2) {
   __nram__ half output[SIZE_PER_TASK];
   __nram__ half input1[SIZE_PER_TASK];
   __nram__ half input2[SIZE_PER_TASK];
   __memcpy(input1, src1 + SIZE_PER_TASK * taskId, SIZE_PER_TASK * sizeof(half) , GDRAM2NRAM);
   __memcpy(input2, src2 + SIZE_PER_TASK * taskId, SIZE_PER_TASK * sizeof(half) , GDRAM2NRAM);
   __bang_add(output, input1, input2, SIZE_PER_TASK);
   __memcpy(dst + SIZE_PER_TASK * taskId, output, SIZE_PER_TASK * sizeof(half) , NRAM2GDRAM);
}
```

Cambricon BANG C语言提供了语法糖 `<<<...>>>` 用于在主机侧以类似普通函数调用的方式启动一个 Kernel：
```cpp
#include "bang.h"

int main() {
  ...
  Kernel<<<dim, ktype, pQueue>>>(mlu_result, mlu_source1, mlu_source2);
  ...
}
```

其中，`<<<dim, ktype, pQueue>>>` 中的 dim 表示任务规模，pQueue 表示该 Kernel 将会放到哪个任务 队列中执行，ktype 表示任务类型，即 Kernel 执行需要的硬件资源数量。

在主机侧使用 `<<<dim, ktype, pQueue>>>` 语法糖启动的 Kernel 会异步执行，主机侧不需要等待 Kernel 执行完毕即可继续执行后续的代码。Cambricon BANG 异构并行计算平台会将对应的 Kernel 插入对应的执行队列中，并在设备侧有资源空闲时调度 Kernel 到硬件上执行。

如图所示，主机侧顺序启动 Kernel1、Kernel2 和 Kernel3。具体执行顺序如下：

- Kernel1 和 Kernel3 位于同一个执行队列中，因此 Kernel3 需要等待 Kernel1 执行完毕才能开始执行；
- Kernel2 与 Kernel1 和 Kernel3 不在同一个队列中，因此 Kernel2 可以与 Kernel1 或 Kernel3 并行执行。
![Kernel Seq](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/timechart.png)

## Task 规模

在 Cambricon BANG 异构并行编程模型中，一个 Kernel 描述了一个 Task 的行为。
在具体编程过程中，用户需要将一个完整的计算任务拆解为一系列可以并行的 Task，所有的 Task 构成一个三维网格。这个三维网络的维度信息由用户做任务拆分时确定。
在由 Task 构成的三维网格中，每个 Task 都有唯一的坐标。每个任务除了一个三维坐标以外，还有一个全局唯一的线性 ID。在实际执行时，**每个 Task 会映射到一个物理 MLU Core 上执行**。
MLU Core 在执行一个 Task 的过程中不会发生切换，只有一个 Task 执行完毕，另一个 Task 才能开始执行。

为了便于描述任务规模，在 Cambricon BANG C 编程语言中引入了 `cnrtDim3_t` 数据类型：
```cpp
cnrtDim3_t dim;
dim.x = 8;
dim.y = 8;
dim.z = 4;
```

上述配置描述的三维任务网格如图所示。
![cube](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/taskgrid.png)

> [!NOTE] 
> dim.x, dim.y和dim.z需要小于65536。 
> 图中 Task 构成的三维网格中蓝色任务的三维坐标为 (5, 0, 0)，线性编号为 5。

Cambricon BANG C 语言为用户提供了一系列内置变量来显式并行编程。其中，与任务规模相关的内置变量包括： `taskDim`  `taskDimX` 、 `taskDimY` 以及 `taskDimZ` 。

- `taskDimX`、`taskDimY` 和 `taskDimZ` 分别对应任务规模的三个维度： `dim.x` 、 `dim.y` 和 `dim.z` 。
- `taskIdX`、`taskIdY` 和 `taskIdZ` 的取值范围分别是 `[0, taskDimX-1]` , `[0, taskDimY-1]` , `[0, taskDimZ-1]` 。
- `taskDim` 等于 `taskDimX`、`taskDimY` 和 `taskDimZ` 三者的乘积。

在图中所示的任务规模配置为 `taskDimX=8`，`taskDimY=8`，`taskDimZ=4`, `taskDim = 256` 。

对于每个任务, 可以通过内置变量 `taskIdX`、`taskIdY` 和 `taskIdZ` 获得本任务在 X 方向、Y 方向和 Z 方向的坐标。也可以通过 `taskId` 获得本任务在整个三维任务块中的线性编号, 即 `taskId = taskIdZ * taskDimY * taskDimX + taskIdY * taskDimX + taskIdX`。`taskId` 的取值范围是 `[0, taskDim -1]` 

基于图所示的任务规模配置，如果要实现两个长度为16384的向量加法，那么每个任务需要处理16384 / 8 / 8 / 4 = 64个元素。使用 Cambricon BANG C 实现的 Kernel 函数如下所示：

```cpp
#define N 64

__nram__ float x_tmp[N];
__nram__ float y_tmp[N];

__mlu_global__ add(float* x, float* y, float* z) {
   __memcpy(x_tmp, x + taskId * N, N * sizeof(float), GDRAM2NRAM);
   __memcpy(y_tmp, y + taskId * N, N * sizeof(float), GDRAM2NRAM);
   __bang_add(x_tmp, x_tmp, y_tmp, N);
   __memcpy(z + taskId * N, x_tmp, N * sizeof(float), NRAM2GDRAM);
}
```

## Task 类型

任务类型指定了一个 Kernel 所需要的硬件资源数量，即一个 Kernel 在实际执行时会启动多少个物理 MLU Core 或者 Cluster。在 Cambricon BANG 异构并行编程模型中支持两种任务类型：Block 任务和 Union 任务。

Block 任务代表一个 Kernel 在执行时至少需要占用一个 MLU Core。
对于 Block 类型的任务:
- 不支持共享 SRAM
- 不支持不同 Cluster 之间的通信。

Block 任务是所有寒武纪硬件都支持的任务类型。当任务规模大于1时，由 Cambricon BANG 异构并行计算平台根据硬件资源占用情况决定所有任务占用的 MLU Core 数量：如果只有一个 MLU Core 可用，那么所有任务在同一个 MLU Core 上串行执行；如果有多个物理 MLU Core 可用，那么所有任务会被平均分配到所有可用的 MLU Core 上分批次执行。

UnionN (N=1, 2, 4, 8, ...) 任务表示一个 Kernel 在执行时至少需要占用 N 个 Cluster，其中，N 必须为 2 的整数次幂。UnionN任务中**每 N * 4 个Task一组（称为一个 Job）** 并行执行。
一个Job内的 N * 4 个 Task可以借助GDRAM共享数据。一个拥有 M 个 Cluster 的硬件，N 的最大值为 ![2 ^ {\lfloor log_2M \rfloor}](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/math/dbf961536f61c347f3d7211a090376b0c336eaa4.png) 。

MLU 硬件对Union 任务的支持与硬件的具体配置有关。例如，一些终端侧或者边缘侧的单核设备不支持 Union 任务，而一个拥有 8 个 Cluster 的硬件只能够支持 Union1、Union2、Union4 和 Union8 类型的 Union 任务，无法支持 Union16 类型的任务。对于592，建议规约类任务使用 UnionN （N>1）任务类型；其他 Kernel 建议使用 Union1 任务。

> [!Warning] 注意
> - 对于 Union1 类型的任务，dim.x 必须是 4 的倍数，支持一个 Cluster 中的 4 个 MLU Core 和一个 Memory Core 共享 SRAM，但是不支持 Cluster 之间的通信。 
> - 对于 Union2/4/8 类型的任务，dim.x 必须是 8/16/32 的倍数，而且每个 Cluster 中的 4 个 MLU Core 和 Memory Core 共享 SRAM，支持 2/4/8 个 Cluster 之间借助GDRAM的通信。 
> - Cambricon BANG 异构并行编程模型不支持 taskIdY 和 taskIdZ 不同的任务之间通过共享SRAM通信。

硬件当前空闲的物理 Cluster 数量大于UnionN任务类型所需要的 Cluster 数量时，由 Cambricon BANG 异构并行计算平台根据硬件资源的占用情况决定是否将任务平均分配到更多的 Cluster 上执行。

#### 示例

- 任务类型为 Union2  
- 任务规模为 {x=8,y=2, z=2}  
- clusterDim 对应任务类型，在本例中 clusterDim = 2  
- taskDimX，taskDimY，taskDimZ 分别对应任务规模，在本示例中，taskDimX=8， taskDimY=2，taskDimZ=2，taskDim = 8 * 2 * 2 = 32。
- taskDimX = 8 ，因此需要同时占用8个 MLU Core，分别对应上面表格的8行；
- 整个任务需要4轮迭代才能执行完毕，每个内建变量在每一轮的取值如上述表格的各列所示。

<div style="
  width:100%;
  overflow-x:auto;
  padding-bottom:8px;
">

<table style="
  border-collapse:collapse;
  min-width:1450px;
  width:1450px;
  text-align:center;
  font-family:Arial, sans-serif;
  font-size:16px;
  white-space:nowrap;
">

  <thead>

    <!-- 一级表头 -->
    <tr style="
      background:#0866c6;
      color:#fff !important;
      font-weight:bold;
    ">

      <th rowspan="2"
          style="
            border:1px solid #333;
            padding:14px 16px;
            color:#fff !important;
            background:#0866c6;
          ">
        Core
      </th>

      <th colspan="4"
          style="
            border:1px solid #333;
            padding:14px 16px;
            color:#fff !important;
            background:#0866c6;
          ">
        taskId
      </th>

      <th colspan="4"
          style="
            border:1px solid #333;
            padding:14px 16px;
            color:#fff !important;
            background:#0866c6;
          ">
        taskIdX
      </th>

      <th colspan="4"
          style="
            border:1px solid #333;
            padding:14px 16px;
            color:#fff !important;
            background:#0866c6;
          ">
        taskIdY
      </th>

      <th colspan="4"
          style="
            border:1px solid #333;
            padding:14px 16px;
            color:#fff !important;
            background:#0866c6;
          ">
        taskIdZ
      </th>

      <th colspan="4"
          style="
            border:1px solid #333;
            padding:14px 16px;
            color:#fff !important;
            background:#0866c6;
          ">
        clusterId
      </th>

      <th colspan="4"
          style="
            border:1px solid #333;
            padding:14px 16px;
            color:#fff !important;
            background:#0866c6;
          ">
        coreId
      </th>

    </tr>


    <!-- 二级表头 -->
    <tr style="
      background:#0866c6;
      color:#fff !important;
      font-weight:bold;
    ">

      <!-- taskId -->
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">0</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">1</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">2</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">3</th>

      <!-- taskIdX -->
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">0</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">1</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">2</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">3</th>

      <!-- taskIdY -->
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">0</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">1</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">2</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">3</th>

      <!-- taskIdZ -->
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">0</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">1</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">2</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">3</th>

      <!-- clusterId -->
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">0</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">1</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">2</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">3</th>

      <!-- coreId -->
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">0</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">1</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">2</th>
      <th style="border:1px solid #333;padding:12px;color:#fff !important;background:#0866c6;">3</th>

    </tr>

  </thead>


  <tbody>

    <!-- Core 0 -->
    <tr>

      <td style="border:1px solid #333;padding:14px;">0</td>

      <!-- taskId -->
      <td style="border:1px solid #333;">0</td>
      <td style="border:1px solid #333;">8</td>
      <td style="border:1px solid #333;">16</td>
      <td style="border:1px solid #333;">24</td>

      <!-- taskIdX -->
      <td colspan="4" style="border:1px solid #333;">0</td>

      <!-- taskIdY -->
      <td rowspan="8"
          style="border:1px solid #333;vertical-align:top;padding-top:14px;">
        0
      </td>

      <td rowspan="8"
          style="border:1px solid #333;vertical-align:top;padding-top:14px;">
        1
      </td>

      <td rowspan="8"
          style="border:1px solid #333;vertical-align:top;padding-top:14px;">
        0
      </td>

      <td rowspan="8"
          style="border:1px solid #333;vertical-align:top;padding-top:14px;">
        1
      </td>

      <!-- taskIdZ -->
      <td rowspan="8"
          style="border:1px solid #333;vertical-align:top;padding-top:14px;">
        0
      </td>

      <td rowspan="8"
          style="border:1px solid #333;">
      </td>

      <td rowspan="8"
          style="border:1px solid #333;vertical-align:top;padding-top:14px;">
        1
      </td>

      <td rowspan="8"
          style="border:1px solid #333;">
      </td>

      <!-- clusterId -->
      <td colspan="4"
          rowspan="4"
          style="
            border:1px solid #333;
            vertical-align:top;
            padding-top:14px;
          ">
        0
      </td>

      <!-- coreId -->
      <td colspan="4"
          style="border:1px solid #333;">
        0
      </td>

    </tr>


    <!-- Core 1 -->
    <tr>

      <td style="border:1px solid #333;padding:14px;">1</td>

      <td style="border:1px solid #333;">1</td>
      <td style="border:1px solid #333;">9</td>
      <td style="border:1px solid #333;">17</td>
      <td style="border:1px solid #333;">25</td>

      <td colspan="4" style="border:1px solid #333;">1</td>

      <td colspan="4" style="border:1px solid #333;">1</td>

    </tr>


    <!-- Core 2 -->
    <tr>

      <td style="border:1px solid #333;padding:14px;">2</td>

      <td style="border:1px solid #333;">2</td>
      <td style="border:1px solid #333;">10</td>
      <td style="border:1px solid #333;">18</td>
      <td style="border:1px solid #333;">26</td>

      <td colspan="4" style="border:1px solid #333;">2</td>

      <td colspan="4" style="border:1px solid #333;">2</td>

    </tr>


    <!-- Core 3 -->
    <tr>

      <td style="border:1px solid #333;padding:14px;">3</td>

      <td style="border:1px solid #333;">3</td>
      <td style="border:1px solid #333;">11</td>
      <td style="border:1px solid #333;">19</td>
      <td style="border:1px solid #333;">27</td>

      <td colspan="4" style="border:1px solid #333;">3</td>

      <td colspan="4" style="border:1px solid #333;">3</td>

    </tr>


    <!-- Core 4 -->
    <tr>

      <td style="border:1px solid #333;padding:14px;">4</td>

      <td style="border:1px solid #333;">4</td>
      <td style="border:1px solid #333;">12</td>
      <td style="border:1px solid #333;">20</td>
      <td style="border:1px solid #333;">28</td>

      <td colspan="4" style="border:1px solid #333;">4</td>

      <!-- clusterId = 1 -->
      <td colspan="4"
          rowspan="4"
          style="
            border:1px solid #333;
            vertical-align:top;
            padding-top:14px;
          ">
        1
      </td>

      <td colspan="4"
          style="border:1px solid #333;">
        0
      </td>

    </tr>


    <!-- Core 5 -->
    <tr>

      <td style="border:1px solid #333;padding:14px;">5</td>

      <td style="border:1px solid #333;">5</td>
      <td style="border:1px solid #333;">13</td>
      <td style="border:1px solid #333;">21</td>
      <td style="border:1px solid #333;">29</td>

      <td colspan="4" style="border:1px solid #333;">5</td>

      <td colspan="4" style="border:1px solid #333;">1</td>

    </tr>


    <!-- Core 6 -->
    <tr>

      <td style="border:1px solid #333;padding:14px;">6</td>

      <td style="border:1px solid #333;">6</td>
      <td style="border:1px solid #333;">14</td>
      <td style="border:1px solid #333;">22</td>
      <td style="border:1px solid #333;">30</td>

      <td colspan="4" style="border:1px solid #333;">6</td>

      <td colspan="4" style="border:1px solid #333;">2</td>

    </tr>


    <!-- Core 7 -->
    <tr>

      <td style="border:1px solid #333;padding:14px;">7</td>

      <td style="border:1px solid #333;">7</td>
      <td style="border:1px solid #333;">15</td>
      <td style="border:1px solid #333;">23</td>
      <td style="border:1px solid #333;">31</td>

      <td colspan="4" style="border:1px solid #333;">7</td>

      <td colspan="4" style="border:1px solid #333;">3</td>

    </tr>

  </tbody>

</table>

</div>


> [!warning] 
> taskDimX = 8，因此需要同时占用 8 个 MLU Core，分别对应上面表格的 8 行； 整个任务需要 4 轮迭代才能执行完毕，每个内建变量在每一轮的取值如上述表格的各列所示。

## Task 映射

任务映射决定一个 Task 最终在哪个设备、哪个计算单元上执行，以及多个 Task 按照什么顺序执行。主机侧运行时通过任务队列管理待执行任务，硬件资源空闲后，运行时再从队列中取出任务并下发到设备。设备侧的调度既可以由软件完成，也可以由硬件完成，目标是在不同 MLU 架构上尽可能充分地利用计算资源。

需要区分三个容易混淆的概念：

| 概念 | 回答的问题 |
|---|---|
| 任务类型 | 一个 Kernel 至少需要多少 MLU Core 或 Cluster，也就是硬件资源需求 |
| 任务规模 | 计算被划分成多少个 Task，也就是 `taskDimX × taskDimY × taskDimZ` |
| 任务映射 | 这些逻辑 Task 如何落到物理 Core 或 Cluster 上，并分几轮执行 |

其中，`coreDim` 表示一个 Cluster 中参与执行的 MLU Core 数量。对于 UnionN 任务，`clusterDim = N`，表示一个 Job 至少占用 N 个 Cluster。

### Block 任务的映射

Block 任务只要求一个 MLU Core，因此只要有一个 Core 空闲，运行时就可以下发任务。它的最小并行度为 1。

如果暂不考虑任务展开，所有 Task 逐个执行，需要的迭代次数为：

$$
\text{迭代次数}=taskDimX \times taskDimY \times taskDimZ
$$

实际下发时，驱动会参考硬件的实时利用率，决定是否把 Block 任务展开到多个空闲 Core 上。这里的“任务展开”是把原本需要多轮执行的 Task 分配给更多计算单元并行处理，它不会改变任务规模，只会减少执行轮数。

### UnionN 任务的映射

UnionN 任务以 N 个 Cluster 为最小资源单位，映射时需要同时满足以下条件：

1. 至少有 N 个满足要求的连续物理 Cluster 空闲，任务才能下发。
2. 起始物理 Cluster ID 必须按照 N 对齐，也就是能够被 N 整除。
3. `taskDimX` 必须是 `N × coreDim` 的正整数倍：

$$
taskDimX \bmod (N \times coreDim)=0
$$

因此，UnionN 任务的最小并行度为：

$$
clusterDim \times coreDim=N \times coreDim
$$

如果暂不考虑任务展开，迭代次数为：

$$
\text{迭代次数}=\frac{taskDimX \times taskDimY \times taskDimZ}{N \times coreDim}
$$

对齐约束会影响不同任务能否同时驻留。例如，一块设备有 6 个 Cluster，先运行的 Union2 占用了某些 Cluster 后，剩余资源即使总数达到 4 个，也可能因为无法找到起始 ID 按 4 对齐的连续区域，而暂时不能下发 Union4。此时必须等待已有任务释放资源。

驱动同样可以对 Union 任务进行展开。以 `coreDim = 4` 的设备为例，Union1、任务规模 `{8, 1, 1}` 的任务最低只占用 1 个 Cluster，每轮并行执行 4 个 Task，因此默认需要 2 轮。如果下发时至少有 2 个 Cluster 空闲，驱动可以让它同时占用 2 个 Cluster，将执行轮数减少为 1。

> [!NOTE] 任务类型只规定最小并行粒度
> UnionN 中的 N 规定任务至少占用多少个 Cluster，不代表运行时一定只分配 N 个 Cluster。空闲资源足够时，驱动可以展开任务，为它分配更多符合对齐要求的 Cluster。

### eg1：对齐与任务展开

假设设备有 16 个物理 Cluster，编号为 0 到 15，每个 Cluster 有 4 个 MLU Core。主机依次下发 4 个彼此独立的 Union 任务：

| 任务     |         任务规模 |        最少占用 | 实际映射               | 迭代次数 |
| ------ | -----------: | ----------: | ------------------ | ---: |
| Union1 |  `{4, 1, 1}` | 1 个 Cluster | Cluster 0          |    1 |
| Union2 |  `{8, 1, 1}` | 2 个 Cluster | Cluster 2 到 3      |    1 |
| Union4 | `{16, 1, 1}` | 4 个 Cluster | Cluster 4 到 7      |    1 |
| Union4 | `{32, 1, 1}` | 4 个 Cluster | 展开到 Cluster 8 到 15 |    1 |

第二个任务没有映射到 Cluster 1 到 2，是因为 Union2 的起始物理 Cluster ID 必须能被 2 整除。第四个任务本来只需占用 4 个 Cluster，分 2 轮完成。由于此时 Cluster 8 到 15 都空闲，驱动将它展开到 8 个 Cluster，于是 1 轮即可完成。

![Union 任务的对齐约束与任务展开](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/physical-logical-cluster-id.png)

> [!IMPORTANT] 物理 ID 与逻辑 ID
> 物理 Cluster ID 是整颗芯片上全局唯一的编号。逻辑 `clusterId` 则在每个 Job 内独立编号，取值范围为 0 到 `clusterDim - 1`。例如，Union4 任务展开到物理 Cluster 8 到 15 时，会形成两组并行 Job，两组看到的逻辑 `clusterId` 都是 0、1、2、3。

### eg2：资源不足时的执行顺序

假设设备只有 4 个物理 Cluster，主机依次启动三个彼此独立的 Kernel：

- Kernel1 是 Union2，任务规模为 `{8, 1, 1}`。
- Kernel2 是 Union1，任务规模为 `{8, 1, 1}`。
- Kernel3 是 Union4，任务规模为 `{16, 2, 1}`。

执行过程如下：

1. Kernel1 获得 Cluster 0 到 1，共 8 个 MLU Core。因为 `taskDimX = 8`，所以 1 轮即可完成。
2. Kernel2 与 Kernel1 没有依赖，只要还有 1 个 Cluster 空闲就能启动。它映射到 Cluster 2，没有展开，每轮执行 4 个 Task，因此需要 2 轮。Kernel1 和 Kernel2 可以并行执行。
3. Kernel3 至少需要 4 个连续且满足对齐要求的 Cluster。虽然它与前两个 Kernel 没有数据依赖，但资源不足，因此必须等待 Kernel1 和 Kernel2 都完成。取得全部 4 个 Cluster 后，因为 `taskDimY = 2`，Kernel3 仍需执行 2 轮。

![有限硬件资源下的 Union 任务映射与执行顺序](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/execuatemodel.png)

这个例子说明，Kernel 之间没有数据依赖，并不等于它们一定能够并发执行。是否能够同时运行，还取决于任务类型要求的最小资源、Cluster 对齐约束，以及当时可用的物理资源。
