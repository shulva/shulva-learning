# What is cpp?

> "Nobody should call themselves a professional if they only know one language"
> ——Bjarne Stroustrup
## Cpp is a compiled language

The compiler translates the ENTIRE program, packages it into an executable file, and then executes it

![2025Fall-02-TypesAndStructs, 页面 18](files/slides/CS106L/2025Fall-02-TypesAndStructs.pdf#page=18)


![2025Fall-02-TypesAndStructs, 页面 18](files/slides/CS106L/2025Fall-02-TypesAndStructs.pdf#page=20)


![2025Fall-02-TypesAndStructs, 页面 18](files/slides/CS106L/2025Fall-02-TypesAndStructs.pdf#page=32)


## C++ is a statically typed language

We know that the compiler checks for types before generating machine code.
This means C++ is a statically typed language20

![2025Fall-02-TypesAndStructs, 页面 18](files/slides/CS106L/2025Fall-02-TypesAndStructs.pdf#page=41)

## std


![2025Fall-02-TypesAndStructs, 页面 18](files/slides/CS106L/2025Fall-02-TypesAndStructs.pdf#page=77)


### pass by value and pass by reference

Passing in a variable by **value** into a function just means “Hey make a copy, don’t take in the actual variable!”

Passing in a variable by **reference** into a function just means “Hey take in the actual piece of memory, don’t make a copy!”


以下是一个经典的reference-copy bug
```cpp
  #include <iostream> 
  #include <math.h> 
  #include <vector> 
  void shift(std::vector<std::pair<int, int>> &nums) 
  { 
  	for (auto [num1, num2] : nums) 
  	{ 
  		num1++; 
  		num2++; 
  	} 
  }
  ``` 

这里的 `auto` 会进行**值拷贝 (Pass by Value)**。

1. 编译器把 `nums` 中的每一个 `pair` 拿出来。
2. **复制**一份数据，拆解给 `num1` 和 `num2`。
3. 你在循环体里执行 `num1++`，实际上是在**修改这份临时的复印件**。
4. 循环结束后，复印件被销毁，`nums` 里的**原件毫发无损**。

解决方法也很简单，给auto加上&即可。
 
 
 
 
