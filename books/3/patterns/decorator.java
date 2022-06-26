package patterns;

//装饰模式
//动态地给对象添加额外职责
//不改变接口，只改变职责
//
public class decorator {// 类似client,只能看到汽车car接口

    public static void main(String[] args) {
        car car1 = new good_car();
        car1.print_add();// goodcar with gps

        car car2 = new air(new bad_car());
        car2.print_add();// badcar with air

        car1 = new air(new GPS(car1));
        car1.print_add();
    }
}

interface car {
    public void print_add();
}

class good_car implements car {

    @Override
    public void print_add() {
        System.out.println("good");
    }

}

class bad_car implements car {

    @Override
    public void print_add() {
        System.out.println("bad");
    }
}

abstract class equipment_test implements car {

    protected car gather;

    public equipment_test(car iCar) {
        gather = iCar;// 聚集功能
    }
}

class GPS extends equipment_test {
    public GPS(car icar) {
        super(icar);
    }

    @Override
    public void print_add() {
        gather.print_add();
        System.out.println("GPS");
    }
}

class air extends equipment_test {
    public air(car iCar) {
        super(iCar);
    }

    @Override
    public void print_add() {
        gather.print_add();
        System.out.println("air");
    }
}
