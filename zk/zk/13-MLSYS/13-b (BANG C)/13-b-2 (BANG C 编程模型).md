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

## Task规模

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

## 任务类型
