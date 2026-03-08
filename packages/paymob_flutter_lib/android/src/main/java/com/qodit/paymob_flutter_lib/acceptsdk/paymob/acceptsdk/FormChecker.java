package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

class FormChecker {
    static Boolean checkCVV(String cvvString) {
        return Boolean.valueOf((cvvString != null && cvvString.length() == 3));
    }

    static Boolean checkCardName(String nameString) {
        return Boolean.valueOf((nameString != null && nameString.length() != 0));
    }

    static Boolean checkCardNumber(String numberString) {
        return Boolean.valueOf((numberString != null && numberString.length() == 16));
    }

    static Boolean checkDate(String monthString, String yearString) {
        if (monthString == null || monthString.length() != 2 || yearString == null || yearString.length() != 2)
            return Boolean.valueOf(false);
        Integer yearDiff = Integer.valueOf(Integer.parseInt(yearString) - Integer.parseInt((new SimpleDateFormat("yy", Locale.GERMANY)).format(new Date())));
        Integer monthDiff = Integer.valueOf(Integer.parseInt(monthString) - Integer.parseInt((new SimpleDateFormat("MM", Locale.GERMANY)).format(new Date())));
        return Boolean.valueOf((yearDiff.intValue() > 0 || (yearDiff.intValue() == 0 && monthDiff.intValue() >= 0)));
    }
}
