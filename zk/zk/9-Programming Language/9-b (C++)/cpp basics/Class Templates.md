# Class Templates

![2025Fall-09-TemplateClasses, 页面 20](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=20)

于是，我们有：
```cpp
#include "grandmas_template.h" 
GENERATE_VECTOR(int) 
intVector v1; 
v1.push_back(5);
```

但是...
![2025Fall-09-TemplateClasses, 页面 25](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=25)

> Templates have come a long way

```cpp
//Template Declaration 
//Vector is a template that takes in the name of a type T
template <typename T>
class Vector { // T gets replaced when Vector is instantiated
public:
    T& at(size_t index);
    void push_back(const T& elem);
    
private:
    // 指向 T 类型数组的指针
    T* elems;
};

```

![2025Fall-09-TemplateClasses, 页面 27](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=29)



> [!NOTE] java泛型与cpp模板
> ![2025Fall-09-TemplateClasses, 页面 35](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=35)
> 
> 图里有两种类型：
> 
> - `Vector<double>`
> - `Vector<int>`
> 
> > These two instantiations (of the same template) are completely different (runtime and compile-time) types  
> 
> **这两个虽然来自同一个模板 `Vector<T>`，但在 C++ 里，它们是完全不同的类型**，无论在编译期还是运行期都算不同的东西。
> 
> 在 Java 中，`ArrayList<Integer>` 和 `ArrayList<Double>` 在运行期却**是同一种类型**（都只是 `ArrayList`），这就是所谓的 *type erasure*（类型擦除）。
> 
> ---
> 
>  🔍 C++ 模板：每个 T 生成一个“真·新类型”
> 
> 在 C++ 中，编译器会做的事类似于“复制粘贴生成代码”：
> 
> - 针对 `int` 生成一个类：`class Vector_int { ... }`
> - 针对 `double` 再生成一个类：`class Vector_double { ... }`
> 
> 所以：
> 
> - `Vector<int>` 和 `Vector<double>` **在编译器眼中是两种完全不同的类型**  
>   - 不能互相赋值  
>   - 不能用同一个函数参数既收 `Vector<int>` 又收 `Vector<double>`
> - 在运行时，它们的对象布局、代码入口也都是不同的实现（各自一套）。
> 
> ---
>  🔄 Java 泛型：编译期检查 + 运行期“都变成 ArrayList”
> 
> Java 里：
> ```java
> ArrayList<Integer> ai = new ArrayList<>();
> ArrayList<Double> ad = new ArrayList<>();
> ```
> 
> 编译器在**编译期**会用泛型帮你做类型检查，比如不让你往 `ArrayList<Integer>` 里塞 `String`。  
> 但**编译后的字节码里，类型参数会被擦掉**，都变成类似：
> ```java
> ArrayList ai = new ArrayList();
> ArrayList ad = new ArrayList();
> ```
> 
> 因此在运行时：
> ```java
> ai.getClass() == ad.getClass()   // true
> ```
> 
> 这就是图中那句：  
> > `ArrayList<int> and ArrayList<double>` share the same runtime type.
> 
> 也就是说：
> 
> - Java：**编译期**区分泛型参数，**运行期**一视同仁（类型擦除）。
> - C++：编译期直接生成多种真正不同的类型，因此**运行期也不同**。
> 
> ---
> 
>  💡 这张图想说明什么？
> 
> 1. **C++ 模板是“生成代码”的工具**：  
>    模板实例化后，就是实打实的、新的类型；没有什么“运行时擦除”这回事。
> 
> 2. **Java 泛型更偏向“编译期语法糖”**：  
>    用来提升类型安全和可读性，但运行时层面，只剩下原始的容器类型。
> 
> 3. 思维习惯上：  
>    - 在 C++ 中，看到 `Vector<T>`，就要当成“`T` 不同就真的是不同类型”。  
>    - 在 Java 中，看到 `ArrayList<T>`，要记住“`T` 只是编译器用来检查和提示的，运行时全是一种 `ArrayList`”。
> 
> ---
> 
> 如果是从 Java / C# 后再学 C++ 模板，这张图其实就是在提醒：  
> **别把 C++ 模板当成 Java 泛型，它强得多，也实得多。**


### 非类型模板参数

