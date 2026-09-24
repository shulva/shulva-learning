# CNRT 和 CNDrv 的使用

CNRT（Cambricon Runtime Library）和 CNDrv（Cambricon Driver API）提供设备管理、内存管理、任务队列管理、设备端程序执行和通知管理等功能。使用 Cambricon BANG C 编写的程序，需要通过 CNRT 或 CNDrv 才能在 MLU 设备上运行。

## CNRT 与 CNDrv

CNRT 是 CNDrv 的上层封装，主要目标是简化编程；CNDrv 是 Driver 的上层封装，提供更细粒度的控制。

![CNRT、CNDrv 与 Driver 的关系](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/relationship_of_cnrt_and_cndrv.png)

| 运行时 | 特点 | 适用场景 |
| --- | --- | --- |
| CNRT | 自动管理 Context、Kernel 和 Module，接口更简单 | 常规 BANG C 程序 |
| CNDrv | 可以显式切换 Context，并控制 Kernel、Module 的加载和卸载 | 需要精细资源控制的程序 |

CNRT 和 CNDrv 的许多接口可以互换，也支持混合调用：

- 如果已经通过 CNDrv 创建并设置了当前 Context，后续 CNRT API 会复用该 Context；
- 如果 CNRT 已经完成初始化，可以使用 `cnCtxGetCurrent` 获取 CNRT 创建的 Shared Context，供后续 CNDrv API 使用；
- 设备内存、Queue 和 Notifier 可以分别通过 CNRT 或 CNDrv 创建，再通过另一套接口释放或销毁；
- 两者的设备管理和版本管理接口可以互换使用。

```cpp
CNaddr device_ptr;
CNqueue queue;
CNnotifier notifier;

cnMalloc(&device_ptr, bytes);
cnQueueCreate(&queue, 0);
cnNotifierCreate(&notifier, 0);

cnrtFree((void *)device_ptr);
cnrtQueueDestroy((cnrtQueue_t)queue);
cnrtNotifierDestroy((cnrtNotifier_t)notifier);
```

## 初始化

### CNRT 初始化

CNRT 没有显式初始化函数，在第一次调用 CNRT API 时进行隐式初始化。初始化分为三个阶段：

1. 初始化运行环境，此阶段不申请设备资源；
2. 创建并激活 Shared Context；
3. 加载 Kernel Module，并申请用于保存 Kernel 指令和运行数据的设备资源。

![CNRT 初始化流程](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/cnrt_init.png)

第一次调用的 API 不同，初始化程度也不同：

- 版本查询等 API 不需要设备资源，不会激活 Shared Context；
- `cnrtMalloc`、`cnrtQueueCreate` 等资源类 API 会激活 Shared Context，并触发 Kernel Module 加载；
- `cnrtSetDevice` 只设置当前线程使用的设备，其创建的 Shared Context 仍未激活，不能立即供 CNDrv 资源类 API 使用。

可以调用一个不实际释放资源的接口来激活 Shared Context：

```cpp
#include "cnrt.h"
#include "cn_api.h"

int main(void) {
  cnrtSetDevice(0);

  unsigned int ctx_flag = 0;
  int ctx_state = 0;
  cnSharedContextGetState(0, &ctx_flag, &ctx_state);

  cnrtFree((void *)0);  // 激活 Shared Context
  cnSharedContextGetState(0, &ctx_flag, &ctx_state);
  return 0;
}
```

> [!NOTE]
> CNRT 会为每个 MLU 设备创建一个由所有主机线程共享的 Shared Context。调用 `cnrtDeviceReset` 会销毁基于当前 Shared Context 申请的资源；后续再次调用需要激活 Context 的 CNRT API 时，Shared Context 会重新激活。

Kernel Module 的加载时机如下：

- Kernel 直接链接到可执行程序时，在第一个使用设备资源的 CNRT API 处加载；
- Kernel 通过 `dlopen` 加载时，在 `dlopen` 之后第一个使用设备资源的 CNRT API 处加载；
- 多次调用 `dlopen` 时，每次调用后的第一个 CNRT API 会加载此前尚未加载的 Module。

### CNDrv 初始化

CNDrv 必须显式调用 `cnInit` 初始化运行环境。该接口可以在进程开始时调用，也可以在每个线程开始时调用，但必须先于其他 CNDrv API。

```cpp
cnInit(0);
```

## 设备管理

在多卡系统中，执行设备端程序前需要先选择目标 MLU。

| API | 功能 |
| --- | --- |
| `cnrtGetDeviceCount` | 获取本机 MLU 设备数量 |
| `cnrtSetDevice` | 设置当前线程即将使用的 MLU 设备 |
| `cnrtGetDevice` | 获取当前使用的设备 |
| `cnrtDeviceGetAttribute` | 获取设备属性 |
| `cnrtDeviceReset` | 重置设备并释放相关资源 |
| `cnrtSyncDevice` | 等待设备上的任务执行完成 |

```cpp
unsigned int device_count = 0;
cnrtGetDeviceCount(&device_count);

if (device_count > 0) {
  cnrtSetDevice(0);
}
```

