package refactor.refacor_expr1;

abstract class price {
    abstract int getPriceCode();

    abstract double getcharge(int daysrental);// 将此两函数放入到于其直接相关的类中

    int getfrequentRenterPoints(int daysrental) {// 多态
        // add bonus for a two day new release rental
        if ((getPriceCode() == Movie.NEW_RELEASE) && (daysrental) > 1)
            return 2;
        else
            return 1;
    }

}

class CHILDRENSprice extends price {

    @Override
    int getPriceCode() {
        return Movie.CHILDRENS;
    }

    @Override
    double getcharge(int daysrental) {
        double result = 1.5;
        if ((daysrental) > 3)
            result += ((daysrental) - 3) * 1.5;
        return result;
    }

}

class NEW_REALESEprice extends price {

    @Override
    int getPriceCode() {
        return Movie.NEW_RELEASE;

    }

    @Override
    double getcharge(int daysrental) {
        return daysrental * 3;
    }

    int getfrequentRenterPoints(int daysrental) {
        return (daysrental > 1) ? 2 : 1;
    } // 只在此类片中使用

}

class REGULARprice extends price {

    @Override
    int getPriceCode() {
        return Movie.REGULAR;
    }

    @Override
    double getcharge(int daysrental) {
        double result = 2;
        if ((daysrental) > 2)
            result += (daysrental - 2) * 1.5;
        return result;
    }

}