/// Saved card from GET /users/me/cards (list). No token.
class SavedCard {
  final String id;
  final String maskedPan;
  final String? cardBrand;
  final String? lastFour;
  final String? createdAt;

  SavedCard({
    required this.id,
    required this.maskedPan,
    this.cardBrand,
    this.lastFour,
    this.createdAt,
  });

  factory SavedCard.fromJson(Map<String, dynamic> json) {
    return SavedCard(
      id: json['id'] as String? ?? '',
      maskedPan: json['masked_pan'] as String? ?? '',
      cardBrand: json['card_brand'] as String?,
      lastFour: json['last_four'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

/// Card details including paymob_token for payment (GET /users/me/cards/:cardId).
class CardDetailsForPayment extends SavedCard {
  final String paymobToken;

  CardDetailsForPayment({
    required super.id,
    required super.maskedPan,
    required this.paymobToken,
    super.cardBrand,
    super.lastFour,
    super.createdAt,
  });

  factory CardDetailsForPayment.fromJson(Map<String, dynamic> json) {
    return CardDetailsForPayment(
      id: json['id'] as String? ?? '',
      maskedPan: json['masked_pan'] as String? ?? '',
      paymobToken: json['paymob_token'] as String? ?? '',
      cardBrand: json['card_brand'] as String?,
      lastFour: json['last_four'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
