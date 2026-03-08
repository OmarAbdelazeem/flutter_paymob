class SessionResponse {
  final String merchantOrderId;
  final int paymobOrderId;
  final String paymentKey;
  final String status;

  SessionResponse({
    required this.merchantOrderId,
    required this.paymobOrderId,
    required this.paymentKey,
    required this.status,
  });

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    return SessionResponse(
      merchantOrderId: json['merchant_order_id'] as String? ?? '',
      paymobOrderId: json['paymob_order_id'] as int? ?? 0,
      paymentKey: json['payment_key'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
    );
  }
}