## 设备内存管理

主机内存和设备内存是两个独立的内存系统。Kernel 访问设备内存，`cnrtMalloc` 返回的设备侧连续虚拟地址可以在不同 Kernel 之间传递。

```cpp
void *device_ptr = NULL;
cnrtMalloc(&device_ptr, bytes);
// 使用 device_ptr
cnrtFree(device_ptr);
```

> [!NOTE]
> MLU 加速卡和 CE 边缘计算平台的设备虚拟地址位宽均为 64 bit。

### 同步与异步拷贝

| API | 特点 |
| --- | --- |
| `cnrtMemcpy` | 同步拷贝，支持 H2D、D2H、D2D 和 H2H |
| `cnrtMemcpyAsync` | 异步拷贝，适合较大的数据量，支持 H2D、D2H 和 D2D |

异步拷贝进入指定 Queue，主机线程可以继续执行其他工作；如果数据拷贝和计算位于不同 Queue，二者可以重叠执行。

> [!NOTE]
> - 异步拷贝使用的设备内存和 Queue 必须属于同一个 Context；
> - Queue 同步完成前，不得释放参与异步拷贝的主机地址或设备地址；
> - 异步接口传入普通可分页 Host 内存时，可能退化为同步行为。需要稳定的异步行为和更高带宽时，应使用页锁定 Host 内存。

下面的示例完成 Host 到 Device 的数据拷贝，并在 MLU 上执行一次标量加法：

```cpp
#include "bang.h"

__mlu_global__ void scalar_add(float *x, float *y) {
  *y = *x + *y;
}

int main(void) {
  float *d0 = NULL;
  float *d1 = NULL;
  const size_t bytes = sizeof(float);

  cnrtMalloc((void **)&d0, bytes);
  cnrtMalloc((void **)&d1, bytes);

  float h0 = 1.0f;
  float h1 = 2.0f;
  cnrtMemcpy(d0, &h0, bytes, cnrtMemcpyHostToDev);
  cnrtMemcpy(d1, &h1, bytes, cnrtMemcpyHostToDev);

  cnrtDim3_t dim = {1, 1, 1};
  cnrtFunctionType_t type = CNRT_FUNC_TYPE_BLOCK;
  cnrtQueue_t queue;
  cnrtQueueCreate(&queue);

  scalar_add<<<dim, type, queue>>>(d0, d1);
  cnrtQueueSync(queue);
  cnrtMemcpy(&h1, d1, bytes, cnrtMemcpyDevToHost);

  cnrtFree(d0);
  cnrtFree(d1);
  cnrtQueueDestroy(queue);
  return 0;
}
```

示例代码位于：

```text
samples/BANG/0_Concepts_and_Techniques/scalarAdd
```

### 二维内存拷贝

`cnrtMemcpy2D` 用于带步长的二维拷贝和一维、二维数据之间的转换：

```cpp
cnrtRet_t cnrtMemcpy2D(void *dst, size_t dpitch,
                       const void *src, size_t spitch,
                       size_t width, size_t height,
                       cnrtMemTransDir_t dir);
```

- 每次从源地址读取 `width` 字节，然后源地址增加 `spitch`；
- 每次向目标地址写入 `width` 字节，然后目标地址增加 `dpitch`；
- 上述过程循环 `height` 次，总搬运量为 `width * height`。

> [!NOTE]
> - `dpitch` 和 `spitch` 不能小于 `width`；
> - `width` 和 `height` 不能大于 1 MB；
> - `dpitch` 和 `spitch` 不能大于 4 MB；
> - 总搬运量 `width * height` 不能大于 16 MB。

一维和二维之间的转换只需调整 pitch：

- 二维转一维：令 `dpitch == width`，源地址按 `spitch` 跳变读取；
- 一维转二维：令 `spitch == width`，目标地址按 `dpitch` 跳变写入；
- 二维转二维：根据源、目标布局分别设置 `spitch` 和 `dpitch`。

二维转一维时，从 4 行、每行跨度 16 B 的源内存中提取每行前 8 B，并在目标内存中连续存放：

![二维内存转一维内存](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/memcpy_2d_to_1d.png)

```cpp
size_t dpitch = 0x8;   // 等于 width，目标连续写入
size_t spitch = 0x10;  // 源内存每行跨度
size_t width = 0x8;
size_t height = 0x4;
cnrtMemcpy2D(dst, dpitch, src, spitch,
             width, height, cnrtMemcpyDevToDev);
```

一维转二维时，连续读取 32 B，并将其写为 4 行、每行有效数据 8 B、行跨度 16 B 的二维数据：

![一维内存转二维内存](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/memcpy_1d_to_2d.png)

```cpp
size_t dpitch = 0x10;  // 目标内存每行跨度
size_t spitch = 0x8;   // 等于 width，源连续读取
size_t width = 0x8;
size_t height = 0x4;
cnrtMemcpy2D(dst, dpitch, src, spitch,
             width, height, cnrtMemcpyDevToDev);
```

二维转二维常用于图层叠加。源、目标使用相同布局时，可以令 `spitch == dpitch`：

