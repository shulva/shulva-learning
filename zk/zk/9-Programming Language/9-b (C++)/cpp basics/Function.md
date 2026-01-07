# Function

## function  

> Definition: A predicate is a boolean-valued function **谓词是一个返回布尔值的函数**

![2025Fall-11-FunctionsAndLambdas, 页面 19](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=19)

> Key Idea: We need to pass a predicate to a function

Modifying our find function!
This condition worked for finding a specific value
but it is too specific. How can we modify it to handle a general condition?

```cpp
template <typename It, typename T>
It find(It first, It last, const T& value) { // const T& value -> ??? pred
    for (auto it = first; it != last; ++it) {
        if (*it == value) return it;
    }
    return last;
}
```

![2025Fall-11-FunctionsAndLambdas, 页面 25](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=25)

![2025Fall-11-FunctionsAndLambdas, 页面 28](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=28)

Passing functions allows us to generalize an algorithm with user-defined behaviour.
but... Seriously though, **what is the type of Pred?**
Here is the answer:

![2025Fall-11-FunctionsAndLambdas, 页面 34](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=34)

## Lambda

```cpp
// Function pointers generalize poorly.. redundant！
bool lessThan5(int x) { return x < 5; }
bool lessThan6(int x) { return x < 6; }
bool lessThan7(int x) { return x < 7; }

find_if(begin, end, lessThan5);
find_if(begin, end, lessThan6);
find_if(begin, end, lessThan7);

```

![2025Fall-11-FunctionsAndLambdas, 页面 36](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=36)

```cpp
// why this wouldn’t work? because.. the num of parameter in find function!
bool isLessThan(int elem, int n) { 
	return elem < n; 
}
```

![2025Fall-11-FunctionsAndLambdas, 页面 38](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=38)

>  We want to give our function extra state… without introducing another parameter 获取额外的状态（变量），但又不增加参数的数量

隆重介绍：Lambda! **Lambda 函数是可以从周围环境（外层作用域）捕获状态的函数**
![2025Fall-11-FunctionsAndLambdas, 页面 40](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=40)


![2025Fall-11-FunctionsAndLambdas, 页面 40](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=41)


![2025Fall-11-FunctionsAndLambdas, 页面 40](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=42)

我们不一定非要使用捕获！Lambda 同样非常适合用于定义临时函数
wait... What is `[](auto c)?`

```cpp
std::string corlys = "Lord of the tides";

auto it = find_if(corlys.begin(), corlys.end(),
    [](auto c) { // what is auto c?
        c = toupper(c); // 转为大写，以便统一比较
        return c == 'A' || c == 'E' || 
               c == 'I' || c == 'O' || c == 'U';
    }
);
```

![2025Fall-11-FunctionsAndLambdas, 页面 45](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=45)

### How do Lambda work?

> Definition: A functor is any object that defines an operator()
> In English: an object that acts like a function

![2025Fall-11-FunctionsAndLambdas, 页面 48](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=48)

**An example of a functor: `std::greater<T>`**
```cpp
template <typename T>
struct std::greater {
    // 重载了 () 操作符
    bool operator()(const T& a, const T& b) const {
        return a > b;
    }
};

std::greater<int> g; // g 是一个对象（Object），不是函数
g(1, 2); // false    // 但我们像调用函数一样调用它！

```

**Another STL functor: `std::hash<T>`**

![2025Fall-11-FunctionsAndLambdas, 页面 51](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=51)

> [!NOTE] Template Specialization
> 这是图中最关键的语法点：`template <> struct std::hash<MyType>`。
> 
> - **问题：** 编译器知道怎么 Hash 一个 `int`，但它不知道怎么 Hash 你自己写的 `MyType`（因为不知道类里有哪些数据重要）。
> - **解决：** 你不能修改标准库的源码，但 C++ 允许你“特化”标准库的模板。
> - **意思就是：** "虽然 `std::hash` 是标准库的，但如果有人用 `MyType` 来实例化它，请编译器**不要**用默认的通用版本，**请用我写的这一段代码**。"
>
> 如果你想把自定义的类 `MyType` 放进 `std::unordered_map` 或 `std::unordered_set` 中作为 **Key**，你需要：
>1. 写一个结构体 `std::hash<MyType>`。
>2. 在里面重载 `operator()`。
>3. 这就叫**模板特化**，也是 Functor 的一种实际应用。

