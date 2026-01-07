# optional

## intro

> Type Safety: The extent to which a language prevents typing errors.
> 类型安全：指一门编程语言在多大程度上能够通过类型系统防止程序里的类型错误。

![2025Fall-15-OptionalAndTypeSafety, 页面 15](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=15)

> Type Safety: The extent to which a language guarantees the behavior of programs.
> 类型安全：指一门语言能在多大程度上，用类型系统来约束并保证程序的运行行为可预期。

`vector::back()` returns a reference to the last element in the vector 
`vector::pop_back()` is like the opposite of `vector::push_back(elem)`  It removes the last element from the vector.

显然，这段代码没有考虑`vec`为空的情况。
```cpp
void removeOddsFromEnd(vector<int>& vec){ 
	while(vec.back() % 2 == 1){ 
		vec.pop_back(); 
	} 
}
```
事实上，这段程序很容易引发UB

![2025Fall-15-OptionalAndTypeSafety, 页面 21](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=21)

> We can make no guarantees about what this function does! **我们无法对这个函数的行为做出任何保证！**
> Key idea: it is the **programmers job** to enforce the **precondition** that `vec` be non-empty, otherwise we get undefined behavior!

当然，最简单的方法就是加个判空
```cpp
void removeOddsFromEnd(vector<int>& vec){ 
	while(!vec.empty() && vec.back() % 2 == 1){ 
		vec.pop_back(); 
	} 
}
```

## intro - Deterministic behavior

> 所以，在 `vec` 这个容器里，**可能有，也可能没有最后一个元素**（也就是 `vec` 可能为空）。
> 那么，不管有没有最后一个元素，怎么才能让 `vec.back()` 的行为都是**确定的（可预期的）**呢？

> Dereferencing a pointer without verifying it points to real memory is **undefined behavior**!
```cpp
valueType& vector<valueType>::back(){ 
	return *(begin() + size() - 1);  // What happens if size() = 0?
}
```

> 改进`back()`
> Now, we will at least reliably error and stop the program **or** return the last element whenever `back()` is called

```cpp
valueType& vector<valueType>::back(){ 
	if(empty()) throw std::out_of_range; 
	return *(begin() + size() - 1); 
}
```

> 行为是确定的当然很好，但我们能不能做得更好？
> 在 `vec` 里可能有，也可能没有最后一个元素
> 我们希望**在调用时**就被“提醒”，这里有可能会没有元素，需要你显式处理

> Type Safety: The extent to which a **function signature** guarantees the behavior of a function.
> 类型安全：指一个函数的签名（参数和返回值的类型等）在多大程度上，把函数的行为约束并保证在类型层面上。


在这种Type Safety定义下，`back()`的问题显而易见:`back()` 承诺自己一定会返回一个 `valueType` 类型的对象，但在某些情况下（比如容器为空）其实并不存在这样的元素。
所以如下代码中，我们改进一下返回值即可

```cpp
valueType& vector<valueType>::back(){ 
	if(empty()) throw std::out_of_range; 
	return *(begin() + size() - 1); 
}

// now it advertises that there may or may not be a last element
std::pair<bool, valueType&> vector<valueType>::back(){ 
	if(empty()){ 
		return {false, valueType()}; 
	} 
	return {true, *(begin() + size() - 1)}; 
}
```

But... we call the Default constructor of `valueType()`

![2025Fall-15-OptionalAndTypeSafety, 页面 34](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=34)

> 即使无视这些代价，一旦default的结果或者其它正常构造路径会产出用来当**特殊标记**的数值（这里是奇数），那整套用特殊值做状态检测的方案就会变得极不可靠——所以这是设计层面的 type safety 问题。
> 在这个层面上，类型系统的检查暂时帮不上忙

![2025Fall-15-OptionalAndTypeSafety, 页面 35](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=35)

我们到底该返回什么？
```cpp
??? vector<valueType>::back(){ 
	if(empty()){ return ??; } 
	return *(begin() + size() - 1); 
}
```

## `std::optional`