> [!NOTE] non-typename template parameter
> ![2025Fall-09-TemplateClasses, 页面 37](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=37)
> 
> 
> 1）**模板参数不一定都是类型（typename）**；  
> 2）**`std::array` 为啥有时比 `std::vector` 更好**。
> 
> ---
> 
> 🧭 non-typename template parameter 是啥？
> 
> 图里的代码是：
> 
> ```cpp
> template <typename T, std::size_t N>
> struct std::array { /* ... */ };
> 
> // An array of exactly 5 strings
> std::array<std::string, 5> arr;
> ```
> 
> 这里模板有两个参数：
> 
> - `typename T`：**类型模板参数**（type template parameter）  
>   - 比如 `T = std::string`
> - `std::size_t N`：**非类型模板参数（non-type template parameter, NTTP）**  
>   - 这里是一个编译期常量整数  
>   - 比如 `N = 5`
> 
> 所以 `std::array<std::string, 5>` 和 `std::array<std::string, 10>` 是**两个完全不同的类型**，不仅元素类型不同算新类型，**大小不同也算新类型**：
> 
> **non-typename 就是在强调：模板参数也可以是值，而不只是类型。**  
> 除了整数，现代 C++ 还支持指针、引用、`std::nullptr_t` 等作为非类型模板参数（但整数是最常见的）。
> 
> ---
> 
> 🧊为什么 `std::array` 可以避免堆分配？
> 
> > 为什么用 `array` 而不是 `vector`？因为它避免了堆分配。  
> > 编译器在编译期就知道 `array<string, 5>` 占多大空间，所以它可以被分配在栈上。
> 
> 核心点：
> 
> 1. `std::array<T, N>` 的大小在**编译期就确定**  
>    - 它本质上就是一个“带点接口的 C 数组”：
>      ```cpp
>      template <typename T, std::size_t N>
>      struct array {
>          T elems[N];
>      };
>      ```
>    - 所以 `sizeof(std::array<T, N>) == N * sizeof(T)`（忽略对齐与填充）
> 
> 1. 因为大小固定、已知，**可以直接放在栈上或类对象里**：
> 
>    ```cpp
>    void f() {
>        std::array<std::string, 5> arr;  // 通常在栈上分配
>    }
>    ```
> 
> 3. `std::vector<T>` 的大小在**运行期才确定，大小事实上是可变的**  
>    - 它内部一般是三个东西：指针 + size + capacity  
>    - 真正的元素是在堆上分配的
>    - 所以每次扩容 / 构造，都可能进行堆分配
> 
> ---
> 
> #### 🧩 小结
> 
> - `template<typename T, std::size_t N>` 中的 `N` 是 **non-typename template parameter**，是一个编译期常量值，而不是类型。  
> - `std::array<std::string, 5>` 的“5”写在模板参数里，所以数组大小成为**类型的一部分**。  
> - 编译器因此在编译期就知道这块内存的确切大小，可以直接在栈上或对象内分配，省掉 `std::vector` 那种堆分配的成本。  


### Template quirks

>  Must copy `template <…>` syntax in .cpp

```cpp
// Vector.h 
template <typename T> 
class Vector { 
	public: T& at(size_t i); 
};

T& Vector::at(size_t i) ❌ {  // Compiler: “I do not know what T is!”
// Implementation... 
}

template <typename T> ✅
T& Vector<T>::at(size_t i) {  // Compiler: “Ahh.. I’m happy now 😌”
// Implementation... 
}

```

> .h must include .cpp at bottom of file

![2025Fall-09-TemplateClasses, 页面 46](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=46)

![2025Fall-09-TemplateClasses, 页面 46](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=47)


> [!NOTE] why?
> **为了让编译器能够生成代码，模板的具体实现（通常写在 .cpp 中）必须对调用者可见，因此通常不得不把 .cpp 的内容包含在 .h 中，或者直接全写在 .h 里。**
> 
> ---
> 
> 🔍 核心原因：模板是“蓝图”，不是“实物”
> 
> 要理解这个问题，首先要明白 C++ 编译器处理**普通函数**和**模板函数**的区别：
> 
> 1. 普通函数（Normal Function）
> *   **机制：** 编译器看到普通函数时，它知道具体的参数类型（比如 `int` 或 `float`），所以它可以直接把函数编译成机器码（二进制指令）。
> *   **分离编译：** 你可以在 `.h` 声明，在 `.cpp` 实现。链接器（Linker）最后会把它们连起来。
> 
> 2. 模板函数（Template Function）
> *   **机制：** 模板本身**不是代码**，它只是一个**蓝图**。
> *   **问题：** 如果你只写了一个 `template <typename T> void add(T a, T b)`，编译器无法生成机器码，因为它不知道 `T` 到底是什么。是 `int`？是 `double`？还是一个自定义的 `Cat` 类？
> *   **实例化（Instantiation）：** 只有当你**使用**模板时（比如调用 `add<int>(1, 2)`），编译器才会根据蓝图，“现场”生成一份处理 `int` 的代码。这叫“模板实例化”。
> 
> ---
> 
> 🛠️ 为什么分开写会报错？（编译单元隔离）
> 
> 如果你按照习惯，把模板声明写在 `.h`，把实现写在 `.cpp`，会发生以下情况：
> 
> ##### ❌场景模拟
> 假设你有三个文件：`main.cpp`（调用者），`Tool.h`（声明），`Tool.cpp`（实现）。
> 
> 1.  **编译 `main.cpp` 时：**
>     *   编译器看到了 `Tool.h`，知道有一个模板函数 `func<T>`。
>     *   `main` 中调用了 `func<int>`。
>     *   编译器想：“好吧，我需要生成一个 `int` 版本的 `func` 代码。**但是我手头只有声明，没有具体的代码实现（因为实现藏在 `Tool.cpp` 里），所以我生成不了。**”
>     *   编译器暂时放过它，寄希望于链接器能找到。
> 
> 1.  **编译 `Tool.cpp` 时：**
>     *   编译器看到了模板的源代码。
>     *   **但是**，编译器不知道其他文件（如 `main.cpp`）需要 `int` 版本。
>     *   所以，编译器**什么代码都没生成**（因为它不知道该生成 `int` 版还是 `float` 版）。
> 
> 1.  **链接阶段（Linker）：**
>     *   `main.o` 呼叫：“谁有 `func<int>` 的代码？”
>     *   `Tool.o` 回答：“我只有模具，没生成过 `int` 版的代码。”
>     *   **结果：** `Undefined reference`（未定义引用）错误。💥
> 
> ---
> 
> ##### ✅ 解决方案：为什么 `.h` 要包含 `.cpp`？
> 
> 为了解决上面的矛盾，必须打破“分离编译”的规则。
> 
> **幻灯片中的做法（Inclusion Model）：**
> 在 `Template.h` 的末尾写上 `#include "Template.cpp"`。
> 
> 当 `main.cpp` 包含 `Template.h` 时，预处理器会把 `.h` 和 `.cpp` 的内容全部复制粘贴到 `main.cpp` 中。
> 这样，当编译器在 `main.cpp` 中遇到 `func<int>` 时：
> 1.  它看到了模板的声明。
> 2.  它同时也看到了模板的**完整源代码实现**。
> 3.  它立刻就能根据这个蓝图和int，现场生成所需的机器码。
> 
> ---
> 
> ##### 💡 总结与最佳实践
> 
> 这就是为什么slides说 "That's pretty weird"（这很奇怪），因为它违反了 C++ 传统的“头文件只放声明”的直觉。
> 
> 为了避免混淆，很多 C++ 开发者在写模板时，根本不创建 `.cpp` 文件，而是直接把声明和实现都写在 `.h` 里；或者将实现文件的后缀改为 `.hpp` 或 `.tpp`，以暗示它不是一个普通的源文件，而是会被包含的模板实现文件。