![二维内存拷贝](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/memcpy_2d_to_2d.png)

```cpp
size_t dpitch = 0x10;
size_t spitch = 0x10;
size_t width = 0x8;
size_t height = 0x4;
cnrtMemcpy2D(dst, dpitch, src, spitch,
             width, height, cnrtMemcpyDevToDev);
```

示例代码位于：

```text
samples/cnrt/basic/6_memcpy2D3D
```

### 三维内存拷贝

`cnrtMemcpy3D` 使用 `cnrtMemcpy3dParam_t` 描述源、目标 pitch、平面跨度和三维搬运范围：

```cpp
cnrtMemcpy3dParam_t p = {0};
p.srcPtr.ptr = src;
p.srcPtr.pitch = src_pitch;
p.srcPtr.ysize = src_ysize;
p.dstPtr.ptr = dst;
p.dstPtr.pitch = dst_pitch;
p.dstPtr.ysize = dst_ysize;
p.extent.width = width;
p.extent.height = height;
p.extent.depth = depth;

cnrtMemcpy3D(&p);
```

> [!NOTE]
> - 源、目标 pitch 不能小于 `extent.width`；
> - 源、目标 `ysize` 不能小于 `extent.height`；
> - `extent.width` 和 `extent.height` 不能大于 1 MB；
> - pitch 不能大于 4 MB；
> - 总搬运量 `width * height * depth` 不能大于 16 MB。

三维转一维时，可以从三维源内存中提取一个 `4 × 4 × 4` 子块，并在目标内存中连续存放：

![三维内存转一维内存](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/memcpy_3d_to_1d.png)

```cpp
p.srcPtr.pitch = 0x8;
p.srcPtr.xsize = 0x4;
p.srcPtr.ysize = 0x8;
p.dstPtr.pitch = 0x4;
p.dstPtr.xsize = 0x4;
p.dstPtr.ysize = 0x4;
p.extent.width = 0x4;
p.extent.height = 0x4;
p.extent.depth = 0x4;
```

一维转三维时使用相反的布局，将连续的 64 B 数据写入 `4 × 4 × 4` 的三维区域：

![一维内存转三维内存](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/memcpy_1d_to_3d.png)

```cpp
p.srcPtr.pitch = 0x4;
p.srcPtr.xsize = 0x4;
p.srcPtr.ysize = 0x4;
p.dstPtr.pitch = 0x8;
p.dstPtr.xsize = 0x4;
p.dstPtr.ysize = 0x8;
p.extent.width = 0x4;
p.extent.height = 0x4;
p.extent.depth = 0x4;
```

三维转三维可以从一个 `8 × 8 × 8` 立方体中提取 `4 × 4 × 4` 的子立方体：

![三维内存拷贝](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/memcpy_3d_to_3d.png)

```cpp
p.srcPtr.pitch = 0x8;
p.srcPtr.xsize = 0x4;
p.srcPtr.ysize = 0x8;
p.dstPtr.pitch = 0x8;
p.dstPtr.xsize = 0x4;
p.dstPtr.ysize = 0x8;
p.extent.width = 0x4;
p.extent.height = 0x4;
p.extent.depth = 0x4;
```

以上三种情况配置好 `p.srcPtr.ptr`、`p.dstPtr.ptr` 和 `p.dir` 后，均通过下列接口执行：

```cpp
cnrtMemcpy3D(&p);
```

### 云侧 NUMA 内存

部分加速卡使用 NUMA 管理设备内存。可以通过 `cnDeviceGetAttribute` 查询设备的 NUMA node 数量，并通过 `cnMallocNode` 在指定 node 上申请内存。

```cpp
int node_count = 0;
CNdev device;
cnDeviceGet(&device, 0);
cnDeviceGetAttribute(&node_count,
                     CN_DEVICE_ATTRIBUTE_GLOBAL_MEMORY_NODE_COUNT,
                     device);

CNaddr device_ptr;
cnMallocNode(&device_ptr, bytes, node_id);
```

### CE 平台内存与缓存一致性

CE 平台的物理内存分为 OS 可见内存和由 CNRT 管理的设备内存。CPU 访问内存时会经过 Cache，MLU Core、JPU 和 VPU 等设备则直接访问物理内存，因此 CPU 和设备交替访问同一内存时需要维护缓存一致性。

![CE 边缘计算内存架构](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/cndrv_memory_arch.png)

如果设备更新了物理内存，而 CPU Cache 中对应的旧缓存行仍然有效，CPU 随后可能读到旧数据：

![缓存一致性错误示例](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/cndrv_memory_err_sample.png)

CPU 与设备交替访问映射内存时，需要在正确的边界执行缓存同步：

![缓存一致性维护](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/cndrv_memory_access.png)

访问规则可以概括为：

- CPU 写入后、设备读取前，需要将 CPU Cache 的数据同步到物理内存；
- 设备写入后、CPU 读取前，需要使对应 CPU Cache 失效或重新同步；
- 缓存维护的最小单位是 Cache Line，CE 平台为 64 字节，即使 CPU 和设备访问同一 Cache Line 内互不重叠的区域，也需要维护一致性。

