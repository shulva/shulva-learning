# nullptr and long long

> [!quote]
> https://en.cppreference.com/w/cpp/language/nullptr.html
## nullptr

`nullptr` 是C++11引入的**指针字面量**，用于表示空指针。它解决了传统空指针表示方式（如`NULL`和`0`）在类型安全性和重载解析方面的不足。

**为什么引入?**

- 解决`NULL`宏和整数`0`在重载解析中的歧义问题
- 提供类型安全的空指针表示方式
- 明确区分指针和整数类型
- 支持模板编程中的类型推导

**nullptr和NULL有什么区别?**

- `nullptr`是C++11引入的关键字，类型为`std::nullptr_t`
- `NULL`是预处理宏，通常定义为整数`0`或`(void*)0`
- `nullptr`在重载解析中更精确，不会与整数类型混淆

### 基础用法

**替代传统的NULL和0**

```cpp
int* ptr1 = nullptr;        // 推荐用法
int* ptr2 = NULL;           // 传统用法
int* ptr3 = 0;              // 不推荐

// 检查指针是否为空
if (ptr1 == nullptr) {
    // 处理空指针情况
}
```

**解决重载歧义问题**
在函数调用中明确传递空指针，`nulltpr`能避免重载歧义问题, 并且避免与整数类型的混淆

```cpp
void func(int* ptr) {
    if (ptr != nullptr) {
        *ptr = 42;
    }
}

void func(int value) {
    // 处理整数参数
}

int main() {
    func(nullptr);  // 明确调用指针版本
    func(0);        // 可能调用整数版本，产生歧义
    func(NULL);     // 可能调用整数版本，产生歧义
}

main.cpp: In function 'int main()':
main.cpp:16:9: error: call of overloaded 'func(NULL)' is ambiguous
16 |     func(NULL);     // 可能调用整数版本，产生歧义
```

**确保模板编程中的类型安全**
在模板函数和类中，`nullptr`提供更好的类型推导和安全性

```cpp

template<class T>
constexpr T clone(const T& t) {
    return t;
}

void g(int*) {
    std::cout << "Function g called\n";
}

int main() {
    g(nullptr);        // ok
    g(NULL);           // ok
    g(0);              // ok

    g(clone(nullptr)); // ok
    g(clone(NULL));    // ERROR: NULL可能会被推导成非"指针"类型
    g(clone(0));       // ERROR: 0会被推导成非"指针"类型
}
```
当使用函数模板时, `NULL`和`0`通过会被推导成非指针类型, 而`nullptr`可以避免这个问题

```cpp
main.cpp:19:12: error: invalid conversion from 'int' to 'int*' [-fpermissive]
   19 |     g(clone(0));       // ERROR: 0会被推导成非"指针"类型
      |       ~~~~~^~~
      |            |
      |            int
```

**配合智能指针/容器**

```cpp
#include <memory>
#include <vector>

int main() {
    std::shared_ptr<int> sp1 = nullptr;
    std::unique_ptr<int> up1 = nullptr;

    std::vector<int*> vec;
    vec.push_back(nullptr);

    // 检查智能指针是否为空
    if (sp1 == nullptr) {
        sp1 = std::make_shared<int>(42);
    }
}
```

### 注意事项

`nullptr`的类型是`std::nullptr_t`，这是一个特殊的类型，可以 **隐式** 转换为任何指针类型：

```cpp
#include <cstddef>  // 包含std::nullptr_t的定义

void func(int*) {}
void func(double*) {}
void func(std::nullptr_t) {}

int main() {
    auto ptr = nullptr;  // ptr的类型是std::nullptr_t

    func(nullptr);       // 调用std::nullptr_t版本
    func(ptr);           // 调用std::nullptr_t版本

    int* intPtr = nullptr;
    func(intPtr);        // 调用int*版本
}
```

`nullptr`可以隐式转换为`bool`类型，在条件判断中非常方便：

```cpp
int* ptr = nullptr;

if (ptr) { // 等价于 if (ptr != nullptr)
    // 指针非空
} else {
    // 指针为空
}

bool isEmpty = (ptr == nullptr);  // true
```
## long long

**为什么引入?**

- 解决传统整数类型范围不足的问题
- 提供统一的64位整数类型标准

**long long和传统整数类型有什么区别?**

- `long long` 保证至少64位宽度，范围至少为 -2^63 到 2\^63-1
- `int` 通常为32位，范围约为 -21亿到21亿
- `long` 在32位系统上为32位，在64位系统上通常为64位（但标准只保证至少32位）

可以用来处理大整数应用

```cpp
#include <limits>

// 使用long long处理大数计算(超过int表示范围)
long long population = 7800000000LL;  // 世界人口

// 获取整数类型边界
int maxInt = std::numeric_limits<int>::max();
long long maxLL = std::numeric_limits<long long>::max();
auto minLL = std::numeric_limits<long long>::min();

```

##### 注意事项

使用`LL`或`ll`后缀明确指定`long long`字面量，使用`ULL`或`ull`指定无符号版本

```cpp
auto num1 = 10000000000;    // 类型可能是int或long，取决于编译器
auto num2 = 10000000000LL;  // 明确为long long辅助类型推导
```

注意不同整数类型之间的转换可能导致的精度损失

```cpp
long long bigValue = 3000000000LL;
int smallValue = bigValue;  // 可能溢出

std::cout << "bigValue: " << bigValue << std::endl;
std::cout << "smallValue: " << smallValue << std::endl;  // 可能不正确

// 安全转换检查
if (bigValue > std::numeric_limits<int>::max() || bigValue < std::numeric_limits<int>::min()) {
    std::cout << "转换会导致溢出!" << std::endl;
}

```

> [!question] 标准中为什么不固定位宽？
> 
> **原因**
> 
> - **硬件差异问题:** 不同架构“自然字长”不同：16/32/64 位都有，大量嵌入式甚至只有 8/16 位乘除指令.若强行规定(long为64位)，一些机器(32 位 MCU）上会造成巨大的性能损失
>     - 例如: 在8位机器上做64位计算, 但没有相关的机器指令。所以需要通过算法模拟的方式实现, 进而导致指令周期攀升
> - **历史与 ABI 兼容:** C/C++ 起源早于现代 32/64 位普及，许多平台的系统接口、文件格式、调用约定都已把 int/long 的大小写进了 ABI。标准若强制改变，会破坏二进制兼容和生态
> - **零成本抽象:** C/C++ 标准面向“与机器高效映射”的抽象机制，只规定行为与最小范围，让实现能选择对该平台最自然的宽度，从而获得零开销抽象或接近零开销
> 
> **解决方案**
> 
> - **C/C++提供了可选方案:** 需要精确位宽时，可以使用`<cstdint>/<stdint.h>`里的 `int8_t`、`int16_t`、`int32_t`、`int64_t`...
> - **不假设位宽和静态断言:** 开发时不假设类型的位宽, 从而提高可移植性. 如果部分代码做了位宽假设, 可以通过静态断言来保证位宽符合预期 `static_assert(sizeof(T)==N)`
> 
> ![table](https://sunrisepeak.github.io/mcpp-standard/imgs/long-long.0.png)