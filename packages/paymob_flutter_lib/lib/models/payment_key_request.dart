// To parse this JSON data, do
//
//     final paymentKeyRequest = paymentKeyRequestFromJson(jsonString);

import 'dart:convert';

String paymentKeyRequestToJson(PaymentKeyRequest data,
        {Map<String, dynamic>? extra}) =>
    json.encode(data.toJson(extra));

class PaymentKeyRequest {
  PaymentKeyRequest({
    this.authToken,
    this.amountCents,
    this.expiration,
    this.orderId,
    this.billingData,
    this.currency,
    this.integrationId,
    this.lockOrderWhenPaid,
  });

  String? authToken;
  String? amountCents;
  int? expiration;
  String? orderId;
  BillingData? billingData;
  String? currency;
  int? integrationId;
  String? lockOrderWhenPaid;

  Map<String, dynamic> toJson(extra) => {
        "auth_token": authToken ?? authToken,
        "amount_cents": amountCents ?? amountCents,
        "expiration": expiration ?? expiration,
        "order_id": orderId ?? orderId,
        "billing_data": billingData ?? billingData!.toJson(),
        "extra": extra ?? "",
        "currency": currency ?? currency,
        "integration_id": integrationId ?? integrationId,
        "lock_order_when_paid": lockOrderWhenPaid ?? lockOrderWhenPaid,
      };
}

class BillingData {
  BillingData({
    this.apartment,
    this.email,
    this.floor,
    this.firstName,
    this.street,
    this.building,
    this.phoneNumber,
    this.shippingMethod,
    this.postalCode,
    this.city,
    this.country,
    this.lastName,
    this.state,
  });

  String? apartment;
  String? email;
  String? floor;
  String? firstName;
  String? street;
  String? building;
  String? phoneNumber;
  String? shippingMethod;
  String? postalCode;
  String? city;
  String? country;
  String? lastName;
  String? state;

  Map<String, dynamic> toJson() => {
        "apartment": apartment ?? apartment,
        "email": email ?? email,
        "floor": floor ?? floor,
        "first_name": firstName ?? firstName,
        "street": street ?? street,
        "building": building ?? building,
        "phone_number": phoneNumber ?? phoneNumber,
        "shipping_method": shippingMethod ?? shippingMethod,
        "postal_code": postalCode ?? postalCode,
        "city": city ?? city,
        "country": country ?? country,
        "last_name": lastName ?? lastName,
        "state": state ?? state,
      };
}