CE 平台设备内存的常用接口：

| API | 功能 |
| --- | --- |
| `cnrtMalloc` / `cnrtFree` | 申请和释放设备内存 |
| `cnrtMmap` | 映射为无缓存属性的 Host 地址 |
| `cnrtMmapCached` | 映射为有缓存属性的 Host 地址 |
| `cnrtMunmap` | 解除 Host 地址映射 |
| `cnrtMcacheOperation` | 对映射内存进行 Cache 同步操作 |
| `cnrtPointerGetAttributes` | 查询指针对应的内存属性 |
| `cnrtMemGetInfo` | 查询设备内存使用信息 |

旧版 CE 内存接口与当前替代接口的对应关系：

| 旧版 API                                                            | 新版替代 API                                       |
| ----------------------------------------------------------------- | ---------------------------------------------- |
| `cnrtCacheOperation(host_ptr, op)`                                | `cnrtMcacheOperation(ptr, hostPtr, size, ops)` |
| `cnrtCacheOperationRange(host_ptr, size, op)`                     | `cnrtMcacheOperation(ptr, hostPtr, size, ops)` |
| `cnrtFindDevAddrByMappedAddr(mapped_host_ptr, dev_ptr)`           | `cnrtPointerGetAttributes(attr, ptr)`          |
| `cnrtFindDevAddrWithOffsetByMappedAddr(mapped_host_ptr, dev_ptr)` | `cnrtPointerGetAttributes(attr, ptr)`          |
| `cnrtGetMemInfo(free, total, channel)`                            | `cnrtMemGetInfo(free, total)`                  |
| `cnrtGetMemorySize(devBasePtr, devPtr, bytes)`                    | `cnrtPointerGetAttributes(attr, ptr)`          |
| `cnrtMap(host_ptr, dev_ptr)`                                      | `cnrtMmapCached(ptr, pHostPtr, size)`          |
| `cnrtMapRange(host_ptr, dev_ptr, size)`                           | `cnrtMmapCached(ptr, pHostPtr, size)`          |
| `cnrtUnmap(host_ptr)`                                             | `cnrtMunmap(hostPtr, size)`                    |
|                                                                   |                                                |

> [!NOTE]
> - 建议先使用 `cnrtMmap` 验证功能，再使用 `cnrtMmapCached` 优化性能；
> - 不要对同一段设备内存反复映射，这会增加合法性检查开销、消耗系统内存，并可能达到系统映射次数上限；
> - 释放映射过的设备内存前，应先调用 `cnrtMunmap` 解映射；
> - `cnrtFree` 不能释放系统内存或映射得到的 Host 地址。

## L2 Cache 管理

当前版本 CNDrv 不向用户开放 L2 Cache 管理功能，仅允许内部基础软件平台使用该资源。

## 主机侧页锁定内存

CNRT 提供页锁定（Page-Locked）Host 内存管理接口：

| API | 功能 |
| --- | --- |
| `cnrtHostMalloc` | 申请页锁定 Host 内存 |
| `cnrtFreeHost` | 释放页锁定 Host 内存 |
| `cnrtAcquireMemHandle` | 获取用于进程间共享的内存句柄 |
| `cnrtMapMemHandle` | 在另一进程中映射共享内存句柄 |
| `cnrtUnMapMemHandle` | 解除进程间共享内存映射 |

页锁定内存的优点：

- 页锁定 Host 内存和设备内存之间的异步拷贝可以与 Kernel 并行；
- 拷贝前不需要临时锁页，带宽通常高于普通可分页 Host 内存；
- 与设备交互时通常能够获得更稳定的性能。

```cpp
void *host_ptr = NULL;
void *device_ptr = NULL;

cnrtHostMalloc(&host_ptr, bytes);
cnrtMalloc(&device_ptr, bytes);
cnrtMemcpyAsync(device_ptr, host_ptr, bytes,
                queue, cnrtMemcpyHostToDev);
cnrtQueueSync(queue);

cnrtFree(device_ptr);
cnrtFreeHost(host_ptr);
```

> [!WARNING]
> 页锁定内存会占用主机物理内存，是较稀缺的系统资源。大量使用会提高分配失败概率，并降低操作系统整体性能。

## 虚拟内存管理

`cnrtMalloc` 类似于设备侧的 `malloc`，但没有对应的 `realloc`。CNDrv 的虚拟内存管理接口将虚拟地址与物理内存解耦，可以分别管理、映射和解映射，从而实现：

- 将不同设备上的物理内存放入一段连续虚拟地址；
- 按需扩展虚拟地址背后的物理内存；
- 选择特定的物理内存类型，例如可压缩内存；
- 控制每段虚拟地址的访问权限。

使用前需要确认设备支持虚拟地址管理：

```cpp
int support_vmm = 0;
cnDeviceGetAttribute(&support_vmm,
                     CN_DEVICE_ATTRIBUTE_VIRTUAL_ADDRESS_MANAGEMENT_SUPPORTED,
                     device);
```

虚拟内存管理的基本流程如下：

