import 'package:flutter_test/flutter_test.dart';
import 'package:paymob_flutter_lib/models/payment_result.dart';
import 'package:paymob_flutter_lib/models/payment.dart';
import 'package:paymob_flutter_lib/paymob_flutter_lib.dart';
import 'package:paymob_flutter_lib/paymob_flutter_lib_platform_interface.dart';
import 'package:paymob_flutter_lib/paymob_flutter_lib_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPaymobFlutterLibPlatform
    with MockPlatformInterfaceMixin
    implements PaymobFlutterLibPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<PaymentResult?> startPayActivityNoToken(Payment payment) {
    // TODO: implement startPayActivityNoToken
    throw UnimplementedError();
  }

  @override
  Future<String?> startPayActivityToken(Payment payment) {
    // TODO: implement startPayActivityToken
    throw UnimplementedError();
  }
}

void main() {
  final PaymobFlutterLibPlatform initialPlatform =
      PaymobFlutterLibPlatform.instance;

  test('$MethodChannelPaymobFlutterLib is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPaymobFlutterLib>());
  });

  test('getPlatformVersion', () async {
    PaymobFlutterLib paymobFlutterLibPlugin = PaymobFlutterLib();
    MockPaymobFlutterLibPlatform fakePlatform = MockPaymobFlutterLibPlatform();
    PaymobFlutterLibPlatform.instance = fakePlatform;

    expect(await paymobFlutterLibPlugin.getPlatformVersion(), '42');
  });
}
