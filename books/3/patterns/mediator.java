package patterns;

//行为-中间者模式，类似千层饼
public class mediator {
    public static void main(String[] args) {
        concrete_intermeidary broker = new concrete_intermeidary();

        concrete_colleagueA sirA = new concrete_colleagueA(broker);

        concrete_colleagueB sirB = new concrete_colleagueB(broker);

        broker.setA(sirA);

        broker.setB(sirB);

        sirA.change();// 改变原因我就不写了

        sirB.change();

    }
}

abstract class colleague {

    private intermediary middleman;

    public colleague(intermediary i_middleman) {
        this.middleman = i_middleman;
    }

    public void change() {
        middleman.haschanged(this);// 用来通知中间者的函数
    }
}

abstract class intermediary {
    public abstract void haschanged(colleague colleague);
}

class concrete_colleagueA extends colleague {

    public concrete_colleagueA(intermediary i_middleman) {
        super(i_middleman);
        System.out.println("A的中间人已指定");
    }

    public void mothodA() {
        System.out.println("A已收到消息");
    }

    public void change() {// 通信缘由我就不写了，可以是被改变之类的
        System.out.println("A通知中间人");
        super.change();
    }

}

class concrete_colleagueB extends colleague {

    public concrete_colleagueB(intermediary i_middleman) {
        super(i_middleman);
        System.out.println("B的中间人已指定");
    }

    public void mothodB() {
        System.out.println("B已收到消息");
    }

    public void change() {
        System.out.println("B通知中间人");// 通信缘由我就不写了
        super.change();
    }
}

class concrete_intermeidary extends intermediary {

    private concrete_colleagueA colleagueA;
    private concrete_colleagueB colleagueB;

    public concrete_intermeidary() {
        System.out.println("中间人已创造");
    }

    @Override
    // 讲实话，应该用list做一个数据结构，来一个个比对后再进行行为，这个是超简单版本
    public void haschanged(colleague colleague) {
        if (colleague.equals(colleagueA)) {
            System.out.println("中间者通知同事B");
            colleagueB.mothodB();
        } else if (colleague.equals(colleagueB)) {
            System.out.println("中间者通知同事A");
            colleagueA.mothodA();
        }
    }

    public void setA(concrete_colleagueA colleague) {
        this.colleagueA = colleague;
    }

    public void setB(concrete_colleagueB colleague) {
        this.colleagueB = colleague;
    }
}