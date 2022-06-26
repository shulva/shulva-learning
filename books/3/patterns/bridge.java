package patterns;

//桥梁模式
/*
 抽象和实现分离
 抽象和实现部分分别放在独立的类层次结构中
 通过桥接两个抽象模块，消除模块间的继承耦合
*/
public class bridge {

    public static void main(String args[]) {
        abstraction a = new abstraction(new CD_equipment());
        a.show_what();
        abstraction b = new abstraction(new tape_equipment());

        b.show_what();
        special_abstraction s = new special_abstraction(new tape_equipment());
        s.new_function();
    }

}

class abstraction {
    protected equipment impl;

    public abstraction(equipment impl) {
        this.impl = impl;// 通过接口来玩设备
    }

    public void show_what() {
        impl.print_iam();
    }
}

class special_abstraction extends abstraction {

    public special_abstraction(equipment impl) {
        super(impl);
    }

    public void new_function()// 细分抽象的新功能
    {
        System.out.println("i am special ");
        impl.print_iam();
    }
}

interface equipment {
    public void print_iam();
}

class CD_equipment implements equipment {

    @Override
    public void print_iam() {

        System.out.println("i am cd");
    }
}

class tape_equipment implements equipment {

    @Override
    public void print_iam() {

        System.out.println("i am tape");
    }
}
