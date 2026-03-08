package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk;

import android.app.Activity;
import android.content.Context;
import android.widget.Toast;

public class ToastMaker {
    public static void displayLongToast(Activity activity, String msg) {
        displayToast(activity.getApplicationContext(), msg, 1);
    }

    public static void displayShortToast(Activity activity, String msg) {
        displayToast(activity.getApplicationContext(), msg, 0);
    }

    private static void displayToast(Context c, String msg, int length) {
        Toast.makeText(c, msg, length).show();
    }
}