1. 使用 `cnMemGetAllocationGranularity` 查询分配粒度；
2. 使用 `cnMemCreate` 申请物理内存，得到 `CNmemGenericAllocationHandle`；
3. 使用 `cnMemAddressReserve` 预留虚拟地址区间；
4. 使用 `cnMemMap` 将物理内存映射到虚拟地址；
5. 使用 `cnMemSetAccess` 设置读写权限；
6. 使用完成后解除映射，释放物理内存和虚拟地址区间。

```cpp
CNmemAllocationProp prop = {0};
prop.type = CN_MEM_ALLOCATION_TYPE_DEFAULT;
prop.location.type = CN_MEM_LOCATION_TYPE_DEVICE;
prop.location.id = device_id;

size_t granularity = 0;
cnMemGetAllocationGranularity(&granularity, &prop,
                              CN_MEM_ALLOC_GRANULARITY_MINIMUM);
size_t aligned_size = ROUND_UP(bytes, granularity);

CNmemGenericAllocationHandle handle;
cnMemCreate(&handle, aligned_size, &prop, 0);

CNaddr address;
cnMemAddressReserve(&address, aligned_size, 0, 0, 0);
cnMemMap(address, aligned_size, 0, handle, 0);

CNmemAccessDesc access = {0};
access.accessFlags = CN_MEM_ACCESS_FLAGS_PROT_READWRITE;
access.location.type = CN_MEM_LOCATION_TYPE_DEVICE;
access.location.id = device_id;
cnMemSetAccess(address, aligned_size, &access, 1);
```

> [!NOTE]
> - `cnMemCreate` 返回的物理内存句柄不能被 Kernel 直接访问，必须先映射到预留的虚拟地址并设置访问权限；
> - 物理内存和虚拟地址可以多次映射、解映射，但不能在已经映射的区间上重复映射；
> - `cnMemMap` 当前要求 `offset == 0`，且单次映射长度等于传入 handle 的大小；
> - 释放虚拟地址前，必须先解除其中的所有物理内存映射。

同一块物理内存可以映射到多个虚拟地址，但不同别名之间的读写顺序需要由 Queue 或 Notifier 显式保证，否则结果未定义。

## 线性设备内存

普通设备虚拟地址需要经过页表翻译后才能访问物理内存；当访问范围很大且模式离散时，地址翻译缓存可能无法覆盖全部映射。线性设备内存访问不需要页表翻译，可以改善离散访问和跨设备异步拷贝的性能稳定性。

使用前先查询设备是否支持：

```cpp
int support_linear = 0;
cnDeviceGetAttribute(&support_linear,
                     CN_DEVICE_ATTRIBUTE_LINEAR_MAPPING_SUPPORTED,
                     device);
```

`cnrtMalloc`、`cnMalloc` 和 `cnZmalloc` 有机会返回线性设备内存，但不保证一定成功。可以查询内存属性确认：

```cpp
void *device_ptr = NULL;
int is_linear = 0;

cnrtMalloc(&device_ptr, bytes);
cnGetMemAttribute(&is_linear,
                  CN_MEM_ATTRIBUTE_ISLINEAR,
                  device_ptr);
```

高效使用建议：

- 尽量一次申请业务所需的全部设备内存，减少碎片；
- 读取 `CN_DEVICE_ATTRIBUTE_LINEAR_RECOMMEND_GRANULARITY`，按设备推荐粒度对齐较大的申请；
- 小于推荐粒度的申请尽量按照 2 的幂次对齐；
- 不应假设线性内存一定能够分配成功，需要准备普通设备内存的回退路径。

> [!WARNING]
> 线性设备内存资源紧张，分配结果会受到申请顺序、规模、其他进程和 ECC 故障页下线的影响。访问线性内存时硬件不再检查非法访问，越界和内存踩踏问题也更难定位。

## 异步并行执行

底层软件支持以下任务相互独立地并行执行：

- Host 计算；
- Device 计算；
- Host 到 Device 拷贝；
- Device 到 Host 拷贝；
- Device 之间的拷贝。

Kernel 启动、设备内拷贝、带 `Async` 后缀的内存拷贝和异步 Memset 都可以相对 Host 异步执行。多个 Kernel 能否并发取决于任务规模和硬件资源，可以通过 `cnGetCtxMaxParallelUnionTask` 查询当前 Context 能够并发执行的 Union Task 数量。

同一 Queue 中的任务遵循 FIFO，只能按顺序执行；不同 Queue 中的任务可以并发。例如，将拷贝和 Kernel 放到不同 Queue，可以由 DMA 和 MLU Core 并行执行。

## Queue

Queue 管理异步任务的执行顺序。同一 Queue 中的操作按提交顺序执行，不同 Queue 之间不保证顺序，可以并行。

```cpp
cnrtQueue_t queues[2];
cnrtQueueCreate(&queues[0]);
cnrtQueueCreate(&queues[1]);

for (int i = 0; i < 2; ++i) {
  cnrtMemcpyAsync(input + i * size,
                  host + i * size,
                  size, queues[i], cnrtMemcpyHostToDev);
  Kernel<<<dim, type, queues[i]>>>(output + i * size,
                                   input + i * size);
  cnrtMemcpyAsync(host + i * size,
                  output + i * size,
                  size, queues[i], cnrtMemcpyDevToHost);
}

cnrtQueueSync(queues[0]);
cnrtQueueSync(queues[1]);
cnrtQueueDestroy(queues[0]);
cnrtQueueDestroy(queues[1]);
```

