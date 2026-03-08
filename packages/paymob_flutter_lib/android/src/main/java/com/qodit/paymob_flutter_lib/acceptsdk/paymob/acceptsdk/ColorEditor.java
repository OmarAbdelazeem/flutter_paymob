package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk;

import android.content.res.ColorStateList;

import androidx.appcompat.widget.AppCompatCheckBox;

class ColorEditor {
    public static void setAppCompatCheckBoxColors(AppCompatCheckBox _checkbox, int _uncheckedColor, int _checkedColor) {
        int[][] states = { { -16842912 }, { 16842912 } };
        int[] colors = { _uncheckedColor, _checkedColor };
        _checkbox.setSupportButtonTintList(new ColorStateList(states, colors));
    }
}
