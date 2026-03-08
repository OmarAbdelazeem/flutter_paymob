package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk;

import android.text.InputFilter;
import android.text.Spanned;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

class ExpiryYearInputFilter implements InputFilter {
    private final String currentYearLastTwoDigits = (new SimpleDateFormat("yy", Locale.GERMANY)).format(new Date());

    public CharSequence filter(CharSequence source, int start, int end, Spanned dest, int dstart, int dend) {
        if (source.equals("")) {
            if (dstart + 1 < dest.length())
                return dest.subSequence(dstart, dend);
            return "";
        }
        if (dest != null && dest.toString().length() >= 2)
            return "";
        if (source.length() > 1)
            return source;
        if (dest != null && source.length() > 1 && dstart != dest.length())
            return "";
        if (source.equals(" "))
            return "";
        char inputChar = source.charAt(0);
        if (dstart == 0) {
            char currYearFirstChar = this.currentYearLastTwoDigits.charAt(0);
            if (inputChar < currYearFirstChar)
                return "";
            return source;
        }
        if (dstart == 1) {
            String inputYear = "" + dest.charAt(dest.length() - 1) + source.toString();
            if (inputYear.compareTo(this.currentYearLastTwoDigits) < 0)
                return "";
        }
        return source;
    }
}
