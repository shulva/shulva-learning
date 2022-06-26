package patterns;

//外观模式
/*
 提供了一个统一的接口，用来访问子系统中的一群接口
 Facade定义了一个高层接口，让子系统更容易使用
*/
public class facade {
    public static void main(String[] args) {
        reporsitory r1 = new reporsitory();
        r1.show1();
    }
}

class cpu {
    public cpu() {
    }

    public void print_iam() {
        System.out.println("i am cpu");
    }
}

class gpu {
    public gpu() {
    }

    public void print_iam() {
        System.out.println("i am gpu");
    }
}

class reporsitory {
    private cpu c;
    private gpu g;

    reporsitory() {
        c = new cpu();
        g = new gpu();
    }

    public void show1() {
        c.print_iam();
        g.print_iam();
    }

}
