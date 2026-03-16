import 'dart:convert';

class SessionRequest {
  final String merchantOrderId;
  final int amountCents;
  final String currency;
  final SessionCustomer customer;
  final SessionBilling billing;
  /// When paying with a saved card, pass the card id so the backend can
  /// create the intention with card_tokens (Paymob Create Intention API).
  final String? savedCardUuid;

  SessionRequest({
    required this.merchantOrderId,
    required this.amountCents,
    required this.currency,
    required this.customer,
    required this.billing,
    this.savedCardUuid,
  });

  Map<String, dynamic> toJson() => {
        'merchant_order_id': merchantOrderId,
        'amount_cents': amountCents,
        'currency': currency,
        'customer': customer.toJson(),
        'billing': billing.toJson(),
        if (savedCardUuid != null) 'saved_card_uuid': savedCardUuid,
      };

  String toJsonString() => jsonEncode(toJson());
}

class SessionCustomer {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;

  SessionCustomer({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      };
}

class SessionBilling {
  final String apartment;
  final String floor;
  final String street;
  final String building;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  SessionBilling({
    this.apartment = 'NA',
    this.floor = 'NA',
    this.street = 'NA',
    this.building = 'NA',
    this.city = 'Cairo',
    this.state = 'Cairo',
    this.country = 'EG',
    this.postalCode = '00000',
  });

  Map<String, dynamic> toJson() => {
        'apartment': apartment,
        'floor': floor,
        'street': street,
        'building': building,
        'city': city,
        'state': state,
        'country': country,
        'postal_code': postalCode,
      };
}
