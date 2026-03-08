package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk.helper;

import android.view.View;
import android.widget.EditText;

public class MoneyClickListener implements View.OnClickListener {
    EditText editText;

    public MoneyClickListener(EditText e) {
        this.editText = e;
    }

    public void onClick(View v) {
        this.editText.setSelection(this.editText.getText().length());
    }
}
