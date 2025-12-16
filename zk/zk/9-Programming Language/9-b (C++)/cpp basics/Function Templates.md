# Function Templates

![2025Fall-10-TemplateFunctions, 页面 146](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=146)

## Template Functions

```cpp
// ------------- take this...
int min(int a, int b) { 
	return a < b ? a : b; 
} 
double min(double a, double b) { 
	return a < b ? a : b; 
} 
std::string min(std::string a, std::string b) { 
	return a < b ? a : b; 
}

// ------------- into this
template <typename T> 
T min(const T& a, const T& b) {  // we can also use reference to avoid copy
	return a < b ? a : b; 
}
```

![2025Fall-10-TemplateFunctions, 页面 22](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=22)

#### How do we call  template functions?

> [!NOTE] Option A: explicit instantiation
> 显式指明类型
> Template functions cause the compiler to generate code for us
> 
> ```cpp
> int min(int a, int b) {              // Compiler generated
>     return a < b ? a : b;            // Compiler generated
> }                                    // Compiler generated
> 
> double min(double a, double b) {     // Compiler generated
>     return a < b ? a : b;            // Compiler generated
> }                                    // Compiler generated
> 
> min<int>(106, 107);                  // Returns 106
> min<double>(1.2, 3.4);               // Returns 1.2
> ```

> [!NOTE] Option B: implicit instantiation
> 不指明类型
> Implicit instantiation lets the compiler **infer** the types for us
> Implicit instantiation is kind of like **auto**
> 
> ```cpp
> // didn’t specify any template types!
> min(106, 107); // int, returns 106 
> min(1.2, 3.4); // double, returns 1.2
> ```


![2025Fall-10-TemplateFunctions, 页面 32](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=32)


![2025Fall-10-TemplateFunctions, 页面 33](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=33)


![2025Fall-10-TemplateFunctions, 页面 33](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=34)

不过，你搞不清楚的时候，也可以使用auto，把锅甩给编译器就是了
很多时候，也可以使用IDE的智能提示搞明白
![2025Fall-10-TemplateFunctions, 页面 33](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=37)

![2025Fall-10-TemplateFunctions, 页面 38](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=38)

## Concepts

```cpp
template <typename T> 
T min(const T& a, const T& b) { 
	return a < b ? a : b; 
} 
// For which T will the following compile successfully? 
T a = /* an instance of T */; 
T b = /* an instance of T */; 
min<T>(a, b);

struct StanfordID; // How do we compare two IDs? 
StanfordID thomas { ”Thomas", ”tpoimen" }; 
StanfordID rachel { ”Rachel", ”rfern" }; 
min<StanfordID>(thomas, rachel); // ❌Compiler error
```

显然，编译器不知道如何比对这个类型
但是，编译器必须在模板实例化之后才能发现这个错误

![2025Fall-10-TemplateFunctions, 页面 60](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=60)

模板的报错纯纯天书

![2025Fall-10-TemplateFunctions, 页面 60](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=62)

> **Idea: How do we put constraints on templates?**

例如约束：`T must have operator<`

![2025Fall-10-TemplateFunctions, 页面 60](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=65)

于是，cpp20引入了Concepts解决模板的问题

![2025Fall-10-TemplateFunctions, 页面 74](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=74)

Using our Comparable concept
```cpp
template <typename T> requires Comparable<T> 
T min(const T& a, const T& b);

// Super slick shorthand for the above
template <Comparable T> 
T min(const T& a, const T& b);
```

用了Concepts，报错就显明多了
![2025Fall-10-TemplateFunctions, 页面 77](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=77)


cpp有很多内建的[concepts](https://en.cppreference.com/w/cpp/concepts.html)以及[iterator concepts](https://en.cppreference.com/w/cpp/iterator.html#Iterator_concepts_.28since_C.2B.2B20.29)

![2025Fall-10-TemplateFunctions, 页面 77](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=81)

## Variadic Templates

如果我们希望我们的函数可以接收不定长的参数，我们该怎么做？
如下图？但是我们不可能无止境的递归下去
```cpp
template <Comparable T> 
T min(const T& a, const T& b) { 
	return a < b ? a : b; 
}

template <Comparable T>
T min(const T& a, const T& b) { return a < b ? a : b; }

template <Comparable T>
T min(const T& a, const T& b, const T& c) {
    auto m = min(b, c);       // 3 element overload calls 2 element
    return a < m ? a : m;
}
// Seems almost recursive!

```

或许，我们可以用模板生成代码的方式？
使用vector，以`min({ 2.4, 7.5, 5.3, 1.2 });`的方式来接收参数
![2025Fall-10-TemplateFunctions, 页面 96](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=96)

显然，vector的拷贝（虽然能避免）以及每次call函数都需要分配一次vector对性能有损耗
而且，我们真正想要的是这种形式：`min(2.4, 7.5, 5.3, 1.2, 3.4, 6.7, 8.9, 9.1);` 而不是传一个vector进去

![2025Fall-10-TemplateFunctions, 页面 97](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=97)


于是，正式引入Variadic Templates

![2025Fall-10-TemplateFunctions, 页面 107](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=107)

编译器会根据模板帮助我们生成实例，并递归下去

![2025Fall-10-TemplateFunctions, 页面 118](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=118&selection=0,7,0,12)

直到最后

![2025Fall-10-TemplateFunctions, 页面 122](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=122)

A single call to min(2, 7, 5, 1) generated the following functions
```cpp
min(2, 7, 5, 1); 
min<int, int, int, int> // T = int, Args = [int, int, int] 
min<int, int, int>      // T = int, Args = [int, int] 
min<int, int>           // T = int, Args = [int] 
min<int>                // T = int
```


而且，变长模板参数相对于vector方案还有一个好处，就是参数类型可以不同

![2025Fall-10-TemplateFunctions, 页面 125](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=125)

例如format:
![2025Fall-10-TemplateFunctions, 页面 128](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=128)

```cpp
format("Lecture {}: {} (Week {})", 9, "Templates", 5);

format<int, std::string, int>()
// T = int, Args = [std::string, int]

format<std::string, int>()
// T = std::string, Args = [int]

format<int>()
// T = int, Args = []

format()
// Base case! Not a template, no type arguments

```

![2025Fall-10-TemplateFunctions, 页面 130](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=130)
---

## Template Metaprogramming

黑魔法，看个乐子就好
![2025Fall-10-TemplateFunctions, 页面 140](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=140)

![2025Fall-10-TemplateFunctions, 页面 133](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=133)

编译期完成递归计算
![2025Fall-10-TemplateFunctions, 页面 135](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=135)

How can we have:
- Compile-time execution
- Readable code

![2025Fall-10-TemplateFunctions, 页面 143](files/slides/CS106L/2025Fall-10-TemplateFunctions.pdf#page=143)