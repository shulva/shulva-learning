package patterns;

//代理模式
//为其他对象提供一种代理以控制对这个对象的访问
public class proxy {
    public static void main(String[] args) {
        proxycore p = new proxycore("vscode");
        System.out.println(p.getname());
        System.out.println(p.getcore());
    }
}

interface txtreader {
    public String getname();

    public String getcore();

}

class txtcore implements txtreader {

    String name;

    public txtcore(String name) {
        this.name = name;
    }

    @Override
    public String getname() {

        return this.name;
    }

    @Override
    public String getcore() {

        return ("core" + name);
    }

}

class proxycore implements txtreader {

    String name;
    txtreader gather;

    public proxycore(String name) {
        this.name = name;
    }

    @Override
    public String getname() {
        return name;
    }

    @Override
    public String getcore() {

        if (gather == null)
            gather = new txtcore(name);

        return gather.getcore();// 实际类方法，相当于做了一层包装
    }

}
