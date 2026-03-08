import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paymob_flutter_lib/paymob_flutter_lib_method_channel.dart';

void main() {
  MethodChannelPaymobFlutterLib platform = MethodChannelPaymobFlutterLib();
  const MethodChannel channel = MethodChannel('paymob_flutter_lib');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (message) {
      return Future.value("42");
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (message) {
        return Future.value(null);
      },
    );
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
