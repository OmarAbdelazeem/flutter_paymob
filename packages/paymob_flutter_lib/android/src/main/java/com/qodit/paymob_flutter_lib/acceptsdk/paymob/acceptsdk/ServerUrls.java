package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk;

class ServerUrls {
    // Accept Egypt (accept.paymob.com) - matches backend session payment_key
    private static final String PAYMOB_SERVER_IP = "https://accept.paymob.com/api/acceptance/";

    static final String API_URL_USER_PAYMENT = "https://accept.paymob.com/api/acceptance/payments/pay";

    static final String API_URL_TOKENIZE_CARD = "https://accept.paymob.com/api/acceptance/tokenization?payment_token=";

    static final String API_NAME_USER_PAYMENT = "USER_PAYMENT";

    static final String API_NAME_TOKENIZE_CARD = "CARD_TOKENIZER";

    static final String PAYMOB_SUCCESS_URL = "https://accept.paymob.com/api/acceptance/post_pay";
}
