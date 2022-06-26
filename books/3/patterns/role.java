package patterns;

//行为-角色模式
//这个模式需要注意的是聚集以及依赖倒置
//这个模式感觉缺点挺多的
public class role {
    public static void main(String[] args) {

        employee li = new employee("li");
        employee zhu = new employee("zhu");
        employee sun = new employee("sun");

        manager manager1 = new manager();
        manager1.set_empolyee(sun);
        manager1.name_employee();

        engineer engineer1 = new engineer();
        engineer1.set_empolyee(zhu);
        engineer1.name_employee();

        manager manager2 = new manager();
        engineer engineer2 = new engineer();
        manager2.set_empolyee(li);
        engineer2.set_empolyee(li);

        manager2.name_employee();
        engineer2.name_employee();

    }
}

class employee {

    private String name;

    public employee(String name) {
        this.name = name;
    }

    public void get_name() {
        System.out.println(name + ":");
    }

}

class manager {

    private employee Employee;

    public void set_empolyee(employee employee) {
        this.Employee = employee;
    }

    public employee get_employee() {
        return Employee;
    }

    public void name_employee() {// 角色不同的行为应当表现出来
        Employee.get_name();
        System.out.println("i am manager");
    }
}

class engineer {

    private employee Employee;

    public void set_empolyee(employee employee) {
        this.Employee = employee;
    }

    public employee get_employee() {
        return Employee;
    }

    public void name_employee() {// 角色不同的行为应当表现出来
        Employee.get_name();
        System.out.println("i am engineer");
    }
}
