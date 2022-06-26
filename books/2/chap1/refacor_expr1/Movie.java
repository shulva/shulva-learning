package refactor.refacor_expr1;

public class Movie {

	public static final int CHILDRENS = 2;
	public static final int REGULAR = 0;
	public static final int NEW_RELEASE = 1;

	private String _title;

	public Movie(String title, int priceCode) {
		_title = title;
		setPriceCode(priceCode);
	}

	public int getPriceCode() {
		return _price.getPriceCode();
	}

	price _price;

	public void setPriceCode(int arg) {
		switch (arg) {
			case REGULAR:
				_price = new REGULARprice();
				break;
			case NEW_RELEASE:
				_price = new NEW_REALESEprice();
				break;
			case CHILDRENS:
				_price = new CHILDRENSprice();
				break;

		}
	}

	public String getTitle() {
		return _title;
	}

	int getfrequentRenterPoints(int daysrental) {// 多态
		return _price.getfrequentRenterPoints(daysrental);
	}
}
