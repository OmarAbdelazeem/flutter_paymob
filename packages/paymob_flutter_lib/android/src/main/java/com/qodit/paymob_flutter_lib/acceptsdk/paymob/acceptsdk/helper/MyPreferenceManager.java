package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk.helper;

import android.content.Context;
import android.content.SharedPreferences;

public class MyPreferenceManager {
    private String TAG = MyPreferenceManager.class.getSimpleName();

    SharedPreferences pref;

    SharedPreferences.Editor editor;

    Context _context;

    int PRIVATE_MODE = 0;

    private static final String PREF_NAME = "androidhive_gcm";

    private static final String KEY_USER_ID = "user_id";

    private static final String KEY_USER_NAME = "user_name";

    private static final String KEY_USER_EMAIL = "user_email";

    private static final String KEY_NOTIFICATIONS = "notifications";

    public MyPreferenceManager(Context context) {
        this._context = context;
        this.pref = this._context.getSharedPreferences("androidhive_gcm", this.PRIVATE_MODE);
        this.editor = this.pref.edit();
    }

    public void addNotification(String notification) {
        String oldNotifications = getNotifications();
        if (oldNotifications != null) {
            oldNotifications = oldNotifications + "|" + notification;
        } else {
            oldNotifications = notification;
        }
        this.editor.putString("notifications", oldNotifications);
        this.editor.commit();
    }

    public String getNotifications() {
        return this.pref.getString("notifications", null);
    }

    public void clear() {
        this.editor.clear();
        this.editor.commit();
    }
}
