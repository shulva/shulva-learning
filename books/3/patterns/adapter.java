package patterns;

import java.util.Vector;

//结构模式
//接口返回值是perosn,csv是string，故需要adapter
//将一个类的接口，转换成客户期望的另一个接口，适配器让原本接口不兼容的类可以一起工作

public class adapter {
    public static void main(String args[]) {
        csv_reader string_needtochange = new csv_adapter();// 需要被适配的csv类

        Vector<person> string_to_person = string_needtochange.adapt();// 适配

        // 显示出被适配后的结果
        for (person person : string_to_person) {
            person.print_name();
        }
    }
}

class csv_adapter implements csv_reader {// 适配器类
    public Vector<person> adapt() {
        // 我要person，但只有string，故要转化
        csv string_need = new csv();// 需要被适配的类
        Vector<String> stringVector = string_need.backVector();
        Vector<person> personVector = new Vector<person>();

        for (String testperson : stringVector) {
            personVector.add(new person(testperson));// person的构造函数，stirng全变为name
        }

        return personVector;
    }
}

interface csv_reader {
    public Vector<person> adapt();// 适配函数
}

class person {
    private String name;

    public person(String name) {
        this.name = name;
    }

    public void print_name() {
        System.out.print(name);
    }

}

class csv {

    // 一般来说都是文件读写需要适配
    Vector<String> backstring = new Vector<String>();

    public Vector<String> backVector() {

        backstring.add("我原来是string类型，现在是person");
        return backstring;
    }
}