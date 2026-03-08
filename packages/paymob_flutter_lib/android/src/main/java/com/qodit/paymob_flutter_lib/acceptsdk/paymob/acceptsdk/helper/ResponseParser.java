package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk.helper;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;

public class ResponseParser {
    HashMap<String, String> returnedMap;

    JSONObject responseObject;

    public ResponseParser(String response) {
        try {
            this.responseObject = new JSONObject(response);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        this.returnedMap = new HashMap<>();
    }

    public boolean isStatusOK() {
        String status = "";
        try {
            status = this.responseObject.getString("status");
        } catch (JSONException e) {
            e.printStackTrace();
        }
        if (status.compareTo("OK") == 0)
            return true;
        return false;
    }

    public HashMap<String, String> getDetails() {
        JSONObject detailsObject = null;
        JSONArray detailsArray = null;
        try {
            detailsArray = this.responseObject.getJSONArray("details");
            detailsObject = detailsArray.getJSONObject(0);
            Iterator<?> objectIterator = detailsObject.keys();
            while (objectIterator.hasNext()) {
                String nextKey = (String)objectIterator.next();
                this.returnedMap.put(nextKey, detailsObject.getString(nextKey));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return this.returnedMap;
    }

    public String getFailureMessage() {
        HashMap<String, String> responseMap = getDetails();
        if (responseMap.containsKey("failure_message"))
            return responseMap.get("failure_message");
        return null;
    }
}
