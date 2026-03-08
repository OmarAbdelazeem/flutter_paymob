package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk;

import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.os.Build;

import java.util.Locale;

public class LocaleManager {
    public static final String LANGUAGE_ENGLISH = "en";

    public static final String LANGUAGE_ENGLISH_US = "US";

    public LocaleManager(Context context) {}

    public Context setLocale(Context c) {
        return c;
    }

    public Context setNewLocale(Context c, String language, String country) {
        return updateResources(c, language, country);
    }

    private Context updateResources(Context context, String language, String country) {
        Locale locale = new Locale(language, country);
        Locale.setDefault(locale);
        Resources res = context.getResources();
        Configuration config = new Configuration(res.getConfiguration());
        if (isAtLeastVersion(17)) {
            config.setLocale(locale);
            context = context.createConfigurationContext(config);
        } else {
            config.locale = locale;
            res.updateConfiguration(config, res.getDisplayMetrics());
        }
        return context;
    }

    public Locale getLocale(Context context) {
        Configuration config = context.getResources().getConfiguration();
        return isAtLeastVersion(24) ? config.getLocales().get(0) : config.locale;
    }

    public static boolean isAtLeastVersion(int version) {
        return (Build.VERSION.SDK_INT >= version);
    }
}
