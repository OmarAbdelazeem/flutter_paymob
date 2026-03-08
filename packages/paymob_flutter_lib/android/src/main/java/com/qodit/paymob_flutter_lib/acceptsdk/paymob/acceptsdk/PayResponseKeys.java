package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk;

public class PayResponseKeys {
    public static final String AMOUNT_CENTS = "amount_cents";

    public static final String IS_REFUNDED = "is_refunded";

    public static final String IS_CAPTURE = "is_capture";

    public static final String CAPTURED_AMOUNT = "captured_amount";

    public static final String SOURCE_DATA_TYPE = "source_data.type";

    public static final String PENDING = "pending";

    public static final String MERCHANT_ORDER_ID = "merchant_order_id";

    public static final String IS_3D_SECURE = "is_3d_secure";

    public static final String ID = "id";

    public static final String IS_VOID = "is_void";

    public static final String CURRENCY = "currency";

    public static final String IS_AUTH = "is_auth";

    public static final String IS_REFUND = "is_refund";

    public static final String OWNER = "owner";

    public static final String IS_VOIDED = "is_voided";

    public static final String SOURCE_DATA_PAN = "source_data.pan";

    public static final String PROFILE_ID = "profile_id";

    public static final String SUCCESS = "success";

    public static final String DATA_MESSAGE = "data.message";

    public static final String SOURCE_DATA_SUB_TYPE = "source_data.sub_type";

    public static final String ERROR_OCCURED = "error_occured";

    public static final String IS_STANDALONE_PAYMENT = "is_standalone_oayment";

    public static final String CREATED_AT = "created_at";

    public static final String REFUNDED_AMOUNT_CENTS = "refunded_amount_cents";

    public static final String INTEGRATION_ID = "integration_id";

    public static final String ORDER = "order";

    static final String REDIRECTION_URL = "redirection_url";

    static final String[] PAY_DICT_KEYS = new String[] {
            "amount_cents", "is_refunded", "is_capture", "captured_amount", "source_data.type", "pending",  "is_3d_secure", "id", "is_void",
            "currency", "is_auth", "is_refund", "owner", "is_voided", "source_data.pan", "profile_id", "success", "data.message", "source_data.sub_type",
            "error_occured", "is_standalone_payment", "created_at", "refunded_amount_cents", "integration_id", "order" };
}
