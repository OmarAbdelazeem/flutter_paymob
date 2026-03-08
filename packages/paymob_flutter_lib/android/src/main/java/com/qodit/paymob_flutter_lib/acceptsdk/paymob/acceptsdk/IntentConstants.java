package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk;

public final class IntentConstants {
    static final Integer CARD_IO_SCAN_REQUEST = Integer.valueOf(16);

    static final Integer THREE_D_SECURE_VERIFICATION_REQUEST = Integer.valueOf(32);

    public static final int USER_CANCELED = 1;

    public static final int MISSING_ARGUMENT = 2;

    public static final int TRANSACTION_ERROR = 3;

    public static final int TRANSACTION_REJECTED = 4;

    public static final int TRANSACTION_REJECTED_PARSING_ISSUE = 5;

    public static final int TRANSACTION_SUCCESSFUL = 6;

    public static final int TRANSACTION_SUCCESSFUL_PARSING_ISSUE = 7;

    public static final int TRANSACTION_SUCCESSFUL_CARD_SAVED = 8;

    public static final int USER_CANCELED_3D_SECURE_VERIFICATION = 9;

    public static final int USER_CANCELED_3D_SECURE_VERIFICATION_PARSING_ISSUE = 10;

    static final int USER_FINISHED_3D_VERIFICATION = 17;

    public static final String TRANSACTION_ERROR_REASON = "transaction_error_reason";

    public static final String RAW_PAY_RESPONSE = "raw_pay_response";

    public static final String MISSING_ARGUMENT_VALUE = "missing_argument_value";
}
