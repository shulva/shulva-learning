# BANG C 硬件模型

## Intro
寒武纪 MLU 是面向人工智能应用的领域专用处理器，针对人工智能领域常用的运算（例如卷积、池化和激活等）做了定制优化。寒武纪所建设的Cambricon BANG 异构并行计算平台如图所示：

![Cambricon BANG 异构并行计算平台](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/softwarestack.png)

寒武纪硬件支持服务器级、板卡级、芯片级、Cluster级、MLU Core 级、流水线级和 SIMD级并行。

在该编程模型下，整个计算系统会被划分为设备端和主机端，二者协同完成并行计算任务。主机端用于完成对设备资源的申请和释放，并控制设备端完成任务处理，而设备端则负责大规模的并行计算。在该编程模型下，一个完整的人工智能应用会被分解为一系列计算密集的运算核心，称为 Kernel，每个 Kernel 最终会下发到 MLU 硬件上执行。

一个Kernel 会被 MLU 硬件上的一个或者多个 MLU Core 执行，每个程序实例称为一个 Task。

基于 Cambricon BANG 异构并行计算模型编程时，用户需要进行以下操作：

1. 任务划分：将一个计算密集的计算需求分解为多个可以并行执行的独立子任务，子任务之间可以通过共享存储的方式进行数据交互，也可以通过同步原语实现同步；
    
2. 任务设置：指定用于执行计算任务的硬件资源的数量。


以下图为例，该程序具有8个任务（Task）：
- 如果底层硬件有1个 MLU Core 可用，那么8个任务会以任意顺序在同一个 MLU Core 上串行执行；
- 如果底层硬件有1个 Cluster 可用（包含 4 个 MLU Core），那么8个任务会被分为2轮迭代，每次执行4个任务；
- 如果底层硬件有2个 Cluster 可用（包含 8 个 MLU Core），那么8个任务可以被同时执行。

![Cambricon BANG 异构并行编程模型的可扩展性](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/execuationmodel.png)

## 抽象硬件模型

寒武纪硬件的基本组成单元是MLU Core。每个 MLU Core 是具备完整计算、IO和控制功能的处理器核心，可以独立完成一个计算任务，也可以与其他 MLU Core 协作完成一个计算任务。
每4个 MLU Core 核心构成一个 **Cluster**，在 MLUv02 以及后续架构中，每个 Cluster 内还会包含一个额外的 Memory Core 和一块被 Memory Core 和 4 个 MLU Core 共享的 SRAM（Shared RAM，共享存储单元）。
Memory Core 不能执行向量和张量计算指令，只能用于 SRAM 与 DDR和 MLU Core 之间的数据传输。

Cambricon BANG异构并行编程模型由通用处理器和多个 MLU 领域专用处理器组成。其中，MLU 负责核心的大规模并行计算，而通用处理器则作为控制单元，负责复杂控制和任务调度等工作。整个抽象硬件模型分为5个层级：服务器级、板卡级、芯片级、处理器簇（Cluster）级和 MLU Core 级，每个层次都包括抽象的控制单元、计算单元和存储单元，如图所示： 

- 第0级是服务器级，由多个 CPU 构成的控制单元、本地 DDR 存储单元和多个 MLU 板卡构成的计算单元组成；
    
- 第1级是板卡级，每个 MLU 板卡由本地控制单元、DDR 存储单元和 MLU 芯片构成的计算单元组成；
    
- 第2级是芯片级，每个芯片由本地控制单元、本地存储单元（例如 L2 Cache）以及一个或者多个 Cluster 构成的计算单元组成；
    
- 第3级是 Cluster 级，每个 Cluster 由本地控制单元、共享存储以及多个 MLU Core 构成的计算单元组成；
    
- 第4级是 MLU Core 级，每个 MLU Core 由本地控制单元、私有存储单元和计算单元FU组成。在 MLU Core 内部支持指令级并行和数据级并行。
![抽象硬件模型](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/hardwarehierarchy.png)


### 存储模型

抽象硬件模型提供了丰富的存储层次，包括GPR（General Purpose Register，通用寄存器）、NRAM、WRAM、SRAM、L2 Cache、LDRAM（Local DRAM，局部 DRAM 存储单元）、GDRAM（Global DRAM，全局 DRAM 存储空间）等。
**GPR、WRAM 和 NRAM 是一个 MLU Core 的私有存储，Memory Core 没有私有的 WRAM 和 NRAM 存储资源。**

