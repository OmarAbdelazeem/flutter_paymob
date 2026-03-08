package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk;

import android.text.InputFilter;
import android.text.Spanned;
import android.util.Log;

class ExpiryMonthInputFilter implements InputFilter {
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
            if (inputChar > '1') {
                try {
                    return "0" + inputChar;
                } catch (Exception e) {
                    Log.d("exception", "filter: " + e.getMessage());
                }
            } else {
                return source;
            }
        } else if (dstart == 1) {
            char firstMonthChar = dest.charAt(0);
            if (firstMonthChar == '0' && inputChar == '0')
                return "";
            if (firstMonthChar == '1' && inputChar > '2')
                return "";
        }
        return source;
    }
}
