// To parse this JSON data, do
//
//     final payment = paymentFromJson(jsonString);

import 'dart:convert';

import 'dart:ui';

String paymentToJson(Payment data) => json.encode(data.toJson());

class Payment {
  Payment({
    this.paymentKey,
    this.saveCardDefault,
    this.showSaveCard,
    this.themeColor,
    this.language,
    this.actionbar,
    this.token,
    this.maskedPanNumber,
    this.customer,
  });

  String? paymentKey;
  bool? saveCardDefault;
  bool? showSaveCard;
  Color? themeColor;
  String? language;
  bool? actionbar;
  String? token;
  String? maskedPanNumber;
  Customer? customer;

  Map<String, dynamic> toJson() => {
        "payment_key": paymentKey ?? paymentKey,
        "save_card_default": saveCardDefault ?? saveCardDefault,
        "show_save_card": showSaveCard ?? showSaveCard,
        "theme_color": themeColor == null
            ? null
            : '#${themeColor?.value.toRadixString(16)}',
        "language": language ?? language,
        "actionbar": actionbar ?? actionbar,
        "token": token ?? token,
        "masked_pan_number": maskedPanNumber ?? maskedPanNumber,
        "customer": customer ?? customer?.toJson(),
      };
}

class Customer {
  Customer({
    this.firstName,
    this.lastName,
    this.building,
    this.floor,
    this.apartment,
    this.city,
    this.state,
    this.country,
    this.email,
    this.phoneNumber,
    this.postalCode,
  });

  String? firstName;
  String? lastName;
  String? building;
  String? floor;
  String? apartment;
  String? city;
  String? state;
  String? country;
  String? email;
  String? phoneNumber;
  String? postalCode;

  Map<String, dynamic> toJson() => {
        "first_name": firstName ?? firstName,
        "last_name": lastName ?? lastName,
        "building": building ?? building,
        "floor": floor ?? floor,
        "apartment": apartment ?? apartment,
        "city": city ?? city,
        "state": state ?? state,
        "country": country ?? country,
        "email": email ?? email,
        "phone_number": phoneNumber ?? phoneNumber,
        "postal_code": postalCode ?? postalCode,
      };
}