[std::optional](https://en.cppreference.com/w/cpp/utility/optional.html)

> The class template `std::optional` manages an optional contained value, i.e. **a value that may or may not be present.**
> 
> A common use case for `optional` is the return value of a function that may fail. As opposed to other approaches, such as `std::pair<T, bool>`, `optional` handles expensive-to-construct objects well and is more readable, as the intent is expressed explicitly.

![2025Fall-15-OptionalAndTypeSafety, 页面 39](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=41)

用 `{}` 和 `std::nullopt` 这两种写法，都可以用来表示“没有值的状态”，**可以互换使用**
```cpp
void main() {
    std::optional<int> num1 = {};      // num1 does not have a value
    num1 = 1;                          // now it does!
    num1 = std::nullopt;               // now it doesn't anymore
}
```

所以现在，我们可以将`back()`更好地改进了
```cpp
std::optional<valueType> vector<valueType>::back(){ 
	if(empty()){ return {}; } 
	return *(begin() + size() - 1); 
}
```

我们不能拿一个 `optional` 直接做算术运算，必须先把里面真正的值（如果存在的话）取出来！
```cpp
void removeOddsFromEnd(vector<int>& vec){ 
	while(vec.back() % 2 == 1){ // but... how to do arithmetic with an optional?
		vec.pop_back(); 
	} 
}
```

> 使用`std::optional`提供的接口

![2025Fall-15-OptionalAndTypeSafety, 页面 47](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=47)

```cpp
#include <optional>
#include <iostream>
int main(){
	std::optional<int> a = 5;
	std::optional<int> b = std::nullopt;

	//------------------
	// 1. has_value()
	//------------------
	std::cout<<a.has_value(); // true
	std::cout<<b.has_value(); // false

	//------------------
	// 2. value()
	//------------------
	if(a.has_value())
		std::cout<<a.value(); // 5

	// this would throw bad_optional_access
	// std::cout<<b.value();

	//------------------
	// 3. value_or(default)
	//------------------

	std::cout<<a.value_or(999); // 5
	std::cout<<b.value_or(999); // 999

	return 0;
}
```

现在，如果我们的`vec`是空的，至少我们能拿到一个`bad_optional_access` error了

```cpp
void removeOddsFromEnd(vector<int>& vec){ 
	while(vec.back() % 2 == 1){ 
		vec.pop_back(); 
	} 
}
```

这种虽然不会出错，但是真的很丑
不过我们可以使用第二版的方案，You can just call vec.back() since nullopt is falsy!

```cpp
void removeOddsFromEnd(vector<int>& vec){ 
	while(vec.back().has_value() && vec.back().value() % 2 == 1){ 
		vec.pop_back(); 
	} 
}

void removeOddsFromEnd(vector<int>& vec){ 
	while(vec.back() && vec.back().value() % 2 == 1){ 
		vec.pop_back(); 
	} 
}
```

![2025Fall-15-OptionalAndTypeSafety, 页面 54](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=54)

## 用`std::optional`重新设计 `Vector`


> [!danger] Disclaimer: std::vector::back() doesn't actually return an optional (and probably never will)
> - C++ 标准库的现有接口（`operator[]`, `.at()`, `.back()` 等）是很传统的：“要么返回引用，要么直接抛异常 / UB”，并没有往处处都用 `optional` 表达失败的方向发展。
> - 也就是说，monad 化并不符合 C++ 现有风格，未来大概率也不会强行把这些老接口改成 `optional`。
> - 从 _教学_ 或 _函数式抽象_ 的角度，`optional` + `and_then` 的写法很优雅；
> - 从 _实际 C++ 标准库设计_ 的角度，要把像 `vector::back()` 这种核心接口改成返回 `optional`，几乎不可能，也不一定更好。

`[]` 运算符不够安全！如果`vec`是空的呢？UB!

```cpp
int foo(vector<int>& vec){ 
	return vec[0]; 
}
```

所以，下面slides这种方法可行吗？
答案是不行！`std::optional<T&>` 这种东西在标准库里是不存在的！

> 引用必须指向一个有效的对象，而 `optional` 不能保证这一点。想象一下：如果有一个指向 `nullopt` 的 optional会发生什么？
> 因为引用必须永远指向一个真实对象，而 `optional` 天生就允许“没有值”，两者语义冲突，所以 `std::optional<T&>` 在 C++ 标准库中是被禁止的。

```cpp
int main(){
	vector <int> v;
	v.data = {10,20,30};
	
	auto optRef = v[5]; // return std::nullopt;
	// ERROR: int& must store a reference to a real integer , not std::nullopt
}
```

![2025Fall-15-OptionalAndTypeSafety, 页面 58](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=58)


> 我们能做的最好的事情就是在出错时抛异常——这正是 `.at()` 的做法。

- 因为没有 `optional<T&>`，无法写出像 `optional` 那样“可空引用”的返回值；
- 所以 `vector` 提供了两种访问方式(符合cpp的设计哲学)：
    - `operator[]`：快，但不安全，不检查越界；
    - `at()`：安全，但有额外开销，越界就抛异常。

![2025Fall-15-OptionalAndTypeSafety, 页面 60](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=60)

> `std::optional`并非是完美的...

![2025Fall-15-OptionalAndTypeSafety, 页面 61](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=61)

## Monad

`std::optional`到底有何意义？
搞来搞去还有一大堆问题？Why even bother with optionals?

> Monad: `and_then(),transform(),or_else()`

```cpp
/** 
 * Calls a function to produce a new optional if there is a value; otherwise, returns nothing.
 *
 * The function passed to `and_then` 
 * it takes a non-optional instance of type `T` and returns a `std::optional<U>`.
 *
 * If the optional has a value, `and_then` applies the function to its value and returns the result.
 * If the optional doesn't have a value (i.e. it is `std::nullopt`), it returns `std::nullopt`.
 */
template <typename U>
std::optional<U> std::optional<T>::and_then(std::function<std::optional<U>(T)> func);

/**
 * Applies a function to the stored value if present 
 * Important!!: wrapping the result in an optional, or returns nothing otherwise.
 * transform 会自动这个结果包装进 std::optional<U>
 * 
 * The function passed to `transform` 
 * it takes a non-optional instance of type `T` and returns a non-optional instance of type `U`.
 *
 * If the optional has a value, `transform` applies the function to its value and returns the result wrapped in an `std::optional<U>`.
 * If the optional doesn't have a value (i.e. it is `std::nullopt`), it returns `std::nullopt`.
 */
template <typename U>
std::optional<U> std::optional<T>::transform(std::function<U(T)> func);

/** 
 * Returns the optional itself if it has a value; otherwise, it calls a function to produce a new optional.
 *
 * The opposite of `and_then`.
 * The function passed to `or_else` takes in no arguments and returns a `std::optional<U>`.
 * If the optional has a value, `or_else` returns it.
 * If the optional doesn't have a value (i.e. it is `std::nullopt`), `or_else invokes the function and returns the result.
 */
template <typename U>
std::optional<U> std::optional<T>::or_else(std::function<std::optional<U>(T)> func);
```

```cpp
#include <iostream>
#include <optional>

std::optional<int> half(int x) {          // 偶数 -> x/2，奇数 -> 空
    if (x % 2 == 0) return x / 2;
    return std::nullopt;
}

int square(int x) { return x * x; }       // 普通函数：x²

std::optional<int> fallback() {           // 兜底：给个 42
    return 42;
}

int main() {
    std::optional<int> a = 8;             // 有值
    std::optional<int> b = std::nullopt;  // 空

    // 1. and_then：链式「可能失败」运算（函数返回 optional）
    auto r1 =   a.and_then(half)          // 8 -> 4
                 .and_then(half)          // 4 -> 2
                 .and_then(half);         // 2 -> 1
    // r1 = optional(1)

    // 2. transform：在有值时做普通变换（函数返回普通值）
    auto r2 = r1.transform(square);       // 1 -> 1² = 1，结果 optional(1)
    auto r3 = b.transform(square);        // b 是空，r3 还是空

    // 3. or_else：若为空，用函数提供一个兜底 optional
    auto r4 = r3.or_else(fallback);       // r3 空 -> 调用 fallback -> optional(42)

    std::cout << "*r1 = " << *r1 << "\n"; // 1
    std::cout << "*r2 = " << *r2 << "\n"; // 1
    std::cout << "*r4 = " << *r4 << "\n"; // 42
}

```


> Monadic: a software design pattern with a structure that combines program fragments (functions) and wraps their return values in a type with additional computation These all let you try a function and will either return the result of the computation or some default value.

> monadic：一种软件设计模式，通过一个结构把若干程序片段（函数）串联起来，并把它们的返回值包在一个带额外语义/计算能力的类型里。  
   上面这些函数（`and_then` / `transform` / `or_else`）都让你可以‘尝试执行一个函数’，要么得到计算结果，要么得到某种默认/空结果。”


> [!question] 还是不懂...
> ##### 结合 `std::optional` 来理解
> 
> 用前面的例子来解释一下：
> 
> - **wrap their return values in a type with additional computation**  
>   - 本来函数只返回 `int`、`string` 之类的普通值；  
>   - 现在把返回值包进 `std::optional<T>` 这种“**可能没有结果**”的壳里；  
>   - 这个壳不只是存值，还自带一些“额外计算规则”：  
>     - 没值时，后面的计算都自动“跳过”；  
>     - 通过 `std::optional提供的 .and_then/.transform/.or_else` 来统一处理“有值/没值”的情况。
> 
> - **“combine program fragments (functions)”**  
>   指的就是：
> 
>   ```cpp
>   a.and_then(half)
>    .and_then(half)
>    .transform(square)
>    .or_else(fallback);
>   ```
> 
>   一串函数被**安全地串成流水线**：中途哪一步失败（变成 `nullopt`），后面就不再算了，最后还可以 `.or_else` 给一个默认结果。
> 
> - **“either return the result … or some default value”**  
>   对应到行为就是：
>   - 有值：按正常逻辑计算并返回结果；
>   - 没值：  
>     - 要么继续是 `nullopt`（比如 `and_then` / `transform`），  
>     - 要么通过 `or_else` 返回一个“兜底的 optional”。
> 
>  `std::optional` 配上 `and_then / transform / or_else`，本质上就是把“可能失败的计算”做成一个 **monad（单子）**：  
>  你可以把一堆函数优雅地串起来，要么一路顺利得到结果，要么在某处失败而变成“没有值”，最后还能统一在一个地方处理默认值 / 兜底。

---

现在有了一个优雅又健全的方法，通过 `while (vec.back().and_then(isOdd)) { ... }` , 只要 `back()` 经过 `isOdd` 处理后还是一个有效结果，就继续

逻辑统一、可组合、错误/空值传播自动化，很函数式、也很monadic，看来`std::optional`还是很有用的

![2025Fall-15-OptionalAndTypeSafety, 页面 72](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=72)

## cpp的设计哲学与`std::optional`

>**Well typed programs cannot go wrong.** 
> —— Robin Milner

其实一整个笔记可以说都在讲一件事：
- 用 **严格类型系统**（特别是有 `optional`、monad 这种工具的系统）
- 把“可能失败 / 可能没有值”这类情况写进类型里，让很多潜在 Bug 在编译期就被堵掉
- 正所谓：Enforce safety at compile time whenever possible
- **写得好的类型 = 不容易炸的程序**


![2025Fall-15-OptionalAndTypeSafety, 页面 74](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=74)

> monad玩的飞起的语言：

![2025Fall-15-OptionalAndTypeSafety, 页面 76](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=76)

> Besides using them in classes, you can use them in application code where it makes sense! This is highly encouraged :)

![2025Fall-15-OptionalAndTypeSafety, 页面 81](files/slides/CS106L/2025Fall-15-OptionalAndTypeSafety.pdf#page=81)