> Since a functor is an object, it can have state

Functor 不仅仅是代码逻辑（Function），它还有数据（Data）。 它可以携带数据在程序中传递，直到被调用的那一刻。
```cpp
struct my_functor {
    // 重载 () 操作符
    int operator()(int a) const { 
        return a * value;
    }
    
    // 这就是 "State" (状态)
    int value; 
};

my_functor f;
f.value = 5;  // 我们给这个“函数”注入了一个状态：5
f(10);        // 调用它：10 * 5 = 50

```

普通函数（Function）通常是“无状态”的。
- **普通函数：** `int mul(int a)` —— 你没法在函数外部轻松地控制它内部乘多少，除非你传两个参数 `int mul(int a, int b)`。
- **仿函数：** `my_functor f` —— 它是一个**对象**。对象可以有成员变量（这里是 `int value`）。这个变量就是它的“状态”。

> When you use a lambda, a functor type is generated

**Lambda 其实只是“语法糖”（Syntactic Sugar），它的本质就是一个自动生成的类（Functor）。**
请看下面的例子：

This code...
```cpp
int n = 10; 
auto lessThanN = [n](int x) { return x < n; }; 
find_if(begin, end, lessThanN);
```

![2025Fall-11-FunctionsAndLambdas, 页面 57](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=57)


![2025Fall-11-FunctionsAndLambdas, 页面 60](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=60)

## Algorthims

![2025Fall-11-FunctionsAndLambdas, 页面 64](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=64)

`<algorithm>` is a collection of template functions
```cpp
// 统计 [first, last] 区间内满足谓词 p 的元素个数 
std::count_if(InputIt first, InputIt last, UnaryPred p); 

// 根据比较规则 comp 对 [first, last) 区间排序 
std::sort(RandomIt first, RandomIt last, Compare comp); 

// 根据比较规则 comp 找出最大元素 
std::max_element(ForwardIt first, ForwardIt last, Compare comp);
```

`<algorithm>`functions operate on iterators

```cpp

// 将 [r1, r2) 中满足条件 p 的元素拷贝到 o 指向的位置
std::copy_if(InputIt r1, InputIt r2, OutputIt o, UnaryPred p);


// 对 [r1, r2) 中的每个元素执行 op 操作，结果写入 o
std::transform(ForwardIt1 r1, ForwardIt1 r2, ForwardIt2 o, UnaryOp op);


// 将 [i1, i2) 中的元素拷贝到 o，但跳过连续重复的元素
std::unique_copy(InputIt i1, InputIt i2, OutputIt o, BinaryPred p);

```

![2025Fall-11-FunctionsAndLambdas, 页面 69](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=69)

## Example : Soundex

> Goal: produce a phonetic encoding for names

![2025Fall-11-FunctionsAndLambdas, 页面 75](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=75)

> 注：对于像 `std::set 或 std::map` 这种大小不能预先设定、需要动态插入元素的容器，你不能直接使用它们的迭代器作为输出目标。你需要使用一个**插入迭代器 (Insert Iterator)**。
> 插入迭代器是一种特殊的适配器，它将赋值操作 (=) 巧妙地转换成容器的 insert() 调用。你需要使用 `std::inserter`
> 对应作业的assignment4有使用样例

> **Hint: there is nothing preventing the range given by `first` from overlapping with the range given by `d_first`!**

![2025Fall-11-FunctionsAndLambdas, 页面 77](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=77)

