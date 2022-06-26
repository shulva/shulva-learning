package patterns;

// 行为模式-模板方法模式
/*
 定义一个操作中的算法的骨架，而将一些步骤延迟到子类中 
 子类不需要改变算法结构即可重定义算法的某些步骤
*/
public class template {
    public static void main(String[] args) {
        function_1 f1 = new function_1();
        f1.show();
        function_2 f2 = new function_2();
        f2.show();
    }
}

abstract class template_fun {

    final public void fun1() {
        fun2();
        show();
    }

    public void fun2() {
        System.out.println("test");
    }

    abstract public void show();
}

class function_1 extends template_fun {

    @Override
    public void show() {
        System.out.println("fun1");
    }

}

class function_2 extends template_fun {

    @Override
    public void show() {
        System.out.println("fun2");
    }

}