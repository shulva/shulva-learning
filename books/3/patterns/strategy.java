package patterns;

//策略模式
public class strategy {

    public static void main(String[] args) {

        kelvin caculator = new kelvin(326.20);

        caculator.set_fun(new fahrenheit());
        caculator.show_temprature();

        caculator.set_fun(new celsius());
        caculator.show_temprature();

    }

}

abstract class degree {
    public abstract double calculate(double k);

    double temprature;
}

class fahrenheit extends degree {

    @Override
    public double calculate(double k) {
        temprature = 9.0 / (5.0) * (k - 273.15) + 32.0;
        return temprature;
    }

}

class celsius extends degree {

    @Override
    public double calculate(double k) {
        temprature = k - 273.15;
        return temprature;
    }

}

class kelvin {

    private degree degree = new celsius();

    private double kelvins;

    public kelvin(double kelvins) {
        this.kelvins = kelvins;
    }

    public void set_fun(degree degree) {
        this.degree = degree;
    }

    public void show_temprature() {
        System.out.println(String.valueOf(degree.calculate(kelvins)));
    }

}