```cpp
static char soundexEncode(char c)
{
    // 使用 static const map 确保映射表只初始化一次，提高效率
    static const std::map<char, char> encoding = {
        {'A', '0'}, {'E', '0'}, {'I', '0'}, {'O', '0'}, {'U', '0'}, {'H', '0'}, {'W', '0'}, {'Y', '0'},
        {'B', '1'}, {'F', '1'}, {'P', '1'}, {'V', '1'},
        {'C', '2'}, {'G', '2'}, {'J', '2'}, {'K', '2'}, {'Q', '2'}, {'S', '2'}, {'X', '2'}, {'Z', '2'},
        {'D', '3'}, {'T', '3'},
        {'L', '4'},
        {'M', '5'}, {'N', '5'},
        {'R', '6'}
    };
    
    // 将输入字符转为大写后查找映射
    return encoding.at(std::toupper(c));
}

std::string soundex(const std::string& s)
{
    // 1. 提取所有字母 (过滤掉标点和空格)
    std::string letters;
    std::copy_if(s.begin(), s.end(), std::back_inserter(letters), ::isalpha);

    // 2. 将字母转换为 Soundex 编码 (例如 B->1, C->2)
    // 注意：soundexEncode 是外部定义的转换函数
    std::transform(letters.begin(), letters.end(), letters.begin(), soundexEncode);

    // 3. 去除连续的重复编码
    std::string unique;
    std::unique_copy(letters.begin(), letters.end(), std::back_inserter(unique));

    // 4. 恢复首字母 (Soundex 规则：首字母保持原样并大写)
    // 注意：这里假设 letters 非空，实际生产代码需检查 empty()
    char first_letter = letters[0];
    unique[0] = std::toupper(first_letter);

    // 5. 去除编码中的 '0' (通常用于忽略元音的占位符)
    // 注意：notZero 是外部定义的谓词
    std::string no_zeros;
    std::copy_if(unique.begin(), unique.end(), std::back_inserter(no_zeros), notZero);

    // 6. 标准化长度：补零并截取前4位
    no_zeros += "0000";
    return no_zeros.substr(0, 4);
}

```

## Ranges and Views

Can we make our Soundex more readable? we need use ranges...
Ranges are a new version of the STL
> Definition: A range is anything with a begin and end

![2025Fall-11-FunctionsAndLambdas, 页面 88](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=88)

> why did we pass iterators to find?

It allows us to find in a subrange! But most of the time, we do not need to.
Do we really care about iterators here(`std::find..`)? I just wanted to search the entire container!

```cpp
int main() { 
	std::vector<char> v = {'a', 'b', 'c', 'd', 'e’}; 
	auto it = std::find(v.begin(), v.end(), 'c'); 
}
```

> Range algorithms operate on ranges

STD ranges provides new versions of `<algorithm>` for ranges

```cpp
int main() { 
	std::vector<char> v = {'a', 'b', 'c', 'd', 'e’};
	auto it = std::ranges::find(v, 'c'); // Look! I can pass v here because it is a range!
}
```

We can still work with iterators if we need to
```cpp
int main() { 
	std::vector<char> v = {'a', 'b', 'c', 'd', 'e'}; // Search from 'b' to 'd’ 
	auto first = v.begin() + 1; 
	auto last = v.end() - 1; 
	auto it = std::ranges::find(first, last, 'c');
}
```

![2025Fall-11-FunctionsAndLambdas, 页面 92](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=92)


![2025Fall-11-FunctionsAndLambdas, 页面 92](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=93)

> Views: a way to compose algorithms
   Definition: A view is a range that lazily adapts another range

old STL without ranges and views:
```cpp
std::vector<char> v = {'a', 'b', 'c', 'd', 'e'};

// 1. Filter -- Get only the vowels (过滤：只保留元音)
// 痛点：必须显式创建一个中间容器 f 来存储过滤后的结果
std::vector<char> f;
std::copy_if(v.begin(), v.end(), std::back_inserter(f), isVowel);

// 2. Transform -- Convert to uppercase (变换：转为大写)
// 痛点：必须再创建一个容器 t 来存储最终结果
std::vector<char> t;
std::transform(f.begin(), f.end(), std::back_inserter(t), toupper);

// 最终结果 t: { 'A', 'E' }

```
> Filter and transform with views!

A view is a range that lazily transforms its underlying range, one element at a time
```cpp
std::vector<char> letters = {'a', 'b', 'c', 'd', 'e'};

// 1. 创建过滤视图 (Filter View)
// 此时 f 不是一个新的容器，它只是一个"轻量级对象"，记录了过滤逻辑
auto f = std::ranges::views::filter(letters, isVowel);

// 2. 创建变换视图 (Transform View)
// t 也是一个视图，它在 f 的基础上叠加了变换逻辑
auto t = std::ranges::views::transform(f, toupper);

// 3. 实体化 (Materialization) - C++23 特性
// 只有到了这一步，数据才真正被处理，并转换回 vector
auto vowelUpper = std::ranges::to<std::vector<char>>(t);

```

---

