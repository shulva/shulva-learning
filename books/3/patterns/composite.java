package patterns;

//组合模式
// 将对象组合成树形结构——“部分/整体”层次结构
// 使用户对单一对象和组合对象使用具有一致性接口
public class composite {
    public static void main(String[] args) {// client只能得知节点

    }
}

abstract class node {

    static int count = 0;

    public node(String name) {
    }

    public abstract void opreation();

}

class composition extends node {

    public composition(String name) {
        super(name);
    }

    @Override
    public void opreation() {

    }

}

class leaves extends node {

    public leaves(String name) {
        super(name);

    }

    @Override
    public void opreation() {

    }

}