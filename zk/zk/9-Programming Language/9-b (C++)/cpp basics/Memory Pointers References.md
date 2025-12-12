# Memory

地址空间从下方的0x0 -> 2\^64-1
![2025Fall-06-Iterators, 页面 74](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=74)


![2025Fall-06-Iterators, 页面 76](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=76)

# Pointers

A pointer is just a number
![2025Fall-06-Iterators, 页面 80](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=80)


![2025Fall-06-Iterators, 页面 80](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=85)

连续的内存，我们可以用指针这样操作:
![2025Fall-06-Iterators, 页面 87](files/slides/CS106L/2025Fall-06-Iterators.pdf#page=87)

# References

> [!quote] what is reference
> Declares a name variable as a reference” tldr: a reference is an alias to an already-existing thing
> [link](https://en.cppreference.com/w/cpp/language/reference.html)

```cpp
int num = 5;    //num is a variable of type int, that is assigned to have the value 5
int& ref = num; //ref is a variable of type int&, that is an alias to num
ref = 10;       //So when we assign 10 to ref, we also change the value of num, since ref is an alias for num
std::cout << num << std::endl; // Output: 10
```

有点抽象的图：
![2025Fall-03-InitializationAndReferences, 页面 50](files/slides/CS106L/2025Fall-03-InitializationAndReferences.pdf#page=50)


### pass by value and pass by reference

Passing in a variable by **value** into a function just means “Hey make a copy, do not take in the actual variable!”
![2025Fall-03-InitializationAndReferences, 页面 57](files/slides/CS106L/2025Fall-03-InitializationAndReferences.pdf#page=57)

Passing in a variable by **reference** into a function just means “Hey take in the actual piece of memory, do not make a copy!”


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