> [!NOTE] 什么是 View (视图)？
> 图片中有一句非常重要的定义：
> > **"A view is a range that lazily transforms its underlying range, one element at a time"**
> > (视图是一个范围，它**惰性地 (Lazily)** 转换其底层范围，一次处理一个元素)
> 
>  1. 惰性求值 (Lazy Evaluation)
> 在上一张图的旧代码中，`copy_if` 执行完后，内存里就已经产生了一个装满数据的 `vector`。
> 而在本图中，执行完 `auto f = ...` 和 `auto t = ...` 时，**什么计算都没有发生**，也没有分配额外的内存来存字符。
> *   `f` 只是记录了：“我要从 `letters` 里拿数据，只拿元音。”
> *   `t` 只是记录了：“我要从 `f` 里拿数据，并把它转大写。”
> 
>  2. 无中间容器 (No Intermediate Allocation)
> 这是最大的性能优势。
> *   **旧方法：** `letters` -> `temp_vector_1` -> `temp_vector_2`
> *   **新方法：** `letters` -> (通过管道直接处理) -> `vowelUpper`
> 数据元素是按需（on-demand）被拉取出来的，中间不需要创建临时的 `vector` 来存储半成品。
> 
>  3. `std::ranges::to` (C++23)
> 注意最后一行 `std::ranges::to`。这是 C++23 才正式加入的标准库功能（虽然常与 C++20 Ranges 一起讨论）。它的作用是将一个“虚”的视图，真正转换成一个“实”的容器（如 `vector`）。
> 
> 你只需要告诉编译器 **“我想做什么”** (过滤、转换)，而不是 **“怎么做”** (循环、分配内存、拷贝)。

---
```cpp
// 1. 创建过滤视图
// f 是一个视图！它接收底层范围 letters，
// 并产生一个新的、只包含元音的范围！
auto f = std::ranges::views::filter(letters, isVowel);

// 2. 组合变换视图
// t 是一个视图！它接收底层范围 f (注意这里接收的是上一步的视图)，
// 并产生一个新的、包含大写字符的范围！
auto t = std::ranges::views::transform(f, toupper);

// 3. 实体化 (Materialization)
// 这里我们将视图实体化为一个 vector！
// 在这一行之前，实际上什么都没有发生！(没有遍历，没有计算)
auto vowelUpper = std::ranges::to<std::vector<char>>(t);

```

> We can chain views together use operator `|`

很舒服 不需要什么中间变量名了
```cpp
std::vector<char> letters = {'a', 'b', 'c', 'd', 'e'};

// 使用管道操作符 | 将视图链接在一起
std::vector<char> upperVowel = letters
    | std::ranges::views::filter(isVowel)      // 1. 过滤：只留元音
    | std::ranges::views::transform(toupper)   // 2. 变换：转大写
    | std::ranges::to<std::vector<char>>();    // 3. 收集：转回 vector (C++23)

// upperVowel = { 'A', 'E' }
```

虽然`views`是惰性的，但是**动词**类型的算法（如 `sort`, `reverse`, `shuffle`）时，**它们依然是立即执行的**，不会等到你“收集”结果时才执行。

![2025Fall-11-FunctionsAndLambdas, 页面 105](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=105)


![2025Fall-11-FunctionsAndLambdas, 页面 108](files/slides/CS106L/2025Fall-11-FunctionsAndLambdas.pdf#page=108)

> In Cpp 26...?

```cpp
namespace rng = std::ranges;
namespace rv = std::ranges::views;

// 1. 获取首字母 (Get first letter)
auto ch = *rng::find_if(s, isalpha);

// 2. 构建处理管道 (Build the pipeline)
auto sx = s | rv::filter(isalpha)              // Discard non-letters (过滤非字母)
            | rv::transform(soundexEncode)     // Encode letters (编码字母)
            | rv::unique                       // Remove duplicates (去重)
            | rv::filter(notZero)              // Remove zeros (去除零)
            | rv::concat("0000")               // Ensure length >= 4 (补全长度，C++26 特性)
            | rv::drop(1)                      // Skip first digit (跳过第一位)
            | rv::take(3)                      // Take next three (取接下来的三位)
            | rng::to<std::string>();          // Convert to string (转回字符串, C++23)

// 3. 返回结果
return toupper(ch) + v; 

```