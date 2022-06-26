package refactor.refacor_expr1;

import java.util.*;

public class Customer {
	private String _name;
	private Vector<Rental> _rentals = new Vector<Rental>();

	public Customer(String name) {
		_name = name;
	}

	public void addRental(Rental arg) {
		_rentals.addElement(arg);
	}

	public String getName() {
		return _name;
	}

	public double Amountfor(Rental aRental) {
		return aRental.getcharge();
	}

	public String statement() {

		Enumeration<Rental> rentals = _rentals.elements();
		String result = "Rental Record for " + getName() + "\n";
		while (rentals.hasMoreElements()) {
			// 无用的临时变量可以去除，thisamount,totalamout,frequentRenterPoints
			Rental each = ((Rental) rentals.nextElement());// 这个地方不能将底下的each替换掉,否则一个循环会next两次

			// determine amounts for each line

			// 只有一个地方调用了此函数，删掉

			// show figures for the rental
			result += "\t" + each.getMovie().getTitle() + "\t" + String.valueOf(each.getcharge()) + "\n";
		}
		// add footer lines
		result += "Amount owed is " + String.valueOf(gettotalcharge()) + "\n";
		result += "You earned " + String.valueOf(getfrequentRenterPoints()) + " frequent renter points ";
		return result;
	}

	private double gettotalcharge() {
		double result = 0;
		Enumeration<Rental> rentals = _rentals.elements();
		while (rentals.hasMoreElements()) {
			// each没啥大用，我自己的构思 Rental each = ((Rental) rentals.nextElement());
			result += ((Rental) rentals.nextElement()).getcharge();
		}
		return result;
	}

	private int getfrequentRenterPoints() {
		int result = 0;
		Enumeration<Rental> rentals = _rentals.elements();
		while (rentals.hasMoreElements()) {
			result += ((Rental) rentals.nextElement()).getfrequentRenterPoints();
		}
		return result;
	}
}
