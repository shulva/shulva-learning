package refactor.refacor_expr1;

public class Rental {
	Movie _movie;
	private int _daysRented;

	public Rental(Movie movie, int daysRented) {
		_movie = movie;
		_daysRented = daysRented;
	}

	public int getDaysRented() {
		return _daysRented;
	}

	public Movie getMovie() {
		return _movie;
	}

	double getcharge() {
		return _movie._price.getcharge(_daysRented);
	}

	int getfrequentRenterPoints() {
		return _movie.getfrequentRenterPoints(_daysRented);
	}
}
