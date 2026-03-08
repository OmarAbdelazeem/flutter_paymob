class PaymentStatusResponse {
  final String status;
  final int amountCents;
  final String currency;
  final int? paymobOrderId;
  final String? updatedAt;

  PaymentStatusResponse({
    required this.status,
    required this.amountCents,
    required this.currency,
    this.paymobOrderId,
    this.updatedAt,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResponse(
      status: json['status'] as String? ?? 'PENDING',
      amountCents: json['amount_cents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      paymobOrderId: json['paymob_order_id'] as int?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  bool get isPaid => status == 'PAID';
  bool get isFailed => status == 'FAILED';
  bool get isPending => status == 'PENDING';
}
