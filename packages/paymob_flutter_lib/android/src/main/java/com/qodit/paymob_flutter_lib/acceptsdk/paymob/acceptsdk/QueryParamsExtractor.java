package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk;

import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.Map;

class QueryParamsExtractor {
    public static Map<String, String> getQueryParams3(String url) {
        try {
            Map<String, String> params = new HashMap<>();
            String[] urlParts = url.split("\\?");
            if (urlParts.length > 1) {
                String query = urlParts[1];
                for (String param : query.split("&")) {
                    String[] pair = param.split("=");
                    String key = URLDecoder.decode(pair[0], "UTF-8");
                    String value = "";
                    if (pair.length > 1) {
                        value = URLDecoder.decode(pair[1], "UTF-8");
                        params.put(key, value);
                    }
                }
            }
            return params;
        } catch (UnsupportedEncodingException ex) {
            return null;
        }
    }

    public static String getQueryParams(String url) {
        try {
            JSONObject JSON = new JSONObject();
            Map<String, String> params = new HashMap<>();
            String[] urlParts = url.split("\\?");
            if (urlParts.length > 1) {
                String query = urlParts[1];
                for (String param : query.split("&")) {
                    String[] pair = param.split("=");
                    String key = URLDecoder.decode(pair[0], "UTF-8");
                    String value = "";
                    if (pair.length > 1) {
                        value = URLDecoder.decode(pair[1], "UTF-8");
                        JSON.put(key, value);
                    }
                }
            }
            return JSON.toString();
        } catch (Exception ex) {
            return null;
        }
    }
}
