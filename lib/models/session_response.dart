class SessionResponse {
  final String merchantOrderId;
  final int paymobOrderId;
  /// Backend may return payment_key (legacy) or client_secret (Create Intention API).
  /// We expose both for compatibility; use clientSecret for the official Paymob SDK.
  final String paymentKey;
  final String status;
  /// Client secret from Create Intention API. If present, use this for payWithPaymob.
  /// Otherwise paymentKey is used as clientSecret (backward compat).
  final String? clientSecret;
  /// Public key from backend (optional). If null, use ApiConfig.paymobPublicKey.
  final String? publicKey;

  SessionResponse({
    required this.merchantOrderId,
    required this.paymobOrderId,
    required this.paymentKey,
    required this.status,
    this.clientSecret,
    this.publicKey,
  });

  /// Value to pass to Paymob SDK as clientSecret (Create Intention API token).
  String get effectiveClientSecret => clientSecret ?? paymentKey;

  /// Value to pass to Paymob SDK as publicKey (integration credential).
  String effectivePublicKey(String fallbackFromConfig) =>
      publicKey ?? fallbackFromConfig;

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    return SessionResponse(
      merchantOrderId: json['merchant_order_id'] as String? ?? '',
      paymobOrderId: json['paymob_order_id'] as int? ?? 0,
      paymentKey: json['payment_key'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      clientSecret: json['client_secret'] as String?,
      publicKey: json['public_key'] as String?,
    );
  }
}