每个 Queue 内部执行 `H2D → Kernel → D2H`，两个 Queue 之间可以重叠，从而隐藏一部分拷贝和计算延迟。

### Default Queue

Queue 参数省略或传入 `0` 时使用默认 Queue。每个设备、每个 Host 线程都有自己的默认 Queue，其行为与普通 Queue 相同，但由运行时自动创建和销毁，不能调用 `cnrtQueueDestroy` 销毁。

### 同步与查询

| API | 功能 |
| --- | --- |
| `cnrtSyncDevice` | 等待所有设备上的所有 Queue 完成 |
| `cnrtQueueSync` | 阻塞等待指定 Queue 中的全部任务完成 |
| `cnrtQueueQuery` | 非阻塞查询 Queue 状态；完成返回 `cnrtSuccess`，否则返回 `cnrtErrorNotReady` |
| `cnrtQueueWaitNotifier` | 让 Queue 中后续任务等待指定 Notifier |

`cnrtQueueSync(0)` 和 `cnrtQueueQuery(0)` 可以操作默认 Queue。

### 同步行为

调用 `cnrtSetDeviceFlag` 可以选择同步等待策略：

| 模式 | 行为 | 适用场景 |
| --- | --- | --- |
| `cnrtDeviceScheduleSpin` | CPU 循环查询，性能较高但占用 CPU | 云侧或性能优先 |
| `cnrtDeviceScheduleBlock` | 阻塞等待，降低 CPU 占用但性能略低 | 端侧或 CPU 资源优先 |
| `cnrtDeviceScheduleYield` | 等待时主动让出 CPU | 多线程且需要调度公平性 |

云侧默认使用 Spin，端侧默认使用 Block。

### Queue 优先级

可以查询设备支持的优先级范围，并创建带优先级的 Queue。高优先级 Queue 中的待处理任务优先于低优先级 Queue。

```cpp
int priority_lowest = 0;
int priority_highest = 0;
cnrtDeviceGetQueuePriorityRange(&priority_lowest, &priority_highest);

cnrtQueue_t queue_high;
cnrtQueue_t queue_low;
cnrtQueueCreateWithPriority(&queue_high, 0, priority_highest);
cnrtQueueCreateWithPriority(&queue_low, 0, priority_lowest);
```

> [!WARNING]
> 如果 Queue 中仍有未执行或正在执行的任务，调用 `cnrtQueueDestroy` 会立即返回并销毁未执行任务或打断正在执行的任务。销毁前应先同步 Queue。

## Notifier

Notifier 用于记录 Queue 中某个时刻之前的任务状态，可以完成 Host 等待、多 Queue 同步和执行时间统计。Notifier 自身不执行硬件计算。

| API | 功能 |
| --- | --- |
| `cnrtNotifierCreate` | 创建 Notifier |
| `cnrtNotifierDestroy` | 销毁 Notifier |
| `cnrtPlaceNotifier` | 在 Queue 中放置 Notifier，记录此前未完成的任务 |
| `cnrtQueueWaitNotifier` | 让另一个 Queue 等待 Notifier |
| `cnrtWaitNotifier` | 阻塞 Host，等待 Notifier 记录的任务完成 |
| `cnrtQueryNotifier` | 查询 Notifier 记录的任务是否完成 |
| `cnrtNotifierElapsedTime` | 计算两个 Notifier 之间的时间，单位为毫秒 |
| `cnrtIpcGetNotifierHandle` | 获取 Notifier 的 IPC 句柄 |
| `cnrtIpcOpenNotifierHandle` | 从 IPC 句柄创建 Notifier |

使用两个 Notifier 统计 Kernel 时间：

```cpp
cnrtNotifier_t start;
cnrtNotifier_t end;
cnrtNotifierCreate(&start);
cnrtNotifierCreate(&end);

cnrtPlaceNotifier(start, queue);
Kernel<<<dim, type, queue>>>(...);
cnrtPlaceNotifier(end, queue);
cnrtQueueSync(queue);

float elapsed_ms = 0.0f;
cnrtNotifierElapsedTime(start, end, &elapsed_ms);

cnrtNotifierDestroy(start);
cnrtNotifierDestroy(end);
```

使用 Notifier 建立多 Queue 依赖：

```cpp
cnrtPlaceNotifier(notifier, queue_a);
cnrtQueueWaitNotifier(notifier, queue_b, 0);
// queue_b 中后续提交的任务会等待 queue_a 中 notifier 之前的任务完成
```

> [!NOTE]
> - `cnrtPlaceNotifier` 使用的 Queue 和 Notifier 必须属于同一个 Context；
> - 多次放置同一个 Notifier 时，它只保留最后一次记录的 Queue 状态；
> - Notifier 只记录任务是否完成，不记录任务是否成功；
> - 使用 `CNRT_NOTIFIER_DISABLE_TIMING_ALL` 创建的 Notifier 不能用于计时；
> - 计算时间时需要保证 start 和 end 的先后顺序，否则结果可能为负。