L2 Cache 是芯片的全局共享存储资源，目前主要用于缓存指令、Kernel 参数以及只读数据。
LDRAM 是每个 MLU Core 和 Memory Core 的私有存储空间，其容量比 WRAM 和 NRAM 更大，主要用于解决片上存储空间不足的问题。
GDRAM 是全局共享的存储资源，可以用于实现主机端与设备端的数据共享，以及计算任务之间的数据共享。

![存储模型](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/memorymodel.png)

> [!NOTE]
> - SREG（Special Register，特殊寄存器）。
> - Cambricon BANG 异构计算平台的 MLU 侧采用小端字节序，即数据的高位字节存储在地址的高位。

#### GPR

GPR 是每个 MLU Core 和 Memory Core 私有的存储资源。MLU Core 和 Memory Core 的标量计算系统都采用精简指令集架构，所有的标量数据，无论是整型数据还是浮点数据，在参与运算之前必须先加载到 GPR。
GPR 的最大位宽为 48位，一个GPR 可以存储一个 8bit、16bit、32bit或者48bit的数据。GPR 中的数据不仅可以用来实现标量运算和控制流功能，还用于存储向量运算所需要的地址、长度和标量参数等。

GPR 不区分数据类型和位宽，GPR 中存储的数据的类型和位宽由操作对应数据的指令决定。当实际写入 GPR 中的数据的位宽小于48bit时，高位自动清零。

Cambricon BANG 异构并行编程模型中的隐式数据迁移都是借助 GPR 实现的。例如，将 GDRAM 上的标量数据赋值给一个位于 LDRAM 的变量时，编译器会自动插入访存指令将 GDRAM 中的数据先加载到 GPR 中，再插入一条访存指令将 GPR 中的数据写入 LDRAM中。

#### NRAM

NRAM 是每个 MLU Core 私有的片上存储空间，主要用来存放向量运算和张量运算的输入和输出数据，也可以用于存储一些运算过程中的临时标量数据。
相比 GDRAM 和 LDRAM 等片外存储空间，NRAM 有较低的访问延迟和更高的访问带宽。NRAM 的访存效率比较高但空间大小有限，而且不同硬件的 NRAM 容量不同。用户需要合理利用有限的 NRAM 存储空间，以提高程序的性能。
对于频繁访问的数据，应该尽量放在 NRAM 上，仅仅当 NRAM 容量不足时，才将数据临时存储在片上的 SRAM 或者片外的 LDRAM 或者 GDRAM 上。

> [!NOTE] 
> - 抽象硬件模型要求参与向量运算或者张量运算的输入数据和输出数据必须位于 NRAM 上。 
> - 位于其他存储空间的数据，在参与向量或者张量运算之前必须通过数据搬运指令显式地拷贝到 NRAM 上。 

#### WRAM

WRAM 是每个 MLU Core 私有的片上存储空间，主要用来存放卷积运算的卷积核数据。为了高效地实现卷积运算，WRAM 上的数据具有特殊的数据布局。

> [!NOTE]
> - WRAM 不支持普通的标量读写操作，只能通过数据搬移指令显式地读写 WRAM。
> - WRAM一般用于储存conv计算中的权值或是gemm计算中的右矩阵。

#### SRAM

SRAM 是一个 Cluster 内**所有 MLU Core 和 Memory Core 都可以访问**的共享存储空间。SRAM 可以用于缓存 MLU Core 的中间计算结果，实现 Cluster 内不同 MLU Core 或 Memory Core 之间的数据共享及不同 Cluster 之间的数据交互。

SRAM 有较高的访存带宽，但是容量有限。用户需要合理利用有限的 SRAM 存储空间，以提高程序的性能。

> [!NOTE] 
> - SRAM 仅支持 MLUv02 及后续硬件架构。
> - 由于 SRAM 是同一个Cluster内多个 MLU Core 共享的存储空间，每个 MLU Core 和 Memory Core 都可以自由读写 SRAM，硬件不保证所有读写操作之间的顺序，因此软件需要插入同步原语来保证数据依赖。

#### L2 cache

L2 Cache 是位于片上的全局存储空间，由硬件保证一致性，目前主要用于缓存指令、Kernel 参数以及只读数据。

