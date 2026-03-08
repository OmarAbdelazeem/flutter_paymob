package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk;

class StringEditor {
    public static String insertPeriodically(String text, String insert, int period) {
        StringBuilder builder = new StringBuilder(text.length() + insert.length() * text.length() / period + 1);
        int index = 0;
        String prefix = "";
        while (index < text.length()) {
            builder.append(prefix);
            prefix = insert;
            builder.append(text.substring(index,
                    Math.min(index + period, text.length())));
            index += period;
        }
        return builder.toString();
    }

    public static String monthString(int month) {
        if (month < 1 || month > 12)
            return null;
        if (month < 10)
            return "0" + Integer.toString(month);
        return Integer.toString(month);
    }

    public static String yearString(int year) {
        return Integer.toString(year).substring(2, 4);
    }
}
