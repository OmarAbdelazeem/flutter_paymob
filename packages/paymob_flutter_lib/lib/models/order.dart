import 'dart:convert';

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  Order({
    this.authToken,
    this.deliveryNeeded,
    this.amountCents,
    this.currency,
    this.merchantOrderId,
    this.items,
    this.shippingData,
    this.shippingDetails,
  });

  String? authToken;
  String? deliveryNeeded;
  String? amountCents;
  String? currency;
  int? merchantOrderId;
  List<Item>? items;
  ShippingData? shippingData;
  ShippingDetails? shippingDetails;

  Map<String, dynamic> toJson() => {
        "auth_token": authToken ?? authToken,
        "delivery_needed": deliveryNeeded ?? deliveryNeeded,
        "amount_cents": amountCents ?? amountCents,
        "currency": currency ?? currency,
        // "merchant_order_id": merchantOrderId ?? merchantOrderId,
        "items": items == null
            ? null
            : List<dynamic>.from(items!.map((x) => x.toJson())),
        // "shipping_data": shippingData ?? shippingData.toJson(),
        // "shipping_details":
        // shippingDetails ?? shippingDetails.toJson(),
      };
}

class Item {
  Item({
    this.name,
    this.amountCents,
    this.description,
    this.quantity,
  });

  String? name;
  String? amountCents;
  String? description;
  String? quantity;

  Map<String, dynamic> toJson() => {
        "name": name ?? name,
        "amount_cents": amountCents ?? amountCents,
        "description": description ?? description,
        "quantity": quantity ?? quantity,
      };
}

class ShippingData {
  ShippingData({
    this.apartment,
    this.email,
    this.floor,
    this.firstName,
    this.street,
    this.building,
    this.phoneNumber,
    this.postalCode,
    this.extraDescription,
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
  String? postalCode;
  String? extraDescription;
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
        "postal_code": postalCode ?? postalCode,
        "extra_description": extraDescription ?? extraDescription,
        "city": city ?? city,
        "country": country ?? country,
        "last_name": lastName ?? lastName,
        "state": state ?? state,
      };
}

class ShippingDetails {
  ShippingDetails({
    this.notes,
    this.numberOfPackages,
    this.weight,
    this.weightUnit,
    this.length,
    this.width,
    this.height,
    this.contents,
  });

  String? notes;
  int? numberOfPackages;
  int? weight;
  String? weightUnit;
  int? length;
  int? width;
  int? height;
  String? contents;

  Map<String, dynamic> toJson() => {
        "notes": notes ?? notes,
        "number_of_packages": numberOfPackages ?? numberOfPackages,
        "weight": weight ?? weight,
        "weight_unit": weightUnit ?? weightUnit,
        "length": length ?? length,
        "width": width ?? width,
        "height": height ?? height,
        "contents": contents ?? contents,
      };
}
