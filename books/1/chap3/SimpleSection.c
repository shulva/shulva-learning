/*
 *SimpleSection.c
 *
 *Linux:
 *  gcc -c SimpleSection.c 编译
 *  objdump -h SimpleSection.o 显示段表
 *  objdump -s -d SimpleSection.o 显示文件所有内容+对包含机器指令的端进行反汇编
 *  objdump -x -s -d SimpleSection.o +显示所有文件的文件头
 *  readelf -h SimpleSection.o 显示ELF文件的文件头
 *  readelf -S SimpleSection.o 显示ELF文件的段
 *  nm SimpleSection.o 查看符号
 *  readelf -s SimpleSection.o 查看符号表
 * 
 * 
 *Windows:
 * cl SimpleSection.c /c /Za
 */

int printf(const char *format, ...);

int global_init_var = 84;
int gloabal_uninit_vat;

void func1(int i)
{
    printf("%d\n", i);
}

int main(void)
{
    static int static_var = 85;
    static int static_var2;
    int a = 1;
    int b;
    func1(static_var + static_var2 + a + b);
    return a;
}