> typename is the same as class

All of the following are identical:
```cpp
// 1. 全部使用 typename (现代 C++ 推荐写法)
template <typename K, typename V>
struct pair;

// 2. 全部使用 class (传统写法)
template <class K, class V>
struct pair;

// 3. 混合使用 (合法，但少见)
template <class K, typename V>
struct pair;

// 4. 混合使用 (合法，但少见)
template <typename K, class V>
struct pair;
```

### Const Correctness

我们有如下代码：
```cpp
template<class T> 
class Vector { 
public: size_t size(); 
bool empty(); 

T& operator[] (size_t index); 
T& at(size_t index); 
void push_back(const T& elem); 
};
```

但如果运行如下代码会有问题：
![2025Fall-09-TemplateClasses, 页面 59](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=59)

在方法的声明与实现后加上const可以解决问题(The const interface)
- Objects marked as const can only make use of the const interface
- The const interface are the functions that are const in an object
![2025Fall-09-TemplateClasses, 页面 60](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=60)

Inside a const method, this has type `const Vector<T>*`
	
![2025Fall-09-TemplateClasses, 页面 60](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=63)

但是即使加上const，方法的声明与实现仍然有问题...

![2025Fall-09-TemplateClasses, 页面 71](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=71)

由于返回的不是`const T&`，当函数参数传入`const Vector<int>& v`时，我们事实上是可以修改值的

![2025Fall-09-TemplateClasses, 页面 72](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=72)

但是加上`const`，又会引发新的问题...

![2025Fall-09-TemplateClasses, 页面 73](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=73)

当函数参数传入`Vector<int>& v`时，我们又不可以修改值了

![2025Fall-09-TemplateClasses, 页面 74](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=74)

Overloading!
只能定义两个版本作为解决方案了

![2025Fall-09-TemplateClasses, 页面 75](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=75)

但是很明显这很冗余，如果有更多且更复杂的方法需要overload呢？
比如像`findElement()`这样实现更复杂的方法

![2025Fall-09-TemplateClasses, 页面 78](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=78)

使用`const_cast<>`消灭冗余
![2025Fall-09-TemplateClasses, 页面 82](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=82)

用转换的方法消灭冗余
> 注：图片中的文字 "What in the Bjarne is going on here?" 是一个梗，指的是Bjarne Stroustrup，意为：“这写的是什么黑魔法？”

不过这里好像有点问题？正常来说是在const版本里实现完整的逻辑，之后在non-const版本中使用类似
` const_cast<T&>(static_cast<const Vector<T>&>(*this).findElement(value));`的逻辑来转换
详情请见Effective C++中的Item3

![2025Fall-09-TemplateClasses, 页面 83](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=83)

解析如下：
![2025Fall-09-TemplateClasses, 页面 89](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=89)


> Valid uses of const_cast are few and far between 意为 可以合理使用 `const_cast` 的情况是非常稀少、寥寥无几的

![2025Fall-09-TemplateClasses, 页面 89](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=92)

#### 是否有更细粒度的控制? mutable

使用mutable
![2025Fall-09-TemplateClasses, 页面 95](files/slides/CS106L/2025Fall-09-TemplateClasses.pdf#page=95)
