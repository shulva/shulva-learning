# Smart Pointers And RAII

## intro

> How many code paths? 2?

```cpp
std::string returnNameCheckPawsome(Pet p) {
    /// NOTE: dogs > cats
    if (p.type() == "Dog" || p.firstName() == "Fluffy") {
        std::cout << p.firstName() << " "
                  << p.lastName() << " is paw-some!" << '\n';
    }
    return p.firstName() + " " + p.lastName();
}
```

![2025Fall-16-RAII-SmartPointers, 页面 15](files/slides/CS106L/2025Fall-16-RAII-SmartPointers.pdf#page=15)


![2025Fall-16-RAII-SmartPointers, 页面 12](files/slides/CS106L/2025Fall-16-RAII-SmartPointers.pdf#page=12)

```cpp
std::string returnNameCheckPawsome(int petId) {
    Pet* p = new Pet(petId); // ❌ exception here means memory leak

    if (p->type() == "Dog" || p->firstName() == "Fluffy") {
        std::cout << p->firstName() << " "
                  << p->lastName() << " is paw-some!" << '\n';
    }

    std::string returnStr = p->firstName() + " " + p->lastName();
    delete p;  // ❌ exception here means memory leak
    return returnStr;
}

```
> It turns out that there are many resources that you need to **release** after **acquiring**...
> How do we ensure that we properly release resources in the case that we have an exception?

| **Resource** | **Acquire** | **Release** |
| ------------ | ----------- | ----------- |
| Heap memory  | `new`       | `delete`    |
| Files        | `open`      | `close`     |
| Locks        | `try_lock`  | `unlock`    |
| Sockets      | `socket`    | `close`     |

## RAII

> [!question] RAII: Resource Acquisition is Initialization 
> RAII was developed by this lad: Bjarne
> And it's a concept that is very emblematic in C++, among other languages. 
> So what is RAII? 
> - All resources used by a class should be acquired in the constructor 
> - All resources that are used by a class should be released in the destructor.
>
> 当你创建一个对象的时候（比如在构造函数里），它就会**自动去申请资源**（内存、文件句柄、锁、socket 等）。  
> 当这个对象生命周期结束、离开作用域时，它的**析构函数会自动释放这些资源**。
> 这样，资源的生命周期就被「绑在」对象的生命周期上了，而不是到处写 `new` / `delete`、`open` / `close` 去手动管理。

#####  By abiding by the RAII policy we avoid 'half-valid' states.

**半有效（half-valid）状态**指的是：  
一个对象 / 资源只“初始化了一半”，现在既不能正常用，又没完全失败——非常危险、容易出 bug。

例子（非 RAII 风格）：
```cpp
File* f = new File();
f->open("data.txt");
// 这里如果 open 失败，f 这个指针在，但底层文件没成功打开
// 这就是 "half-valid" 状态
```

 RAII 风格：
```cpp
std::ifstream file("data.txt"); // 构造时就尝试打开
if (!file) {
    // 构造失败直接报错 / 抛异常
}
```

- 按 RAII 设计：对象一旦构造成功，就**处于完全可用**状态；
- 如果不能保证可用，就干脆构造失败（抛异常 / 标记无效），不会产生「看起来存在，但用起来不对」的半吊子对象。


![2025Fall-16-RAII-SmartPointers, 页面 29](files/slides/CS106L/2025Fall-16-RAII-SmartPointers.pdf#page=29)


如下代码便没有遵循RAII: the ifstream is opened and closed in code, not constructor & destructor
```cpp
void printFile() {
    std::ifstream input;
    input.open("hamlet.txt");

    std::string line;
    while (getline(input, line)) {   // might throw an exception
        std::cout << line << std::endl;
    }

    input.close();
}

```

#####  **No matter what, the destructor is called whenever the resource goes out of scope.**

- 只要对象是**自动对象（栈上局部变量）**：
  - 代码块结束、函数返回、抛异常离开作用域时，
  - **编译器保证一定会调用析构函数**。

这就解决了如下的问题：
```cpp
Pet* p = new Pet(petId);
// 中间如果抛异常，就永远走不到 delete p; → 内存泄漏
delete p;
```

用 RAII（比如 `std::unique_ptr<Pet>`）：
```cpp
std::unique_ptr<Pet> p = std::make_unique<Pet>(petId);
// 这里抛异常也没关系
// 退出作用域时，unique_ptr 的析构会自动 delete Pet
```

 不管是正常 return，还是异常跳出，  
 只要对象离开作用域，它的析构函数就一定会执行，资源一定被释放。  
 这就是 RAII 解决“忘记释放 / 异常导致不释放”的方法。

如下代码同样：一旦`lock()`与`unlock()`之间抛出了异常，那么就发生了资源泄露

```cpp
void cleanDatabase(std::mutex& databaseLock, std::map<int, int>& db) {
    databaseLock.lock();

    // no other thread or machine can change database
    // modify the database
    // if any exception is thrown, the lock never unlocks!

    databaseLock.unlock();
}

```
#####  **One more thing: the resource/object is usable immediately after it is created.**

这条是说：  
RAII 要求**在构造函数里就完成资源获取**，所以：

- 对象一构造完，就已经把该拿的资源拿好了（内存分配、文件打开、锁获取……）
- 之后直接用它，不需要额外再调用什么 `init()`、`open()` 之类的函数。

例子：
A lock guard is a RAII-compliant wrapper that attempts to acquire the passed in lock. It releases the the lock once it goes out of scope. Read more [here](https://en.cppreference.com/w/cpp/thread/lock_guard.html#:~:text=The%20class%20lock_guard%20is%20a,the%20mutex%20it%20is%20given.)
```cpp
std::lock_guard<std::mutex> guard(m); 
// 构造时就加锁
// 后面的代码可以安全使用共享数据
// 作用域结束时自动解锁
```

- 简化心智负担：看到对象构造成功，就可以放心用；
- 不会出现「构造好了，但我忘了调用 init/open」这种坑。

## Smart Pointers


> RAII for locks → lock_guard 
> Created a new object that acquires the resource in the constructor and releases in the destructor

So for the memory , we can do the same...

![2025Fall-16-RAII-SmartPointers, 页面 50](files/slides/CS106L/2025Fall-16-RAII-SmartPointers.pdf#page=50)

```cpp
void rawPtrfn(){

	// ❌
	Node* n = new Node();
	delete n;

	//✅
	std::unique_ptr<Node> n(New Node());
}
```

> Remember we can't copy unique pointers

![2025Fall-16-RAII-SmartPointers, 页面 55](files/slides/CS106L/2025Fall-16-RAII-SmartPointers.pdf#page=55)

> `std::shared_ptr`

![2025Fall-16-RAII-SmartPointers, 页面 57](files/slides/CS106L/2025Fall-16-RAII-SmartPointers.pdf#page=57)

> We're still explicitly calling `new`  
> No! we need something new!

```cpp
// std::unique_ptr<T> uniquePtr{ new T };
std::unique_ptr<T> uniquePtr = std::make_unique<T>();

// std::shared_ptr<T> sharedPtr{ new T };
std::shared_ptr<T> sharedPtr = std::make_shared<T>();

std::weak_ptr<T> wp = sharedPtr;
```

![2025Fall-16-RAII-SmartPointers, 页面 62](files/slides/CS106L/2025Fall-16-RAII-SmartPointers.pdf#page=62)


> `std::weak_ptr` Weak pointers are a way to avoid circular dependencies in our code so that we don't leak any memory.

`std::weak_ptr`最多的使用场景就是解决循环引用问题：
![2025Fall-16-RAII-SmartPointers, 页面 66](files/slides/CS106L/2025Fall-16-RAII-SmartPointers.pdf#page=66)


![2025Fall-16-RAII-SmartPointers, 页面 66](files/slides/CS106L/2025Fall-16-RAII-SmartPointers.pdf#page=67)
