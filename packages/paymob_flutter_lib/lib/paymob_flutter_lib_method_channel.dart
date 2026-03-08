import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models/payment.dart';
import 'models/payment_result.dart';
import 'paymob_flutter_lib_platform_interface.dart';

/// An implementation of [PaymobFlutterLibPlatform] that uses method channels.
class MethodChannelPaymobFlutterLib extends PaymobFlutterLibPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('paymob_flutter_lib');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<PaymentResult?> startPayActivityNoToken(Payment payment) async {
    String strPayment = paymentToJson(payment);
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Paymob MethodChannel] Invoking StartPayActivityNoToken (payment_key present: ${payment.paymentKey != null && payment.paymentKey!.isNotEmpty})');
    }
    final result = await methodChannel.invokeMethod<String>(
        'StartPayActivityNoToken', {"payment": strPayment});
    if (kDebugMode) {
      final preview = result != null ? (result.length > 80 ? '${result.substring(0, 80)}...' : result) : 'null';
      // ignore: avoid_print
      print('[Paymob MethodChannel] StartPayActivityNoToken returned: $preview');
    }
    return paymentResultFromJson(result!);
  }

  @override
  Future<String?> startPayActivityToken(Payment payment) async {
    final String result = await methodChannel.invokeMethod(
        'StartPayActivityToken', {"payment": paymentToJson(payment)});
    return result;
  }
}
