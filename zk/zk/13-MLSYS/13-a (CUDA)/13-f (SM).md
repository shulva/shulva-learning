# SM

一个 GPU 是由多个 SM 构成的。一个 SM一般包含如下资源：

 - 一定数量的寄存器。 
 - 一定数量的共享内存。 
 - 常量内存的缓存。 
 - 纹理和表面内存的缓存。  
 - L1 缓存。  
 -  4 个线程束调度器（warp scheduler），用于在不同线程的上下文之间迅速地切换，以及为准备就绪的线程束发出执行指令。 
 - 执行核心，包括： 
	 - 若干整型数运算的核心（INT32）。 
	 - 若干单精度浮点数运算的核心（FP32）。
	 - 若干双精度浮点数运算的核心（FP64）。 
	 - 若干单精度浮点数超越函数（transcendental functions）的特殊函数单元（Special Function Units，SFUs）。 
	 - 若干混合精度的张量核心（tensor cores）。

Hopper架构：

![hopper](https://developer-blogs.nvidia.com/wp-content/uploads/2022/03/H100-Streaming-Multiprocessor-SM.png)


Ampere架构：
![ampere](https://developer-blogs.nvidia.com/wp-content/uploads/2021/guc/raD52-V3yZtQ3WzOE0Cvzvt8icgGHKXPpN2PS_5MMyZLJrVxgMtLN4r2S2kp5jYI9zrA2e0Y8vAfpZia669pbIog2U9ZKdJmQ8oSBjof6gc4IrhmorT2Rr-YopMlOf1aoU3tbn5Q.png)

Turing架构：
![turing](https://developer-blogs.nvidia.com/wp-content/uploads/2018/09/image11.jpg)