> [!NOTE] 
> L2 Cache 目前对于用户透明，在 Cambricon BANG 异构并行编程模型中暂时没有提供读写 L2 Cache 的接口。

#### LDRAM

LDRAM 是每个 MLU Core 和 Memory Core 私有的存储空间，可以用于存储无法在片上存放的私有数据。
LDRAM 属于**片外存储**，不同 MLU Core 和 Memory Core 之间的LDRAM空间互相隔离，软件可以配置其容量。与GDRAM相比，LDRAM的访存性能更好，因为LDRAM的访存冲突比较少。

> [!NOTE]
> 实际编程时不推荐使用LDRAM。

#### GDRAM

与 LDRAM 类似，GDRAM 也是**片外存储**。位于 GDRAM 中的数据被所有的 MLU Core 和 Memory Core 共享。GDRAM 空间的作用之一是用来在主机侧与设备侧传递数据，如 Kernel 的输入、输出数据等。Cambricon BANG 异构编程模型提供了专门用于在主机侧和设备侧之间进行数据拷贝的接口。

### 数据一致性

Cambricon BANG异构编程模型支持显式或隐式的在不同的存储层次之间实现数据迁移。

显式数据迁移由用户通过调用对应的数据移动接口完成。

隐式数据迁移由编译器自动完成，不需要用户参与。MLU 硬件要求所有的标量计算都在 GPR 中进行，当定义在 LDRAM / GDRAM / SRAM / NRAM 上的标量参与运算时，编译器会自动插入 load 指令将数据搬移到 GPR 中，在计算完成之后再通过编译器插入的 store 指令将 GPR 上的结果写回 LDRAM / GDRAM / SRAM / NRAM。

### 访存一致性

NRAM 和 WRAM 是每个 MLU Core 的私有存储空间，因此不存在多个 MLU Core 之间的访问一致性问题。
但是在同一个 MLU Core 内部，**属于不同流的指令读写 NRAM 或者 WRAM 时**，需要软件显式插入核内同步指令以保证数据一致性；
属于同一条流的指令读写 NRAM 或者 WRAM 是顺序执行的，由硬件保证一致性。

LDRAM 是每个 MLU Core 和 Memory Core 的私有存储空间，因此不存在多个 MLU Core 之间的访存一致性问题。在同一个 MLU Core 内部，读写 LDRAM 的指令顺序执行，由硬件保证一致性。

SRAM 是由多个 MLU Core 和 Memory Core 共享的存储空间，多个 MLU Core 或者 Memory Core 可以并发地读写同一个 SRAM 地址，需要由软件插入核间同步指令来保证数据一致性。

L2 Cache 是被所有 MLU Core 和 Memory Core 共享的存储空间，由硬件保证一致性。

GDRAM 是被所有 MLU Core 和 Memory Core 共享的存储空间，多个 MLU Core 或者 Memory Core 可以并发地读写同一个 GDRAM 地址，需要软件插入核间同步指令来保证数据一致性。

## 计算模型

MLU 硬件支持服务器级、板卡级、芯片级、Cluster 级、MLU Core 级、流水线级和数据级七个维度的并行计算。
其中，服务器级和板卡级并行由具体的系统规模确定，芯片级、Cluster 级和 MLU Core 级并行由用户在主机侧配置任务规模和类型时确定，而每个 MLU Core 内部的流水线级和数据级并行计算则由用户通过对设备侧的编程来实现。

在设备侧，用户编程的主体是一个 Task，每个 Task 在具体执行时只会在一个 MLU Core 上执行，而且在执行过程中不会发生任务的切换。
每个 Cluster 可以并行执行多个 Task，每个芯片支持的 Cluster 数量不同。每个 MLU Core 都是具备控制流、标量运算和向量运算能力的处理器核心。标量运算指令和控制流指令主要用来实现控制流功能，而向量指令则用于实现并行数据处理。一条向量运算指令可以处理任意长度的数据。

在面向 Cambricon BANG 异构计算平台的抽象硬件模型中，每个 MLU 板卡由多块 MLU 芯片构成，每个 MLU 芯片由多个 Cluster 组成 ，每个 Cluster 包含多个 MLU Core、一个 Memory Core 和一块共享的 SRAM 存储单元。
一个 Kernel 的所有 Task 都在同一个 MLU 硬件上执行。同一批次，在不同的 Cluster 上执行的 Task 之间可以同步，也可以通过 GDRAM 通信。

