package patterns;

public class factory {
    public static void main(String[] args) {
        abstr_factory product = new product_A();
        product.create().get_name();

        product = new product_B();
        product.create().get_name();

    }
}

abstract class abstr_factory {
    public abstract produce create();
}

class product_A extends abstr_factory {

    @Override
    public produce create() {

        return new productA();
    }

}

class product_B extends abstr_factory {

    @Override
    public produce create() {

        return new productB();
    }

}

abstract class produce {
    public abstract void get_name();
}

class productA extends produce {

    private String name = "A";

    @Override
    public void get_name() {
        System.out.println(name);
    }
}

class productB extends produce {

    private String name = "B";

    @Override
    public void get_name() {
        System.out.println(name);
    }
}