## 错误检查

| API | 功能 |
| --- | --- |
| `cnrtGetErrorName` | 获取错误码对应的错误名称 |
| `cnrtGetErrorStr` | 获取错误码对应的错误说明 |
| `cnrtGetLastError` | 获取最近一次错误并将状态重置为 `cnrtSuccess` |
| `cnrtPeekAtLastError` | 获取最近一次错误但不重置状态 |

```cpp
cnrtRet_t ret = cnrtMalloc(&device_ptr, bytes);
if (ret != cnrtSuccess) {
  fprintf(stderr, "%s: %s\n",
          cnrtGetErrorName(ret),
          cnrtGetErrorStr(ret));
}
```

## TaskTopo

TaskTopo 将一组异步任务及其依赖关系打包成任务图，实现任务流一次定义、多次执行。将构图和执行分开可以降低重复下发时的 CPU 负载，并让运行时获得全局任务信息进行优化。

| 术语 | 含义 |
| --- | --- |
| TaskTopo | 任务图，包含任务节点和节点间的依赖关系 |
| TaskTopoEntity | 实体图，某一时刻任务图的可执行快照 |
| TaskTopoNode | 任务节点，包含任务类型、参数和依赖关系 |

TaskTopo 的使用分为三个阶段：

1. 构建：描述节点操作和依赖关系，生成 TaskTopo；
2. 实例化：检查任务图并完成资源准备，生成 TaskTopoEntity；
3. 执行：将实体图下发到任意 Queue，可以重复执行。

![TaskTopo 的编程模型](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/graphviz-dcaed8413caab449b1626ec68d37a7fd309d7275.png)

```cpp
cnrtTaskTopo_t topo;
cnrtTaskTopoEntity_t entity;

cnrtTaskTopoCreate(&topo, 0);
// 添加节点并建立依赖关系
cnrtTaskTopoInstantiate(&entity, topo, NULL, NULL, 0);

cnrtTaskTopoDestroy(topo);  // 不影响已经生成的 entity
cnrtTaskTopoEntityInvoke(entity, queue0);
cnrtTaskTopoEntityInvoke(entity, queue1);
```

### 节点类型

| 节点类型            | 作用                                |
| --------------- | --------------------------------- |
| KernelNode      | Kernel 任务                         |
| HostFuncNode    | CPU 函数任务                          |
| AsyncMemcpyNode | 异步内存拷贝，目前只支持 1D                   |
| AsyncMemsetNode | 异步内存初始化，目前只支持 1D                  |
| EmptyNode       | 空节点，可作为多个依赖的汇合点                   |
| ChildNode       | 子图节点，将一个 TaskTopo 嵌套到另一个 TaskTopo |

![TaskTopo 子任务图](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/graphviz-a4571198d9d561130e0bc1c99a076df2325ad821.png)

图中 TaskTopo B 是独立的任务图，同时也作为 TaskTopo A 中的 ChildNode。

> [!NOTE]
> AsyncMemcpyNode 使用的 Host 地址必须是页锁定内存，否则可能导致性能下降或执行失败。`cnrtTaskTopo_t` 的访问和修改不是线程安全的，多线程操作时需要加锁。

### 直接构造任务图

TaskTopo 的主要构造与查询接口如下：

| API | 作用 |
| --- | --- |
| `cnrtTaskTopoCreate` | 创建任务图 |
| `cnrtTaskTopoDestroy` | 销毁任务图及其中的节点和边 |
| `cnrtTaskTopoAdd<TYPE>Node` | 添加指定类型的任务节点，并可同时指定前置依赖 |
| `cnrtTaskTopoDestroyNode` | 删除节点以及与该节点关联的边 |
| `cnrtTaskTopo<TYPE>NodeGetParams` / `SetParams` | 获取或修改节点参数 |
| `cnrtTaskTopoNodeGetDependencies` | 获取依赖该节点的后继节点 |
| `cnrtTaskTopoNodeGetDependentNodes` | 获取该节点依赖的前序节点 |
| `cnrtTaskTopoAddDependencies` | 添加节点之间的依赖边 |
| `cnrtTaskTopoRemoveDependencies` | 删除节点之间的依赖边 |
| `cnrtTaskTopoNodeGetType` | 获取节点类型 |
| `cnrtTaskTopoGetEdges` | 获取任务图中的全部依赖边 |
| `cnrtTaskTopoGetNodes` | 获取任务图中的全部节点 |
| `cnrtTaskTopoGetRootNodes` | 获取所有入度为 0 的根节点 |
| `cnrtTaskTopoClone` | 复制任务图，生成生命周期独立的快照 |
| `cnrtTaskTopoNodeFindInClone` | 查找原节点在复制图中的对应节点 |

原文示例构造了 `A → {B, C} → D`，以及 `{C, D} → E` 的依赖关系：

