// To parse this JSON data, do
//
//     final paymentKeyRequest = paymentKeyRequestFromJson(jsonString);

import 'dart:convert';

PaymentResult? paymentResultFromJson(String str) =>
    PaymentResult.fromJson(json.decode(str));

class PaymentResult {
  PaymentResult({
    this.dataMessage,
    this.token,
    this.maskedPan,
    this.id,
  });

  String? dataMessage;
  String? token;
  String? maskedPan;
  String? id;

  factory PaymentResult.fromJson(Map<String, dynamic> json) => PaymentResult(
        dataMessage: json["data_message"] ?? json["data_message"],
        token: json["token"] ?? json["token"],
        maskedPan: json["masked_pan"] ?? json["masked_pan"],
        id: json["id"] ?? json["id"],
      );
}
