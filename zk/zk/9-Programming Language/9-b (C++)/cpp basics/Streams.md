# Streams

### what are streams?

Streams: a general input/output facility for C++

![2025Fall-04-Streams, 页面 28](files/slides/CS106L/2025Fall-04-Streams.pdf#page=28)

**basic_ios** ensures the stream is working correctly and where the stream comes from! maybe it is the console, keyboard, or a file

中间的相交部分是iostream(This intersection is known as iostream which takes has all of the characteristics of ostream and istream!)

![2025Fall-04-Streams, 页面 28](files/slides/CS106L/2025Fall-04-Streams.pdf#page=33)


![2025Fall-04-Streams, 页面 28](files/slides/CS106L/2025Fall-04-Streams.pdf#page=42)

### stringstreams

stringstreams is a way to **treat strings as streams **
stringstreams are useful for use-cases that deal with mixing data types

```cpp
void foo() 
{
	/// partial Bjarne Quote 
	std::string initial_quote = “Bjarne Stroustrup C makes it easy to shoot yourself in the foot\n”; 
	
	/// create a stringstream 
	std::stringstream ss(initial_quote); 
	
	// since this is a stream we can also insert the initial_quote like this!
	// ss << initial_quote;
	
	/// data destinations 
	std::string first; 
	std::string last; 
	std::string language, extracted_quote; 
	ss >> first >> last >> language >> extracted_quote; 

	std::cout << first << “ ” << last << “ said this: ”<< language << “ “ << extracted_quote << std::endl;
} 

```

We want to extract the quote , but we have >> problems ! So we can use getline() instead .

![2025Fall-04-Streams, 页面 28](files/slides/CS106L/2025Fall-04-Streams.pdf#page=70)

### cout and cin

btw:[cerr and clog](https://www.geeksforgeeks.org/cpp/difference-between-cerr-and-clog/)
contents in buffer not shown on external source until an explicit flush occurs!

![2025Fall-04-Streams, 页面 28](files/slides/CS106L/2025Fall-04-Streams.pdf#page=76)

![2025Fall-04-Streams, 页面 28](files/slides/CS106L/2025Fall-04-Streams.pdf#page=78)

> [!NOTE] 输出缓冲区：std::endl 与 \n
> 
> 通常我们的理念是：
> - `\n` = 仅仅换行。
> - `std::endl` = 换行 + 强制刷新缓冲区（Flush）。
> 
> **但事实上，即使只用了 `\n`，数据也会被立即打印出来（刷新了），表现得和 `std::endl` 一模一样。**
> 
> 2. 原因揭秘：标准输出的“行缓冲”模式
> 
> CppReference可以找到原因：
> 
> - **默认行为**：在大多数实现中，标准输出（`std::cout`）如果是连接到**终端（Terminal/屏幕）**的，它默认开启**行缓冲（Line-buffered）**模式。
> - **意思是**：只要遇到换行符 `\n`，系统就会自动把缓冲区里的内容“冲”出去显示。
> - **例外**：当然，如果你手动执行了 `std::ios::sync_with_stdio(false);`，这种同步行为可能会改变。
> 
> 实验验证：管道 `| cat` 改变了行为
> 
> 如果你做了一个操作：把程序的输出通过管道传给 `cat` 命令（`| cat`）。
> 
> - **现象**：这时候，`\n` **不再**立即刷新缓冲区了。
> - **原理**：
>     - 当你直接运行程序（输出到屏幕）时，是**行缓冲**（遇到 `\n` 就刷）。
>     - 当你用 `| cat` 或重定向到文件（`> file.txt`）时，C++ 运行时检测到输出目标不是交互式终端，于是自动切换为**全缓冲（Full Buffering）**。
>     - **全缓冲**：必须等到缓冲区填满（比如填满 4KB），或者程序结束时，才会一次性把数据写出去。`\n` 在这里就真的只是个换行符，不起刷新作用了。

> [!NOTE] sync_with_stdio(false) 与 cin.tie(nullptr)
> [stack overflow](https://stackoverflow.com/questions/31162367/significance-of-ios-basesync-with-stdiofalse-cin-tienull)
>
> You may get a massive performance boost from this.
> ```cpp
> int main() 
> {
> 	std::ios::sync_with_stdio(false); 
> 	for (int i=1; i <= 5; ++i) 
> 		std::cout << i << ‘\n’; 
> 	return 0; 
> }
> ```
> 
> `std::ios_base::sync_with_stdio(false);`
> 
> **本质含义：解除 C++ 与 C 标准流的同步（分家）**
> 
> - **默认状态（True）：** C++ 的 `std::cout` 和 C 的 `printf` 是**同步**的，它们共享同一个缓冲区。
>     - **好处：** 你可以混用 `cout` 和 `printf`，输出顺序是正常的。
>     - **代价：** 为了维持这种同步，C++ 必须牺牲性能，配合 C 的节奏。
> - **设置为 False 后：** C++ 宣布“独立”，不再配合 C 的标准流。`cout` 会启用自己独立的缓冲区。
>     - **副作用（提速）：** 因为不再需要同步开销，I/O 速度大幅提升。
>     - **风险（大坑）：** **绝对不能混用 I/O！** 如果你在代码里一会儿用 `cout`，一会儿用 `printf`，它们的输出顺序会完全乱套（因为各自缓冲，谁先满谁先出），导致结果不可预测。
> 
> 但是,这招只对“非交互式”输出有效
> - **有效场景（非交互式）：** 当你把输出重定向到 **文件 (File)** 或 **管道 (Pipe)** 时，这行代码确实有效。它会让 `\n` 停止刷新缓冲区，变成全缓冲模式（填满才刷），从而极大提升速度。
> - **无效场景（交互式）：** 当你直接输出到 **终端/屏幕 (Terminal)** 时，即便你写了这行代码，系统依然会强制执行“行缓冲”。也就是说，遇到 `\n` 还是会立即刷新，速度并没有本质改变。
> 
> 这是一个**用户体验**的设计保护机制。
> - **终端 (Terminal)** 是给人看的。如果程序问你 `Please enter password:`，但因为缓冲区没满而未显示，那就出问题了。
> - 所以，无论你如何在代码里设置“不要同步”，操作系统和运行时库通常都会强制终端保持 **Line Buffer（行缓冲）**，确保用户能实时看到程序的输出。
> 
> 判题系统通常是用**文件重定向**或**管道**来读取你的输出的。所以，`sync_with_stdio(false)` 在 OJ 上是**非常有效**的，能显著降低 I/O 时间。
> 
> ---
> `cin.tie(NULL);`
> 
> **本质含义：解除输入与输出的绑定（解绑）**
> - **默认状态（Tied）：** `cin` 默认是绑定在 `cout` 上的。
>     - **机制：** 只要程序试图执行输入（`cin >>`），它会先强制刷新输出缓冲区（`cout` flush）。
>     - **目的（用户体验）：** 确保用户在输入之前，一定能看到提示语。
> - **设置为 NULL 后：** `cin` 不再管 `cout` 的死活。
>     - **副作用（提高性能）：** 省去了每次输入前强制刷新输出的开销。
>     - **风险（交互式程序的大坑）：** 程序运行到了 `cin >> name` 开始等待你输入，但屏幕上一片漆黑。为什么？因为 "请输入名字:" 这句话还在缓冲区里没吐出来！用户不知道程序在等什么，以为程序卡死了。
> 	

### Output and input file streams

![2025Fall-04-Streams, 页面 28](files/slides/CS106L/2025Fall-04-Streams.pdf#page=96)

```cpp
int main() 
{ 
/// associating file on construction 
	std::ofstream ofs(“hello.txt”);
	if (ofs.is_open()) 
		ofs << “Hello CS106L!” << ‘\n’; 
	ofs.close(); 
	
	ofs << “this will not get written”; //sliently fail
	
	ofs.open(“hello.txt”, std::ios::app); // Flag specifies you want to append, not truncate!
	ofs << “this will though! It’s open again”; 
	return 0; 
}
```

![2025Fall-04-Streams, 页面 28](files/slides/CS106L/2025Fall-04-Streams.pdf#page=106)

### input streams


![2025Fall-04-Streams, 页面 28](files/slides/CS106L/2025Fall-04-Streams.pdf#page=110)


![2025Fall-04-Streams, 页面 28](files/slides/CS106L/2025Fall-04-Streams.pdf#page=112)

tao is a double , so Fernandez >> double obviously is wrong

![2025Fall-04-Streams, 页面 28](files/slides/CS106L/2025Fall-04-Streams.pdf#page=121)

这里的ignore指的是：**如果你刚用了 `>>` 读取数据，紧接着又要用 `getline`，在中间插一句 `cin.ignore()`，把残留的回车符清理掉。**
![Streams 2, 页面 21](files/slides/CS106L/Streams%202.pdf#page=70)


![Streams 2, 页面 21](files/slides/CS106L/Streams%202.pdf#page=32)

![2025Fall-04-Streams, 页面 28](files/slides/CS106L/2025Fall-04-Streams.pdf#page=138)

注意，如果你只使用了一个std::getline(std::cin,name);
那么就意味着，虽然`getline` 会从输入流中一直读，直到遇到换行符 `\n`，并把这个 `\n` 从缓冲区里**拿走并丢弃**，但**不会**把它存到你的字符串变量里。所以，消耗完一个`\n`后，name没有读取到任何东西，之后，cin又要读取Rachel...，还是错误的。

### Summary

![Streams 2, 页面 21](files/slides/CS106L/Streams%202.pdf#page=21)


![Streams 2, 页面 21](files/slides/CS106L/Streams%202.pdf#page=22)

> [!NOTE]
> 1. 什么时候程序会“卡住”等待输入？(Blocking)
> 
> > "The program hangs and waits for user input when the position reaches EOF, past the last token in the buffer."
> 
> - **缓冲区有货时：** 如果输入缓冲区里还有之前剩下的数据（比如上次输入多打的字符），`cin` 会直接拿走用，程序**毫不停留**，继续往下跑。
> - **缓冲区空了时：** 只有当读取指针（Position Pointer）跑到了缓冲区的末尾（EOF），发现没东西可读了，程序才会“挂起”（Hang），光标闪烁，等待用户敲键盘并回车。
> 
> ---
> 
> 2. `cout` 什么时候才会把字吐到屏幕上？(Flushing)
> 
> > "All input operations will flush cout."
> 
> - 这就是我们之前讨论的 `cin.tie(NULL)` 的反面（默认行为）。
> - `cout` 是有缓冲的，平时它会攒着数据不发。
> - 但是，**任何输入操作（`cin`）都会强制触发 `cout` 的刷新**。
> - **原因：** 编译器假设如果你要输入数据，那你肯定得先看到提示语（比如 "Please enter value:"）。如果这句话还在缓冲区里没吐出来，你就不知道该干嘛了。所以 `cin` 启动前，必须先把 `cout` 清空。
> 
> ---
>  3. `>>` 运算符是如何“吃”数据的？(Position Pointer Tokenizing)
>  
> - **它怎么处理空格？（Skip Leading Whitespace）**
> 
> > "consume all whitespaces (spaces, newlines, etc.)"
> 
> **规则：** 每次你用 `cin >> x;` 时，它做的第一件事是**跳过并丢弃**所有开头的空白字符（空格、Tab、换行符 `\n`）。
> - 它会一直吃，直到遇到第一个**非空白**字符才开始真正的数据读取。
> - **结论：** `>>` 总是跳过**标记前（Before）**的空格。
> 
> -  **它读到哪里停止？(Delimiters)**
> 
> > "reads as many characters until: a whitespace is reached, or... for primitives, the maximum number of bytes necessary..."
> 
> **规则：** 一旦开始读取有效数据，它会一直读，直到遇到下面两种情况之一就**立即停止**：
> **遇到了空白符**（空格、换行等）：这是最常见的停止方式。
> **遇到了“类型不匹配”的字符**："example: if we extract an int from '86.2', we'll get 86, with pos at the decimal point."
> `int x; cin >> x; // 用户输入 "86.2"`
> 1. `cin` 试图读取一个整数 (`int`)。
> 2. 读取 `8`（是数字，继续）。
> 3. 读取 `6`（是数字，继续）。
> 4. 读取 `.`（**小数点不是整数的一部分！**）。
> 5. **停止！**
> 6. **结果：** 变量 `x` 变成 `86`。
> 7. **关键点：** 那个 `.` **并没有被丢弃**，它留在了缓冲区里，变成了下一个读取操作的“开头”。如果你后面紧接着写 `cin >> y;`，`y` 会直接撞上这个小数点。


![Streams 2, 页面 21](files/slides/CS106L/Streams%202.pdf#page=71)

```cpp
#include <iostream>
#include <string>
#include <sstream> 

using namespace std;

int getValidAge() {
    int age;
    string line;

    while (true) {
        cout << "请输入年龄: ";

        // 先把整行读进来
        if (!getline(cin, line)) {
            throw runtime_error("输入流已断开");
        }

        // 把刚才读到的字符串包装成一个流
        istringstream iss(line);

        // 尝试从流里提取一个整数
        if (iss >> age) { // if (stream)  等价于  if (!stream.fail())
            
            // 检查是否有多余的垃圾字符，比如用户输入 "25 abc"，虽然读到了 25，但后面还有东西，这不是有效输入
            if (iss.eof()) {
                break; // 成功！读到了整数且后面没有垃圾，跳出循环
            }
        }

        // 如果走到这里，说明解析失败
        cout << "输入无效，请重试！" << endl;
    }
    return age;
}

int main() {
    int myAge = getValidAge();
    cout << "成功录入年龄: " << myAge << endl;
    return 0;
}

```