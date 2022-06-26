package patterns;

//观察者模式
import java.util.ArrayList;
import java.util.List;

public class observer {
    public static void main(String[] args) {
        center center1 = new center();
        single single1 = new single();
        single2 single2 = new single2();

        // 登记观察者
        center1.regist(single1);
        center1.regist(single2);

        center1.change("水浒传");

        // 删除一个观察者
        center1.delete(single2);
        center1.change("红楼梦");
    }
}

// 观察者接口
interface iwatcher {
    public void notice(icanbewatcher bewatcher);
}

// 被观察者接口
interface icanbewatcher {
    public void regist(iwatcher watcher);

    public void delete(iwatcher watcher);

    public String name();
}

// 两种不同类型的观察者
class single implements iwatcher {

    @Override
    public void notice(icanbewatcher bewatcher) {
        System.out.println("对象1观察到变化:" + bewatcher.name());// 行为
    }
}

class single2 implements iwatcher {

    @Override
    public void notice(icanbewatcher bewatcher) {
        System.out.println("对象2观察到变化:" + bewatcher.name());
    }

}

class center implements icanbewatcher {

    private List<iwatcher> watcherlist = new ArrayList<iwatcher>();

    private String name1 = "西游记";

    public void change(String name1) {// 改变时通知所有观察者
        this.name1 = name1;
        inform();
    }

    @Override
    public void regist(iwatcher watcher) {// 登记操作
        watcherlist.add(watcher);
    }

    @Override
    public void delete(iwatcher watcher) {// 删除操作
        watcherlist.remove(watcher);
    }

    @Override
    public String name() {
        return name1;
    }

    public void inform() {// 通知，调用所有已注册的观察者的notice函数()
        for (iwatcher iwatcher : watcherlist) {
            iwatcher.notice(this);
        }
    }
}
