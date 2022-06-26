package patterns;

//行为-状态模式
public class state {
    public static void main(String[] args) {// 相当于client

        concrete_state day = new day();

        alarm_ring ring = new alarm_ring();

        ring.change_state(day);

        ring.alarm();

        concrete_state night = new night();

        ring.change_state(night);

        ring.alarm();

    }
}

interface concrete_state {// 状态接口
    public void is_there_person();
}

class alarm_ring {

    concrete_state iConcrete_state;

    public void alarm() {
        iConcrete_state.is_there_person();
    }

    public void change_state(concrete_state iConcrete_state) {
        this.iConcrete_state = iConcrete_state;
    }

}

class day implements concrete_state {

    public day() {
        System.out.println("day coming..");
    }

    @Override
    public void is_there_person() {
        System.out.println("nothing..");
    }
}

class night implements concrete_state {

    public night() {
        System.out.println("night coming..");
    }

    @Override
    public void is_there_person() {
        System.out.println("ring ring !!");
    }

}