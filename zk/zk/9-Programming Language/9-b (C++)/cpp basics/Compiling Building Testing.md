## compiling 

假设我们要用g++编译一个程序

`g++ -std=c++23 main.cpp -o main`

- `g++` : This is the compiler command
- `-std=c++23` : This specifies the c++ version you want to compile in
- `main.cpp` : This is the source file
- `-o` : This means that you are going to give a specific name to your executable
- `main` : In this case it is main

`g++ -std=c++23 main.cpp` This is also valid, your executable will be something like `a.out`  

## Building C++ projects

> make and makefile

![2025Fall-16-RAII-SmartPointers, 页面 80](files/slides/CS106L/2025Fall-16-RAII-SmartPointers.pdf#page=80)

```makefile
# Compiler
CXX = g++

# Compiler flags
CXXFLAGS = -std=c++20

# Source files and target
SRCS = $(wildcard *.cpp)
TARGET = main

# Default target
all:
	$(CXX) $(CXXFLAGS) $(SRCS) -o $(TARGET)

# Clean up
clean:
	rm -f $(TARGET)
```

但是，直接手写makefile还是有点太麻烦了

> For making our Makefiles we can and should use CMAKE

![2025Fall-16-RAII-SmartPointers, 页面 83](files/slides/CS106L/2025Fall-16-RAII-SmartPointers.pdf#page=83)

> 下面是一个CMakeLists.txt的示例

```cmake
cmake_minimum_required(VERSION 3.10)

project(cs1061_classes)

set(CMAKE_CXX_STANDARD 20) // This command tells CMAKE to set the C++ compiler to C++20

file(GLOB SRC_FILES "*.cpp") // This GLOB command is telling the CMAKE program to do a wildcard search for all                                // files that have the pattern “*.cpp

add_executable(main ${SRC_FILES}) // This command adds all of the source files of our program into the executable

```

![2025Fall-16-RAII-SmartPointers, 页面 88](files/slides/CS106L/2025Fall-16-RAII-SmartPointers.pdf#page=88)

## Testing

> So... What is Unit Testing?

[IBM](https://www.ibm.com/think/topics/unit-testing):Unit testing is a test-driven development (TDD) method for evaluating software that pays special attention to an individual component or unit of code—the smallest increment possible

![2025Fall-17-UnitTesting, 页面 6](files/slides/CS106L/2025Fall-17-UnitTesting.pdf#page=6)

> How to ?

![2025Fall-17-UnitTesting, 页面 11](files/slides/CS106L/2025Fall-17-UnitTesting.pdf#page=11)

> Why should we...?

![2025Fall-17-UnitTesting, 页面 15](files/slides/CS106L/2025Fall-17-UnitTesting.pdf#page=15)

### Google Test

虽然市面上有很多测试框架，但是**Google Test 仍然是事实上的主流**

![2025Fall-17-UnitTesting, 页面 24](files/slides/CS106L/2025Fall-17-UnitTesting.pdf#page=24)

> 感谢Google诸神！

![2025Fall-17-UnitTesting, 页面 44](files/slides/CS106L/2025Fall-17-UnitTesting.pdf#page=44)


现在，假设我们有一个类需要测试:

```cpp
// .h -------------------------------------
#ifndef __BANK_ACCOUNT_H__
#define __BANK_ACCOUNT_H__

struct BankAccount {
    // member variables
    double balance;

    // constructors
    BankAccount();
    explicit BankAccount(const double initial_balance);

    // member functions
    void deposit(double amount);
    bool withdraw(double amount);
};

#endif // __BANK_ACCOUNT_H__

// .cpp -----------------------------------

#include "bank_account.h"

// default constructor initializes to balance of 0
BankAccount::BankAccount()
    : balance(0) {}

// custom constructor that initializes balance to initial_balance
BankAccount::BankAccount(const double initial_balance)
    : balance(initial_balance) {}

// deposit amount into the account
void BankAccount::deposit(double amount) {
    balance += amount;
}

// withdraws amount from balance if funds exist.
bool BankAccount::withdraw(double amount) {
    if (amount <= balance) {
        balance -= amount;
        return true;
    }
    return false;
}

```

> 最基本的测试宏：TEST

 `TEST(TestSuiteName, TestName) { ... }`

`TEST` 是 gtest 提供的一个宏，用来**定义一个“单独的测试用例”**：

- 第一个参数 `TestSuiteName`：  
    测试套件的名字，可以理解为“这一组测试”的名字。  
    这里是 `AccountTest`，意思是“跟账户相关的测试们”。
    
- 第二个参数 `TestName`：  
    具体这一个测试的名字。  
    这里是 `BankAccountStartsEmpty`，意思是“BankAccount 一开始应该是空的”。

Google Test 在编译期会把这个宏展开成一个函数，并自动登记到测试框架里，`RUN_ALL_TESTS()` 时就会调用它。

```cpp
TEST(AccountTest, BankAccountStartsEmpty) {
    BankAccount* account = new BankAccount;
    EXPECT_EQ(0, account->balance);
    delete account;
}
```

`EXPECT_EQ(0, account->balance);`
- 这是 gtest 的**断言**：检查“实际值是否等于期望值”。
- 语义：**期望（expect）账户的余额 `account->balance` 等于 0**。
- 如果不等于 0，这个测试会标记为失败，并打印出期望值/实际值的差异。

> 测试宏TEST_F
> Hm… this looks the same. What changed?

![2025Fall-17-UnitTesting, 页面 32](files/slides/CS106L/2025Fall-17-UnitTesting.pdf#page=32)


![2025Fall-17-UnitTesting, 页面 32](files/slides/CS106L/2025Fall-17-UnitTesting.pdf#page=33)


> [!NOTE] `TEST_F` 和 `TEST` 的核心区别
> - `TEST(SuiteName, TestName)`  
>     每个测试自己 new / delete，环境自己搭，彼此独立。
>     
> - `TEST_F(FixtureName, TestName)`  
>     先定义一个 **测试夹具类 `FixtureName`**，在里面写好：
>     - `SetUp()`：每个测试运行前自动执行（初始化环境）
>     - `TearDown()`：每个测试运行后自动执行（清理资源）
>     - 成员变量：各个测试共享这套“起始状态”
>     然后 `TEST_F` 里就可以直接用这些成员，不用再重复 new / delete。

![2025Fall-17-UnitTesting, 页面 32](files/slides/CS106L/2025Fall-17-UnitTesting.pdf#page=34)

> TEST_P : 应对参数化场景

`TEST_P` 允许你把**测试逻辑和测试数据**分开写。  
你给它多组数据，它就自动生成多条测试，用非常简洁的方式批量创建测试用例。

这个 struct 就是：**一次取款测试需要的所有参数**打包在一起
这里重载 `operator<<` 是为了当测试失败时，Google Test 能把这个 struct 打印得更好

`WithdrawAccountTest`- 
继承自`BankAccountTest`：之前的测试fixture（里面有 `BankAccount* account` 或 `BankAccount account` 等公共测试环境）。
- `testing::WithParamInterface<account_state>`：
    - 告诉 gtest：  
        “这是一个**参数化测试夹具**，每次运行会给我一个 `account_state` 类型的参数。”
    - `GetParam()` 就是用来读取当前这次的参数。

`account->balance = GetParam().initial_balance;`
每次测试开始前，把账户余额设置成这次参数里指定的 `initial_balance`。


![2025Fall-17-UnitTesting, 页面 36](files/slides/CS106L/2025Fall-17-UnitTesting.pdf#page=36)

> Here is Our TEST_P!
> But hold on...  What are the parameters? Where are they coming from? Who is defining them?

```cpp
TEST_P(WithdrawAccountTest, FinalBalance) {
    auto as = GetParam();
    auto success = account->withdraw(as.withdraw_amount);

    EXPECT_EQ(as.final_balance, account->balance);
    EXPECT_EQ(as.success,       success);
}
```

> Parameterized tests need to be instantiated!

Using a `DEFAULT` name, create a parameterized test on the `WithdrawAccountTest` test suite, using the parameters `testing::Values(…)` 

`Test:TEST_P` Providing multiple sets of values results in multiple tests! Super clean way of instantiating lots of tests!

```cpp
INSTANTIATE_TEST_SUITE_P(
    DEFAULT,                 // 实例化前缀名
    WithdrawAccountTest,     // 使用的测试夹具（fixture）
    testing::Values(         // 一组参数
        account_state{100,  50,  50,  true},   // 初始 100，取 50 → 剩 50，成功
        account_state{100, 200, 100, false}    // 初始 100，取 200 → 剩 100，失败
    )
);
```