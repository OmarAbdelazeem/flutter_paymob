package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk.helper;

import android.content.Context;
import android.content.SharedPreferences;

import com.qodit.paymob_flutter_lib.R;

import org.json.JSONException;
import org.json.JSONObject;

public class JSONObjectBuilder {
    private static final String login = "test";

    private static final String password = "test";

    private static final String requestGatewayCode = "W";

    private static final String requestGatewayType = "W";

    private String app_id;

    public JSONObject returnedJSON;

    public JSONObjectBuilder(Context context) throws JSONException {
        SharedPreferences sharedPref = context.getSharedPreferences(context.getString(R.string.pref_file_name), 0);
        this.app_id = sharedPref.getString(context.getString(R.string.app_id), "");
        this.returnedJSON = new JSONObject();
        this.returnedJSON.put("APP_ID", this.app_id);
        this.returnedJSON.put("LOGIN", "test");
        this.returnedJSON.put("PASSWORD", "test");
        this.returnedJSON.put("REQUEST_GATEWAY_CODE", "W");
        this.returnedJSON.put("REQUEST_GATEWAY_TYPE", "W");
    }

    public JSONObject buildREFUNDJSONObject(String msisdn, String pin, String language, String msisdn2, String amount, String CID) {
        try {
            this.returnedJSON.put("TYPE", "PREREQ");
            this.returnedJSON.put("MSISDN", msisdn);
            this.returnedJSON.put("PIN", pin);
            this.returnedJSON.put("LANGUAGE1", language);
            this.returnedJSON.put("MSISDN2", msisdn2);
            this.returnedJSON.put("AMOUNT", amount);
            this.returnedJSON.put("CID", CID);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return this.returnedJSON;
    }

    public JSONObject buildPurchaseJSONObject(String msisdn, String pin, String language, String mercode, String amount, String orderno, String CID) {
        try {
            this.returnedJSON.put("TYPE", "CMPREQ");
            this.returnedJSON.put("MSISDN", msisdn);
            this.returnedJSON.put("PIN", pin);
            this.returnedJSON.put("LANGUAGE1", language);
            this.returnedJSON.put("MERCODE", mercode);
            this.returnedJSON.put("AMOUNT", amount);
            this.returnedJSON.put("ORDERNO", orderno);
            this.returnedJSON.put("CID", CID);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return this.returnedJSON;
    }

    public JSONObject buildCashinJSONObject(String msisdn, String pin, String language, String msisdn2, String amount, String CID) {
        try {
            this.returnedJSON.put("TYPE", "RCIREQ");
            this.returnedJSON.put("MSISDN", msisdn);
            this.returnedJSON.put("PIN", pin);
            this.returnedJSON.put("LANGUAGE1", language);
            this.returnedJSON.put("AMOUNT", amount);
            this.returnedJSON.put("MSISDN2", msisdn2);
            this.returnedJSON.put("CID", CID);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return this.returnedJSON;
    }

    public JSONObject buildBalanceInquiryJSONObject(String msisdn, String pin, String language) {
        try {
            this.returnedJSON.put("TYPE", "CBEREQ");
            this.returnedJSON.put("MSISDN", msisdn);
            this.returnedJSON.put("PIN", pin);
            this.returnedJSON.put("LANGUAGE1", language);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return this.returnedJSON;
    }

    public JSONObject buildUserJSONObject(String username, String password) {
        try {
            this.returnedJSON.put("TYPE", "MPOSINQREQ");
            this.returnedJSON.put("MSISDN", username);
            this.returnedJSON.put("PIN", password);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return this.returnedJSON;
    }

    public JSONObject buildRSAKeyJSONObject(String androidID, String key) {
        try {
            this.returnedJSON.put("TYPE", "MPOSKEYREQ");
            this.returnedJSON.put("LOGIN", "test");
            this.returnedJSON.put("PASSWORD", "test");
            this.returnedJSON.put("REQUEST_GATEWAY_CODE", "W");
            this.returnedJSON.put("REQUEST_GATEWAY_TYPE", "W");
            this.returnedJSON.put("LANGUAGE1", "2");
            this.returnedJSON.put("SNO", androidID);
            this.returnedJSON.put("PUB", key);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return this.returnedJSON;
    }

    public JSONObject buildAESKeyJSONObject(String androidID, String key) {
        try {
            this.returnedJSON.put("TYPE", "MPOSKEYREQ");
            this.returnedJSON.put("LOGIN", "test");
            this.returnedJSON.put("PASSWORD", "test");
            this.returnedJSON.put("REQUEST_GATEWAY_CODE", "W");
            this.returnedJSON.put("REQUEST_GATEWAY_TYPE", "W");
            this.returnedJSON.put("LANGUAGE1", "2");
            this.returnedJSON.put("SNO", androidID);
            this.returnedJSON.put("KEY", key);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return this.returnedJSON;
    }

    public JSONObject buildHistoryJSONObject(String username) {
        try {
            this.returnedJSON.put("TYPE", "CLTREQ");
            this.returnedJSON.put("MSISDN", username);
            this.returnedJSON.put("PIN", "");
            this.returnedJSON.put("LOGIN", "test");
            this.returnedJSON.put("PASSWORD", "test");
            this.returnedJSON.put("REQUEST_GATEWAY_CODE", "W");
            this.returnedJSON.put("REQUEST_GATEWAY_TYPE", "W");
            this.returnedJSON.put("LANGUAGE1", "2");
            this.returnedJSON.put("CID", "");
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return this.returnedJSON;
    }

    public JSONObject buildShiftJSONObject(String username, String password, String Date) {
        try {
            this.returnedJSON.put("TYPE", "MPOSINQREQ");
            this.returnedJSON.put("MSISDN", username);
            this.returnedJSON.put("PIN", password);
            this.returnedJSON.put("TIME", Date);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return this.returnedJSON;
    }

    public JSONObject buildTxnJSONObject(String msi, String trx_id) {
        try {
            this.returnedJSON.put("LOGIN", "test");
            this.returnedJSON.put("PASSWORD", "test");
            this.returnedJSON.put("REQUEST_GATEWAY_CODE", "W");
            this.returnedJSON.put("REQUEST_GATEWAY_TYPE", "W");
            this.returnedJSON.put("TYPE", "CLTXNRREQ");
            this.returnedJSON.put("MSISDN", msi);
            this.returnedJSON.put("CID", "");
            this.returnedJSON.put("TXNREFID", trx_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return this.returnedJSON;
    }

    public JSONObject buildreverseJSONObject(String msi, String msi2, String cid, String pin, String trx_id) {
        try {
            this.returnedJSON.put("LOGIN", "test");
            this.returnedJSON.put("PASSWORD", "test");
            this.returnedJSON.put("REQUEST_GATEWAY_CODE", "W");
            this.returnedJSON.put("REQUEST_GATEWAY_TYPE", "W");
            this.returnedJSON.put("TYPE", "PREVREQ");
            this.returnedJSON.put("MSISDN", msi);
            this.returnedJSON.put("MSISDN2", msi2);
            this.returnedJSON.put("PIN", pin);
            this.returnedJSON.put("CID", cid);
            this.returnedJSON.put("PurchID", trx_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return this.returnedJSON;
    }
}
