# Operator Overloading

![2025Fall-12-OperatorOverloading, 页面 19](files/slides/CS106L/2025Fall-12-OperatorOverloading.pdf#page=19)

I want the min of 2<???>...
类型 T 必须满足什么条件，我们才能使用 `min` 函数？

```cpp
template <typename T>
T min(const T& a, const T& b) {
    // 这里的关键操作是 "a < b"
    return a < b ? a : b;
}

// 这里的 T 需要满足什么条件才能编译成功？
// T a = ...;
// T b = ...;
// min<T>(a, b);
```

![2025Fall-12-OperatorOverloading, 页面 22](files/slides/CS106L/2025Fall-12-OperatorOverloading.pdf#page=22&selection=0,4,0,10)

> So how do operators work with classes?

- Just like we declare functions in a class, we can declare an operator's functionality
- When we use that operator with our new object, it performs a custom function or operation
- Just like in function overloading, if we give it the same name, it will override the operator's behavior!

> What are Operators?

Operators are symbols that perform operations on values, objects, or types and produce a new value or effect.

![2025Fall-12-OperatorOverloading, 页面 28](files/slides/CS106L/2025Fall-12-OperatorOverloading.pdf#page=28)

> 🚫 C++ 不可重载运算符列表

| 运算符类别 (Category)                        | 符号 (Symbol)                                          | 说明                                                                 |
| --------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------ |
| **作用域解析**  <br>(Scope Resolution)       | **`::`**                                             | 用于访问命名空间或类中的静态成员，属于编译器解析名称的基础机制。                                   |
| **三元运算符**  <br>(Ternary Conditional)    | **`? :`**                                            | 唯一的三元运算符。C++ 标准规定它不能被重载，以保证条件判断逻辑的一致性。                             |
| **成员访问**  <br>(Member Access)           | **`.`**                                              | 用于直接访问对象的成员。为了保证 `obj.member` 永远指向确定的成员，不允许重载。                     |
| **成员指针访问**  <br>(Pointer-to-member)     | **`.*`**                                             | 用于通过成员指针访问类成员（注意：`->*` 是可以重载的，但 `.*` 不行）。                          |
| **对象元数据与转换**  <br>(Size, Type, Casting) | **`sizeof()`**  <br>**`typeid()`**  <br>**`cast()`** | 包括 `sizeof`（编译期求大小）、`typeid`（运行时类型识别）以及强制转换关键字（如 `static_cast` 等）。 |

> Operator Overloading Syntax

`return_type operator<symbol>(parameter_list);`
## member overloading

如果不具备必要的条件，就会出现如下情况：
```cpp
StanfordID min(const StanfordID& a, const StanfordID& b) {
    return a < b ? a : b;  // Compiler: “Hey, I don’t know what to do here!”
}
```

> you want to compare StanfordID objects by their idNumber member variable, how could you implement this?

当你把一个运算符重载为**类的成员函数**时，这个类的对象实例 (this) 会自动成为运算符的**左操作数lhs**。因此，作为成员函数，你只需要为**右操作数rhs**提供一个参数。
```cpp
#include StanfordID.h  // private: int idNumber
int StanfordID::getIdNumber() { 
	return idNumber; 
} 

bool StanfordID::operator<(const StanfordID& other) const { 
	return idNumber < other.getIdNumber(); 
}
```
## non-member overloading

![2025Fall-12-OperatorOverloading, 页面 43](files/slides/CS106L/2025Fall-12-OperatorOverloading.pdf#page=43)


![2025Fall-12-OperatorOverloading, 页面 44](files/slides/CS106L/2025Fall-12-OperatorOverloading.pdf#page=44)

> Non-member overloading is actually preferred by the STL, and is more idiomatic C++ 
> And... Why?

1. Allows for the left-hand-side to be a non-class type

```cpp
// 允许左边是 int，右边是 StanfordID
bool operator<(int lhs, const StanfordID& rhs) {
    return lhs < rhs.getIDNumber();
}
```

> [!question] Why?
> 为什么？核心理由只有一个：**解放左操作数 (Left-Hand-Side, LHS)**。
> 为了理解这一点，我们需要对比一下两种写法的区别。
> 
> ##### 如果写成“成员函数” (Member Function)
> 假设你在 `StanfordID` 类内部定义了 `<`。当你写代码 `a < b` 时，编译器实际上将其翻译为：
> 
> > `a.operator<(b)`
> 
> 这就带来了一个巨大的限制：**等号左边的 `a` 必须是 `StanfordID` 类的实例**。
> 
> - ✅ `student < 12345` (可行，只要你重载了接受 int 的版本)
> - ❌ `12345 < student` (**报错！** 因为整数 `12345` 是基本类型，它里面没有 `operator<` 成员函数来接受一个 `StanfordID` 对象)
> 
> ##### 如果写成“非成员函数” (Non-member Function)
> 
> 这就是幻灯片中推荐的做法。你定义一个独立的全局函数，接受两个参数。当你写 `a < b` 时，编译器会翻译为：
> 
> > `operator<(a, b)`
> 
> 这就完美解决了上面的问题！
> 
> - ✅ `operator<(12345, student)`
> 

2. Allows us to overload operators with classes we don't own

```cpp
class StanfordID {
private:
    std::string sunet;
public:
    StanfordID(std::string s) : sunet(s) {}

    // 这是一个成员函数重载
    // ❌它只支持：StanfordID < string
    bool operator<(const std::string& other) const {  
        return sunet < other;
    }
};

// --- 下面是测试代码 ---

StanfordID rachel("rfer");
std::string name = "zzhang";

// ❌ 这里会报错！
if (name < rachel) {
    std::cout << "Name comes before Rachel\n";
}


// ✅定义在类外部
bool operator<(const std::string& lhs, const StanfordID& rhs) {
    return lhs < rhs.getSunet(); // 假设有 getter
}

```

---

> [!question] Why?
> 核心逻辑在于解释**操作数的顺序问题**。
> ##### 报错的原因
> 看代码中的报错行：
> > `if (name < rachel)`
> 
> 这里，**左操作数 (`name`) 是 `std::string` 类型**。
> 编译器会尝试去 `std::string` 类里找一个能接受 `StanfordID` 的 `<` 运算符。
> 即：`name.operator<(rachel)`。
> 
> **问题来了：**
> `std::string` 是标准库提供的类，**我们无法修改它**（We don't own it）。标准库在写的时候， `std::string` 里面肯定不会提供处理 `StanfordID` 的代码。
> 
> It's better to use non-member overloading so we can do comparison in both directions and with classes we don't own!

---

> Can we access these with non-member operator overloading? No!

但是non-member方法也有其缺点，毕竟我们将方法移到了类外部。如此这般，我们便无法访问类内部的私有成员。
![2025Fall-12-OperatorOverloading, 页面 52](files/slides/CS106L/2025Fall-12-OperatorOverloading.pdf#page=52)


而且，两者都定义是会引发UB的，歧义是非常非——常糟糕的！

![2025Fall-12-OperatorOverloading, 页面 52](files/slides/CS106L/2025Fall-12-OperatorOverloading.pdf#page=55)

所以，我们可以使用`friend`友元来解决非成员函数如何访问类内部的私有变量的问题。
![2025Fall-12-OperatorOverloading, 页面 52](files/slides/CS106L/2025Fall-12-OperatorOverloading.pdf#page=58)

- **在类内部声明**：在  类的定义里（通常在 `.h` 文件），加上一行带有 `friend` 关键字的函数声明。
- **在类外部定义**：函数的具体实现代码依然写在类外面，不需要加`Class::`前缀。

```cpp
// .h file
class StanfordID { 
....
private:
.....
public:
	friend bool operator < (const StanfordID& lhs, const StanfordID& rhs); 
}

// .cpp file
bool operator< (const StanfordID& lhs, const StanfordID& rhs) { 
	return lhs.idNumber < rhs.idNumber; 
}

//当然，这种方案也可以，只是不再需要friend了，因为不需要访问私有变量
bool operator< (const StanfordID& lhs, const StanfordID& rhs) { 
	return lhs.getIdNumber() < rhs.getIdNumber(); 
}
```
## So why is this even meaningful?

> Operators allow you to convey meaning about types that functions don't

用运算符来传达意义是更直观的。

![2025Fall-12-OperatorOverloading, 页面 67](files/slides/CS106L/2025Fall-12-OperatorOverloading.pdf#page=67)


![2025Fall-12-OperatorOverloading, 页面 70](files/slides/CS106L/2025Fall-12-OperatorOverloading.pdf#page=70)