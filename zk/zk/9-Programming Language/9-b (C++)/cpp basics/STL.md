# STL

![2025Fall-05-Containers, 页面 32](files/slides/CS106L/2025Fall-05-Containers.pdf#page=32)

![2025Fall-05-Containers, 页面 98](files/slides/CS106L/2025Fall-05-Containers.pdf#page=98)
## Sequence Containers

Sequence containers store a linear sequence of elements
vector已是老生常谈，在此不列举

### std::deque

A deque has the same interface as vector, except we can push_front / pop_front

![2025Fall-05-Containers, 页面 52](files/slides/CS106L/2025Fall-05-Containers.pdf#page=52)


![2025Fall-05-Containers, 页面 52](files/slides/CS106L/2025Fall-05-Containers.pdf#page=55)

## associative containers

Associative containers organize elements by unique keys

## std::map

`std::map<K, V>` stores a collection of `std::pair<const K, V>`
```cpp
std::map<std::string, int> map; 
for (const auto& [key, value] : map)  //结构化绑定获取
{ 
	// key has type const std::string& 
	// value has type const int& 
}
```

![2025Fall-05-Containers, 页面 61](files/slides/CS106L/2025Fall-05-Containers.pdf#page=61)

![2025Fall-05-Containers, 页面 70](files/slides/CS106L/2025Fall-05-Containers.pdf#page=70)


![2025Fall-05-Containers, 页面 70](files/slides/CS106L/2025Fall-05-Containers.pdf#page=71)


![2025Fall-05-Containers, 页面 70](files/slides/CS106L/2025Fall-05-Containers.pdf#page=72)


![2025Fall-05-Containers, 页面 70](files/slides/CS106L/2025Fall-05-Containers.pdf#page=74)

## std::set

![2025Fall-05-Containers, 页面 77](files/slides/CS106L/2025Fall-05-Containers.pdf#page=77)

![2025Fall-05-Containers, 页面 80](files/slides/CS106L/2025Fall-05-Containers.pdf#page=80)

## std::unordered_map

![2025Fall-05-Containers, 页面 91](files/slides/CS106L/2025Fall-05-Containers.pdf#page=91)

![2025Fall-05-Containers, 页面 95](files/slides/CS106L/2025Fall-05-Containers.pdf#page=95)

![2025Fall-05-Containers, 页面 83](files/slides/CS106L/2025Fall-05-Containers.pdf#page=83)

![2025Fall-05-Containers, 页面 83](files/slides/CS106L/2025Fall-05-Containers.pdf#page=84)

![2025Fall-05-Containers, 页面 83](files/slides/CS106L/2025Fall-05-Containers.pdf#page=85)

![2025Fall-05-Containers, 页面 83](files/slides/CS106L/2025Fall-05-Containers.pdf#page=86)

![2025Fall-05-Containers, 页面 83](files/slides/CS106L/2025Fall-05-Containers.pdf#page=87)

![2025Fall-05-Containers, 页面 83](files/slides/CS106L/2025Fall-05-Containers.pdf#page=89)


You can control the max load factor before rehashing
```cpp
std::unordered_map<std::string, int> map; 
double lf = map.load_factor(); // Get current load factor 
map.max_load_factor(2.0); // Set the max load factor 
// Now the map will not rehash until load factor exceeds 2.0 
// You should almost never need to do this, 
// but it’s a fun fact (good for parties!)
```


## Iterators

We need something to track where we are in a container… sort of like an index
Containers and iterators work together to allow iteration

![2025Fall-06-Iterators, 页面 44](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=44)

end() never points to an element!
![2025Fall-06-Iterators, 页面 27](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=27)

![2025Fall-06-Iterators, 页面 33](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=33)



> [!NOTE] Aside: Why do we use ++it instead of it++?
>  ![2025Fall-06-Iterators, 页面 47](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=47)
> 首先，我们要明确这两个操作符的定义（和 `int` 的行为一致）：
> 
> - **前置 (`++it`)**：先加，后用。
>     - 口语：把自己加 1，然后把**现在的我**给你。
> - **后置 (`it++`)**：先用，后加。
>     - 口语：先把**刚才的我**给你，然后我自己加 1。
> 
> - 代码实现的区别（核心原因）
> 
> 为了实现“先把刚才的我给你”，代码必须**把“刚才的我”备份一份**。这就是那个“不必要的拷贝”的来源。
> 
> 让我们看看这两个操作符在 C++ 内部通常是怎么实现的（伪代码）：
> #### ✅ 前置 ++ (Prefix)
> 
> ```cpp
> // 只需要一步：加 1，返回自己
> Iterator& operator++() {
>     this->value += 1;  // 1. 真正干活
>     return *this;      // 2. 返回自己的引用（不用拷贝，极快）
> }
> 
> ```
> #### ❌ 后置 ++ (Postfix)
> 
> ```cpp
> // 需要三步：备份、加 1、返回备份
> Iterator operator++(int) {
>     Iterator temp = *this; // 1. 【关键】必须先创建一个临时副本，保存旧值
>     this->value += 1;      // 2. 自己加 1
>     return temp;           // 3. 返回那个旧的副本（发生值拷贝）
> }
> 
> ```
> 
> **看到了吗？** 后置 `it++` 必须创建一个 `temp` 对象。 如果你的迭代器只是一个简单的指针（比如 `vector` 的迭代器），这个拷贝可能很快。 但如果你的迭代器是一个复杂的对象（比如 `map` 或 `list` 的迭代器，或者自定义的重型迭代器），**拷贝它就需要分配内存、复制状态**，这在循环里执行几百万次，性能损耗就非常可观了。
> 
> C++ 这样设计是为了**逻辑自洽**。如果你写 `a = it++`，你期望 `a` 得到的是旧值，所以它必须拷贝旧值给你。
> **最佳实践：** 除非你真的需要用到旧值（比如 `arr[i++]` 这种写法），否则在写 `for` 循环时，**永远写 `++it`**。

> [!quote] Bjarne's Thoughts
> ++i is sometimes faster than, and is never slower than, i++. ... So if you are writing i++ as a statement rather than as part of a larger expression, why not just write ++i instead? You never lose anything, and you sometimes gain something.

### Iterators Types

![2025Fall-06-Iterators, 页面 68](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=68)

Iterators have a similar interface to pointers
`T*` is the backing type for `vector<T>::iterator`
In the real STL implementation, the actual type is not T*. 
But for all intents and purposes, you can think of it this way.

当然，对于复杂的iterator(map之类)，事实上我们需要用一个类去作为迭代器，而非指针。使用运算符重载去重载`++,&`这些操作，从而提供统一的接口。
![2025Fall-06-Iterators, 页面 92](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=92)

![2025Fall-06-Iterators, 页面 54](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=54)

![2025Fall-06-Iterators, 页面 59](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=59)

![2025Fall-06-Iterators, 页面 58](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=58)

`it1==it2 -> ++it1==++it2`表明**读取操作是无副作用的**，不会像一些流操作一样，读取一次便消耗一个数据。
这个公式证明了：**我们可以独立地、多次地访问同一个数据序列，而不会因为前一次的访问破坏了后一次的结果。**
![2025Fall-06-Iterators, 页面 61](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=61)


![2025Fall-06-Iterators, 页面 61](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=62)

![2025Fall-06-Iterators, 页面 61](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=63)

![2025Fall-06-Iterators, 页面 67](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=67)

### range-based

![2025Fall-05-Containers, 页面 43](files/slides/CS106L/2025Fall-05-Containers.pdf#page=43)

传引用零拷贝，比传值拷贝性能更高
![2025Fall-05-Containers, 页面 43](files/slides/CS106L/2025Fall-05-Containers.pdf#page=44)