在 MLUv02 以及后续架构中， 每个 Cluster 内部新增了1个 Memory Core。Memory Core 不具备向量和张量运算功能，只支持基本的标量运算功能。其主要功能是实现 Cluster 与 DRAM 之间、Cluster 与 Cluster之间，以及同一个 Cluster 内部多个 MLU Core 之间的通信。

### 核内并行与同步

MLU 硬件同时支持数据级并行和指令级并行。数据级并行是指一条指令中同时处理多个数据，向量指令就是典型的数据级并行。数据级并行的优点在于指令条数比较少。
MLU硬件同时提供了多条可以并行执行的流水线，分别对应不同的功能，位于不同流水线中的指令可以并行执行，从而实现不同流水线之间的指令级并行。

整个硬件系统由标量指令、向量指令、张量指令和访存指令构成。
- 标量系统是一个典型的 load-store 类型的 RISC精简指令集架构。在 MLU Core 和 Memory Core 中，标量主要用来实现控制流和一些特殊的处理功能。
- 向量指令用来实现向量运算，每条向量指令的操作数会同时包含源操作数的地址、目的操作数的地址以及向量长度。一条向量指令可以操作的数据长度是可变的，在调用对应的向量指令时，硬件会根据指令设置的向量长度进行批量处理。张量指令用于实现卷积、积分、直方图和矩阵运算。
- 张量指令可以操作的数据长度也是可变的，在调用对应的张量指令时，硬件会根据指令设置的维度信息进行批量处理。访存指令支持变长的数据传输，可以用来实现不同存储资源之间的数据搬运，从而为标量、向量和张量运算提供数据来源。

由于向量运算指令、张量指令和访存指令都可以处理规模可变的数据，因此每一条向量指令、张量指令和访存指令的执行时间也是可变的。为了避免阻塞后续无关的指令的执行，硬件提供了多条流水线，同一条流水线中的指令串行执行，不同流水线中的指令并行执行。
硬件同时提供了同步指令用于在需要维持依赖的位置实现同步。为了实现 MLU Core 内向量/张量计算和 IO 的延迟隐藏，用户应当合理安排向量/张量运算和访存指令的执行顺序。尽量通过指令调度或者重排来减少同步指令对不同流的打断，并且减少流之间的数据依赖。

MLU Core 有4条指令流水线，分别是 **IO 流、Move 流、Compute 流和 Scalar 流**。所有涉及读写片外 DDR 的指令都在 IO 流中执行，不会读写片外 DDR 的访存指令都在 Move 流中执行，张量和向量计算指令都在 Compute 流中执行，所有标量指令都在 Scalar 流中执行。
所有指令流水线都是可以并行工作的，IO 流、Move 流、Compute 流和 Scalar 流默认是并行执行的，但是硬件会保证 Scalar 流与其他流之间的寄存器依赖。例如：如果有 IO 流、Move 流或者 Compute 流的指令修改标量通用寄存器时，硬件会保证 Scalar 流中读对应寄存器的指令必须在其他流的指定执行完成后才能开始执行；同理，当 Scalar 流中的指令修改寄存器时，其他流中需要读取对应寄存器的指令也需要等待 Scalar 流的写操作执行完毕才能执行。

Memory Core 可以看成是裁剪版的 MLU Core，只有3条指令流水线：Move 流、IO 流和 Scalar 流。不同的指令流也是可以并行工作的，由硬件保证 Scalar 流与其他流之间的寄存器依赖。

硬件只保证**不同的指令流之间的寄存器依赖**，其他依赖关系需要由用户插入核内同步指令来保证。以如下指令序列为例介绍指令流之间的依赖关系：

```cpp
offset = __load_gdram(ptr);                      // ld.gpr.gdram r0, [r0], 6;
addr = base + offset;                            // add.gpr.s48 r2, r0, 512;
__bang_write_value(dst, 128, 0.0f);              // writezero.nram.f32 [r1], 128;
__sync();                                        // sync;
__memcpy_async(gdram, addr, 512, NRAM2GDRAM);    // st.async.gdram.nram [r2], [r1], 512;
__memcpy_async(sram, dst, 512, NRAM2SRAM);       // st.async.sram.nram [r3], [r1], 512;
```

如图所示，MLU Core 硬件将指令队列中的上述指令序列根据指令类型发射到不同的执行队列。
![多队列间数据依赖和同步](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/pipeline.png)


