package patterns;

//抽象工厂
public class abstractfactory {
    public static void main(String[] args) {
        abstract_industry factoryA = new penfactory_10cm();
        abstract_industry factoryB = new penfactory_15cm();

        product product1 = new product();
        product1.set_factory(factoryA);
        product1.produce();

        product1.set_factory(factoryB);
        product1.produce();
    }
}

class product {

    private abstract_industry ifactory;

    // 选择生产工厂
    public void set_factory(abstract_industry ifactory) {
        this.ifactory = ifactory;
    }

    public void produce() {
        ifactory.createpen().print();
        ifactory.createpenhat().print();
    }
}

interface Ipen {// 笔
    public void print();
}

interface Ipenhat {// 笔帽
    public void print();
}

// 10cm与15cm的笔
class pen10cm implements Ipen {

    @Override
    public void print() {// 行为动作
        System.out.println("produce 10cmpen");
    }

}

class pen15cm implements Ipen {

    @Override
    public void print() {
        System.out.println("produce 15cmpen");
    }

}

// 10cm与15cm的笔帽
class penhat10cm implements Ipenhat {

    @Override
    public void print() {
        System.out.println("produce 10cmpenhat");
    }

}

class penhat15cm implements Ipenhat {

    @Override
    public void print() {
        System.out.println("produce 15cmpenhat");
    }

}

// 生产配套产品的抽象工厂类
interface abstract_industry {
    public Ipen createpen();

    public Ipenhat createpenhat();
}

// 10cm笔与10cm笔帽配套，15cm笔与15cm笔帽配套
class penfactory_10cm implements abstract_industry {

    // 在子类中生成实例
    @Override
    public Ipen createpen() {
        return new pen10cm();
    }

    @Override
    public Ipenhat createpenhat() {

        return new penhat10cm();
    }

}

class penfactory_15cm implements abstract_industry {

    @Override
    public Ipen createpen() {

        return new pen15cm();
    }

    @Override
    public Ipenhat createpenhat() {

        return new penhat15cm();
    }

}