![使用 TaskTopo API 构造任务图](https://www.cambricon.com/docs/sdk_1.15.0/cntoolkit_3.7.2/programming_guide_1.7.0/_images/graphviz-8d79a3b5f25c611fcb26cd9cd20316d0fd691ae7.png)

```cpp
cnrtTaskTopo_t topo;
cnrtTaskTopoNode_t a;
cnrtTaskTopoNode_t b;
cnrtTaskTopoNode_t c;

cnrtTaskTopoCreate(&topo, 0);
cnrtTaskTopoAddKernelNode(&a, topo, NULL, 0, &params_a);
cnrtTaskTopoAddKernelNode(&b, topo, NULL, 0, &params_b);
cnrtTaskTopoAddKernelNode(&c, topo, NULL, 0, &params_c);

cnrtTaskTopoAddDependencies(topo, &a, &b, 1);  // A -> B
cnrtTaskTopoAddDependencies(topo, &a, &c, 1);  // A -> C
```

### QueueCapture

QueueCapture 可以在基本不修改原有异步代码的情况下，将任务提交序列捕获为 TaskTopo：

```cpp
cnrtTaskTopo_t topo;

cnrtQueueBeginCapture(queue, cnrtQueueCaptureModeGlobal);
kernel_a<<<dim, type, queue>>>(...);
kernel_b<<<dim, type, queue>>>(...);
cnrtInvokeHostFunc(queue, host_func, user_data);
cnrtQueueEndCapture(queue, &topo);
```

QueueCapture 的主要接口：

| API | 作用 |
| --- | --- |
| `cnrtQueueBeginCapture` | 将 Queue 设置为捕获模式 |
| `cnrtQueueEndCapture` | 结束捕获并返回生成的 TaskTopo |
| `cnrtQueueIsCapturing` | 查询 Queue 是否处于捕获状态 |
| `cnrtQueueGetCaptureInfo` | 获取 Queue 的捕获信息 |
| `cnrtQueueUpdateCaptureDependencies` | 修改后续捕获任务的前序依赖 |

捕获期间，下发到该 Queue 的异步任务不会立即执行，而是转换为任务图节点；节点依赖由提交顺序产生。结束捕获后，返回的 TaskTopo 与用于捕获的 Queue 不再绑定。

| QueueCapture 模式 | 说明 |
| --- | --- |
| `cnrtQueueCaptureModeGlobal` | 全局捕获；开始和结束必须在同一线程，捕获期间会限制进程内的同步、查询、TaskTopo 实例化和同步内存分配 |
| `cnrtQueueCaptureModeThreadLocal` | 线程局部捕获，当前版本暂不支持 |
| `cnrtQueueCaptureModeRelaxed` | 无约束捕获模式 |

> [!WARNING]
> - 捕获状态的 Queue 不能执行 Sync 或 Query；
> - QueueCapture 不可重入；
> - 当前不支持捕获 Default Queue；
> - 捕获的异步拷贝必须使用页锁定 Host 内存；
> - 多 Queue 捕获可以借助 `cnrtPlaceNotifier` 和 `cnrtQueueWaitNotifier` 建立分支与合并，但所有分支 Queue 必须在原始 Queue 结束捕获前重新汇合。

### 实体图执行与更新

TaskTopoEntity 是经过合法性检查和资源初始化的可执行快照。实例化阶段会检查任务图是否有环、节点参数是否合法，以及当前平台是否支持相应节点。

- 实体图不能修改拓扑结构；节点或依赖发生变化时需要重新实例化；
- 只修改节点参数时，可以使用整图更新或具体节点参数更新接口；
- 实体图可以在任意 Queue 上重复执行，无依赖关系的内部节点可以并行；
- 同一个实体图不能与自身并发执行，同时下发到多个 Queue 时仍会串行执行。

## FAQ

### Queue 中的任务如何执行

同一 Queue 中的任务按照 FIFO 串行执行，不同 Queue 中的任务可以并行执行。

### Queue 是否可以不销毁

通过 `cnrtQueueCreate` 创建的 Queue 应由用户调用 `cnrtQueueDestroy` 销毁。进程退出时运行时虽然会回收资源，但依赖自动回收存在隐患。

### 使用 dlopen 加载 Kernel 时需要注意什么

通过 `dlopen` 加载动态库中的 Kernel 后，应在进程结束前调用 `dlclose`。否则部分系统环境可能在退出时出现异常。

### fork 的调用时机

必须在调用任何 CNRT 或 CNDrv API 之前调用 `fork`，否则可能发生 API 错误或其他未知问题。

### cnrtSetDevice 后为什么不能立即调用 CNDrv 资源接口

`cnrtSetDevice` 创建的 Shared Context 尚未激活。可以调用 `cnrtFree((void *)0)` 激活 Context，再使用 `cnMalloc` 等 CNDrv 资源接口。

### 第一次创建 Queue 时为什么会占用设备内存

`cnrtQueueCreate` 是需要激活 Shared Context 的资源类 API。首次调用时会触发 CNRT 隐式初始化和 Kernel Module 加载，因此会预先申请一部分设备内存用于保存 Kernel 数据和指令。
