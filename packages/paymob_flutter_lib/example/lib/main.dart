import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paymob_flutter_lib/models/order.dart';
import 'package:paymob_flutter_lib/models/payment.dart';
import 'package:paymob_flutter_lib/models/payment_key_request.dart';
import 'package:paymob_flutter_lib/models/payment_result.dart';
import 'dart:async';

import 'package:paymob_flutter_lib/paymob_flutter_lib.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _paymobFlutterLibPlugin = PaymobFlutterLib();
  // String apiKey = 'your_api_key';
  String apiKey =
      'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRJd056RXNJbTVoYldVaU9pSXhOall6TURjeE16WXlMakl4TkRVME5DSjkuZ0NiQnNiaW12SUswcGZzV084Q1RNUWtQUjFvOGpFdDYtdGY3UWFMeTdUWnU3S3FWYXBaNlNqMlZYMGladVh6Yk9PWkhzRmRDdVdaeUVQc0N3QnZYaXc=';

  String _auth = '';
  int _orderId = 0;
  String _paymentKey = '';

  String? _error = 'No Error';
  String? _result = 'Unknown';
  String? _token = 'Unknown';
  String? _maskedPan = 'Unknown';

  Future<void> authenticateRequest() async {
    try {
      String result = await PaymobFlutterLib.authenticateRequest(apiKey);
      if (!mounted) return;

      setState(() {
        _auth = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = '$e';
      });
    }
  }

  Future<void> registerOrder() async {
    try {
      int result = await PaymobFlutterLib.registerOrder(
        Order(
          authToken: _auth,
          deliveryNeeded: "false",
          amountCents: "35000",
          currency: "PKR",
          // merchantOrderId: 2194,
          items: [
            // Item(
            //   name: "ASC1515",
            //   amountCents: "35000",
            //   description: "Smart Watch",
            //   quantity: "1",
            // ),
            // Item(
            //     name: "ERT6565",
            //     amountCents: "1000",
            //     description: "Power Bank",
            //     quantity: "1",)
          ],
          // shippingData: ShippingData(
          //     apartment: "803",
          //     email: "claudette09@exa.com",
          //     floor: "42",
          //     firstName: "Clifford",
          //     street: "Ethan Land",
          //     building: "8028",
          //     phoneNumber: "+86(8)9135210487",
          //     postalCode: "01898",
          //     extraDescription: "8 Ram , 128 Giga",
          //     city: "Jaskolskiburgh",
          //     country: "CR",
          //     lastName: "Nicolas",
          //     state: "Utah"),
          // shippingDetails: ShippingDetails(
          //     notes: "test",
          //     numberOfPackages: 1,
          //     weight: 1,
          //     weightUnit: "Kilogram",
          //     length: 1,
          //     width: 1,
          //     height: 1,
          //     contents: "product of some sorts"),
        ),
      );
      if (!mounted) return;

      setState(() {
        _orderId = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = '$e';
      });
    }
  }

  Future<void> requestPaymentKey() async {
    try {
      String result = await PaymobFlutterLib.requestPaymentKey(
        PaymentKeyRequest(
          authToken: _auth,
          amountCents: "35000",
          expiration: 3600,
          orderId: _orderId.toString(),
          billingData: BillingData(
            firstName: "Bilal",
            lastName: "Ilyas",
            email: "bilal.ilyas1990@gmail.com",
            phoneNumber: "+923156702020",
            apartment: "NA",
            floor: "NA",
            street: "NA",
            building: "NA",
            postalCode: "NA",
            city: "Sargodha",
            state: "Punjab",
            country: "PK",
          ),
          currency: "PKR",
          integrationId: 12740,
          lockOrderWhenPaid: "false",
        ),
      );
      if (!mounted) return;

      setState(() {
        _paymentKey = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = '$e';
      });
    }
  }

  Future<void> startPayActivityNoToken() async {
    try {
      PaymentResult? result =
          await _paymobFlutterLibPlugin.startPayActivityNoToken(Payment(
        paymentKey: _paymentKey,
        saveCardDefault: false,
        showSaveCard: false,
        themeColor: const Color(0xFF002B36),
        language: "en",
        actionbar: true,
      ));
      if (!mounted) return;

      print("transID : ${result?.id}");
      print(result);
      setState(() {
        _result = result?.dataMessage;
        _token = result?.token;
        _maskedPan = result?.maskedPan;
      });
    } on PlatformException catch (err) {
      // Handle err
      print("PlatformException 1");
      print(err);
      setState(() {
        _error = '${err.message}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
      });
    }
  }

  Future<void> startPayActivityToken() async {
    try {
      String? result =
          await _paymobFlutterLibPlugin.startPayActivityToken(Payment(
        paymentKey: _paymentKey,
        saveCardDefault: false,
        showSaveCard: true,
        themeColor: const Color(0xFF002B36),
        language: "en",
        actionbar: true,
        token: _token,
        maskedPanNumber: _maskedPan,
        customer: Customer(
            firstName: "Eman",
            lastName: "Ahmed",
            phoneNumber: "+201012345678",
            email: "example@gmail.com",
            building: "7",
            floor: "9",
            apartment: "91",
            city: "Alexandria",
            state: "NA",
            country: "Egypt",
            postalCode: "NA"),
      ));
      if (!mounted) return;

      setState(() {
        _result = result;
      });
    } catch (e) {
      print("erorrrrrr 2");
      print(e);
      if (!mounted) return;
      setState(() {
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MaterialButton(
                onPressed: () async {
                  await authenticateRequest();
                },
                child: const Text('Authentication Request'),
              ),
              Text('auth: $_auth'),
              MaterialButton(
                onPressed: () async {
                  await registerOrder();
                },
                child: const Text('Order Registration API'),
              ),
              Text('orderId: $_orderId'),
              MaterialButton(
                onPressed: () async {
                  await requestPaymentKey();
                },
                child: const Text('Payment Key Request'),
              ),
              Text('paymentKey: $_paymentKey'),
              const Divider(),
              MaterialButton(
                onPressed: () async {
                  // print(_paymentKey);
                  await startPayActivityNoToken();
                },
                child: const Text('startPayActivityNoToken'),
              ),
              MaterialButton(
                onPressed: () async {
                  await startPayActivityToken();
                },
                child: const Text('startPayActivityToken'),
              ),
              Text(
                'error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
              const Text(
                "TRANSACTION_SUCCESSFUL : ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('result: $_result'),
              const Text(
                "TRANSACTION_SUCCESSFUL_CARD_SAVED",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('token: $_token'),
              Text('maskedPan: $_maskedPan'),
            ],
          ),
        ),
      ),
    );
  }
}
