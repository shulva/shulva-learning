# Class


![2025Fall-07-Classes, 页面 8](files/slides/CS106L/2025Fall-07-Classes.pdf#page=8)


![2025Fall-07-Classes, 页面 8](files/slides/CS106L/2025Fall-07-Classes.pdf#page=21)

### Constructor and destructor

> .h file
```cpp
class StanfordID {
private:
    std::string name;
    std::string sunet;
    int idNumber;

public:
    // constructor for our StudentID
    StanfordID(std::string name, std::string sunet, int idNumber);

    // method to get name, sunet, and idNumber, respectively
    std::string getName();
    std::string getSunet();
    int getID();
}

```
> .cpp file (implementation)
```cpp
#include "StanfordID.h"
#include <string>

// ⚠️ 注意：这里的 StanfordID:: 前缀是必须的
StanfordID::StanfordID(std::string name, std::string sunet, int idNumber) {
    name = name;         // 🔴 这里有一个潜在的逻辑错误（变量遮蔽）
    sunet = sunet;       // 🔴 同样的问题
    idNumber = idNumber; // 🔴 同样的问题
}

```

> Use the **this** keyword
```cpp
// Use this this keyword to disambiguate which ‘name’ you’re referring to.
StanfordID::StanfordID(std::string name, std::string sunet, int idNumber) {
    this->name = name;
    this->sunet = sunet;       
    this->idNumber = idNumber; 
}
```


当然，初始化还可以用一种名为**成员初始化列表**的方法，详见[9-b-6 （初始化与构造函数）](../cpp11/9-b-6%20（初始化与构造函数）.md#^list-construct)
> List initialization constructor (C++11) .cpp file (implementation)

```cpp
#include "StanfordID.h"
#include <string>

// list initialization constructor
// Recall uniform initialization, this is similar but not quite!
StanfordID::StanfordID(std::string name, std::string sunet, int idNumber)
    : name{name}, sunet{sunet}, idNumber{idNumber} {}; 

```

> 析构函数

```cpp
#include "StanfordID.h"
#include <string>

StanfordID::~StanfordID() {
    // free/deallocate any data here (在这里释放/归还任何数据)
    delete [] my_array; // for illustration (仅作演示用)
}

```

### 组合优于继承

> A car ~~is~~ has an engine!
![2025Fall-08-Inheritance, 页面 99](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=99)


![2025Fall-08-Inheritance, 页面 99](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=100)


---


> [!NOTE] pimpl (pointer to implementa)
> **pImpl（pointer to implementation）就是：把一个类的“实现细节”挪到另一个类里，通过一个指针指过去。**
> 
> - 头文件里：只暴露一个「瘦身」后的接口类，里面只放一个指向实现类 `impl` 的指针。
> - 源文件里：真正的实现完全藏在 `.cpp` 里，外部看不到实现的成员变量、私有函数、依赖头文件等等。
> 
> 这么做的核心目的有两个：
> 
>  **隐藏实现细节（information hiding / encapsulation）**
>  **减少编译依赖 & 保持 ABI 稳定（库升级时不需要重新编译用户代码）**
> 
> ---
> 
>  ##### 普通类的三个问题
> 
> 假设你有一个普通类：
> 
> ```cpp
> // widget.h
> # include <string>
> # include <vector>
> 
> class widget {
> public:
>     void foo();
> 
> private:
>     std::string name_;
>     std::vector<int> data_;
> };
> ```
> 
> 问题：
> 
> -  **实现改一点，所有用到 `widget` 的文件都要重编**
>    - 私有成员也属于对象布局，编译器在编译用户代码时就需要知道 `sizeof(widget)`。
>    - 一旦你在 `widget` 里加了个私有成员，所有 `#include "widget.h"` 的地方都要重编。
> 
> -  **头文件膨胀，编译慢**
>    - `widget.h` 需要包含 `<string>`, `<vector>` 等等。
>    - 别的文件只要 `#include "widget.h"`，就间接包含了所有这些头文件，编译依赖层层传染。
> 
> -  **二进制兼容性差（ABI 不稳定）**
>    - 如果你发布的是一个 `.so` / `.dll` 动态库，用户只链接你的库和头文件。
>    - 你后来修改了 `widget` 的私有成员布局，重新编译库，但用户没重新编译自己的程序，就可能出现 ABI 不兼容、运行时崩溃。
> 
>  -  pImpl 如何缓解这些问题？
> 
> 采用 pImpl：
> 
> ```cpp
> // widget.h
> #include <memory>
> 
> class widget {
> public:
>     widget();
>     ~widget();
> 
>     void foo();
> 
> private:
>     struct impl;               // 仅前置声明，不知道里面长什么样
>     std::unique_ptr<impl> p_;  // 只知道有一个指针
> };
> ```
> 
> ```cpp
> // widget.cpp
> #include "widget.h"
> #include <string>
> #include <vector>
> 
> struct widget::impl {
>     std::string name_;
>     std::vector<int> data_;
> 
>     void foo_impl();
> };
> 
> widget::widget() : p_(std::make_unique<impl>()) {}
> widget::~widget() = default;
> 
> void widget::foo() {
>     p_->foo_impl();
> }
> ```
> 
> 这样带来的好处：
> 
> -  **头文件不暴露实现细节**
>    - `widget.h` 里只包含 `<memory>` 就够了，`<string>`, `<vector>` 等完全留在 `.cpp`。
>    - 使用 `widget` 的用户不需要知道这些依赖，编译更快、耦合更低。
> 
> -  **修改实现不需要重编用户代码**
>    - 你在 `impl` 里加字段、删字段、改私有函数，用户的 `.cpp` 完全不需要重编，只要链接新库即可。
>    - 因为从用户视角看，`widget` 的布局没变：它就是一个 `unique_ptr<impl>`，大小和布局固定。
> 
> -  **便于保持 ABI 稳定**
>    - 面向发布二进制库时，尤其重要。
>    - 只要你不改变公开接口（public 成员函数的签名、class 的大小等），就能在库内部尽情调整实现。
> 
> 
>   ##### 为什么析构函数要在 `.cpp` 里定义？
> 
> 因为：
> 
> - `std::unique_ptr<impl>` 的析构需要知道 `impl` 的完整类型。
> - 但在头文件中，`impl` 只有前置声明，不完整。
> - 解决办法：**在 `.cpp` 里写 `widget::~widget() = default;`**，此时编译器看到 `struct widget::impl` 的完整定义了，能生成正确的析构代码。
> 
> ---
> 
> pImpl 依赖于 C++ 的一个特性：**指针/引用可以指向“不完整类型”**。
> 
> ```cpp
> struct X;          // 只声明，不定义：不完整类型
> 
> X* p;             // OK，只声明指针，不需要知道 X 的大小
> // X x;          // 错，栈上对象需要 sizeof(X)
> ```
> 
> 在 `widget.h` 中：
> ```cpp
> struct impl;              // 不完整类型
> std::unique_ptr<impl> p;  // OK，编译器只需要知道指针大小
> ```
> 
> 在 `widget.cpp` 中：
> ```cpp
> struct widget::impl {
>     // 真正的数据
> };
> ```
> 
> **定义与实现分离**，就是借此实现的。
> 
> ---
>  ⚖️ pImpl 的代价和缺点
> 
> pImpl有几个明显 trade-off：
> 
> -  额外的间接访问 & 动态分配
> 每次访问成员：`p_->member`，相当于多了一次指针跳转。
> - 同时 `impl` 通常通过 `new` 分配在堆上，有堆分配开销。
> 
> -  代码量增加、可读性稍差
> - 你需要维护两套东西：外部接口类 + 内部实现类。
> 
> -  值语义变复杂
> - 如果你的类需要可拷贝，`std::unique_ptr<impl>` 本身不可拷贝，你必须自己写拷贝构造 / 赋值，并实现“深拷贝”。
> - 或者你选择禁止拷贝，只允许移动（很多库类就是这么干的）。
> 
> -  不适合简单 POD / 纯算法类
> - 如果类本身非常简单，没有复杂依赖，也不需要 ABI 稳定，pImpl 反而增加复杂度。
> - pImpl 比较适合：库接口、GUI 控件对象、长寿命资源管理类等。
> 


###  Inheritance

![2025Fall-08-Inheritance, 页面 36](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=36)

通过继承来消除类定义上的冗余：
![2025Fall-08-Inheritance, 页面 43](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=43)


![2025Fall-07-Classes, 页面 60](files/slides/CS106L/2025Fall-07-Classes.pdf#page=60)

#### access modifer

private inheritance:
不指明的话，默认是私有继承

```cpp
class Entity {
public:
    bool overlapsWith(const Entity& other);
};

// 注意：这里没有写 public, protected 或 private
class Player : /* private */ Entity {
    // Private inheritance (私有继承):
    // - private members of Entity are inaccessible to all (Entity 的私有成员对谁都不可见)
    // - public members become private (inaccessible to outside) (Entity 的公有成员在 Player 中变成了私有，外部无法访问)
};
```

public inheritance:
```cpp
class Entity {
public:
    bool overlapsWith(const Entity& other);
};

// ✅ 添加了 public 关键字
class Player : public Entity {
    // Public inheritance (公有继承):
    // - private members of Entity are still inaccessible (Entity 的私有成员依然不可访问)
    // - public members become public (accessible to outside) (Entity 的公有成员在 Player 中保持公有，外部可访问)
};

```


![2025Fall-08-Inheritance, 页面 50](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=50)

protected inheritance:
![2025Fall-08-Inheritance, 页面 51](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=51)
#### diamond problem 菱形继承问题

![2025Fall-07-Classes, 页面 80](files/slides/CS106L/2025Fall-07-Classes.pdf#page=81)

> The way to fix this is to make B and C inherit from A in a virtual way. 
> Virtual inheritance means that a derived class, in this case D, should only have a single instance of base classes, in this case A.

```cpp
D obj {}; 
obj.B::hello(); // call B’s hello method 
obj.C::hello(); // call C’s hello method 
obj.hello(); // whose method do I call ???

//------------------------------------ Solution:use virtual 
class C : virtual public A { public: C(); }
class B : virtual public A { public: B(); }

// This creates a shared instance of A between B and C!
obj.hello(); // no longer ambiguous :)
```


> [!question] virtual虚继承如何解决问题？
> 1. 没有虚继承时（问题的根源）
> 
> 假设结构是：**A** 是基类，**B** 和 **C** 继承 A，**D** 继承 B 和 C。
> 
> 在普通继承中，继承意味着“包含”。
> *   当 **B** 继承 **A** 时，B 的体内这就有一个完整的 **A**。
> *   当 **C** 继承 **A** 时，C 的体内也有一个完整的 **A**。
> 
> 当你创建 **D** 时，D 把 B 和 C 拼在一起。于是 D 的内存布局看起来是这样的：
> 
> ```text
> Class D 的内存布局：
> [ A 的数据 ]  <-- 这是 B 带来的 A
> [ B 的数据 ]
> ----------------
> [ A 的数据 ]  <-- 这是 C 带来的 A （重复了！）
> [ C 的数据 ]
> ----------------
> [ D 的数据 ]
> ```
> 
> **后果：**
>  **浪费空间**：A 存了两份。
>  **二义性（Ambiguity）**：如果在 D 里调用 `A::func()`，编译器会崩溃：“是指 B 带进来的那个 A，还是 C 带进来的那个 A？”
> 
> ---
> 
> 3. 用了 Virtual 继承后（如何解决）
> 
> 当你把继承改为 `class B : virtual public A` 时，规则变了。
> 
> **B 和 C 不再包含着 A 了，而是拥有指针/偏移量。**
> 
> 此时，编译器在构建 **D** 的时候，会执行特殊的逻辑：
> 3.  它发现 B 和 C 都虚继承自 A。
> 4.  它会说：“停！既然你们都想要 A，那我只在 D 的内存里**单独**造一份 A。”
> 5.  然后，它让 B 和 C 内部的指针都指向这份**公共的 A**。
> 
> **Class D 的内存布局（概念版）：**
> 
> ```text
> [ B 的数据 (包含一个指向 A 的指针) ]
> [ C 的数据 (包含一个指向 A 的指针) ]
> [ D 的数据 ]
> ----------------------------------
> [ A 的唯一实例 ]  <-- 大家都指向这里
> ```
> 
> **结果：**
> 无论继承链多复杂，只要是虚继承，最底层的子类（D）只会保留**一份**基类（A）的实例。
> 
> ---
> 4. 谁负责初始化 A？
> 
> *   **普通继承中**：B 负责构造它的 A，C 负责构造它的 A。
> *   **虚继承中**：B 和 C **不再负责**构造 A 了（因为它们不知道 A 到底在哪，也不拥有 A）。
> 
> **责任转移给了 D（最底层的派生类）。**
> 当创建 D 的对象时，C++ 编译器会强制要求 **D 直接调用 A 的构造函数**来初始化那份唯一的 A。B 和 C 对 A 的初始化请求会被忽略。

### Class Memory Layout

Python memory layout:
![2025Fall-08-Inheritance, 页面 13](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=13)


![2025Fall-08-Inheritance, 页面 13](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=14)

![2025Fall-08-Inheritance, 页面 15](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=15)

C++ stores less data in classes! This is one reason why C++ is more memory-efficient than Python

#### functions

![2025Fall-08-Inheritance, 页面 19](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=19)


![2025Fall-08-Inheritance, 页面 19](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=20)


![2025Fall-08-Inheritance, 页面 26](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=26)

#### 多态

有如下代码：
Entity父类中有`update()以及render()`方法，Player,Tree,Projectile是继承了Entity的子类，他们实现了各自的`update()以及render()`方法。

```cpp
int main() 
{ 
	std::vector<Entity> entities { Player(), Tree(), Projectile() }; 
	while (true) 
	{ 
		for (auto& entity : entities) 
			{ 
				entity.update(); 
				entity.render(); 
			} 
		} 
	}
}
```
但是执行时是会发生错误的。

原因在于：
![2025Fall-08-Inheritance, 页面 60](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=60)


![2025Fall-08-Inheritance, 页面 61](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=61)


于是，我们换一种方法...?
```cpp
int main() 
{ 
	Player p; Tree t; Projectile b; 
	std::vector<Entity*> entities { &p, &t, &b }; 
	while (true) 
	{ 
		for (auto& ent : entities) 
		{ 
			ent->update(); 
			ent->render(); 
		} 
	} 
}
```

按照下面的解释，这段代码应该是可行的。可惜，结果仍然不正确...
![2025Fall-08-Inheritance, 页面 64](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=64)

> 核心问题：which one is called??

![2025Fall-08-Inheritance, 页面 70](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=70)


![2025Fall-08-Inheritance, 页面 70](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=71)

Using `Entity*` comes at a cost: We **forget** which type the object actually is
![2025Fall-08-Inheritance, 页面 70](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=73)


![2025Fall-08-Inheritance, 页面 70](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=75)

所以，我们需要引入virtual function
如果 `Entity` 类中没有将 `update()` 和 `render()` 声明为**虚函数（virtual functions）**，编译器会使用静态绑定（Static Binding）

![2025Fall-08-Inheritance, 页面 78](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=78)

##### How virtual function work?

![2025Fall-08-Inheritance, 页面 82](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=82)

![2025Fall-08-Inheritance, 页面 85](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=85)


![2025Fall-08-Inheritance, 页面 87](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=87)

还有一些其他要点，比如纯虚函数：

> pure virtual function

Mark a virtual function as pure virtual by adding `= 0;` instead of an implementation!
```cpp

class Entity { 
	public: virtual void update() = 0; 
	virtual void render() = 0; 
};
```

![2025Fall-08-Inheritance, 页面 90](files/slides/CS106L/2025Fall-08-Inheritance.pdf#page=91)



