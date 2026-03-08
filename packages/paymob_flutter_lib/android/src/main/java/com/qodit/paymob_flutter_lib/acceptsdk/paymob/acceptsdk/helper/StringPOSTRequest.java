package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk.helper;

import com.android.volley.AuthFailureError;
import com.android.volley.Response;
import com.android.volley.toolbox.StringRequest;

public class StringPOSTRequest extends StringRequest {
    private String postContents;

    public StringPOSTRequest(String url, String postContents, Response.Listener<String> listener, Response.ErrorListener errorListener) {
        super(1, url, listener, errorListener);
        setShouldCache(false);
        this.postContents = postContents;
    }

    public byte[] getBody() throws AuthFailureError {
        return this.postContents.getBytes();
    }

    public String getBodyContentType() {
        return "application/json";
    }
}
