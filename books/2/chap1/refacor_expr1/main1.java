package refactor.refacor_expr1;

public class main1 {
    public static void main(String[] args) {
        Customer a1 = new Customer("李");

        Movie shader = new Movie("aa", 2);
        Movie shader2 = new Movie("bb", 1);

        Rental rental = new Rental(shader, 4);
        Rental rental2 = new Rental(shader2, 3);

        a1.addRental(rental);
        a1.addRental(rental2);

        System.out.println(a1.statement());

    }
}
