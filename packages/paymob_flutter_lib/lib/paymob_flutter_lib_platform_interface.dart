import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'models/payment.dart';
import 'models/payment_result.dart';
import 'paymob_flutter_lib_method_channel.dart';

abstract class PaymobFlutterLibPlatform extends PlatformInterface {
  /// Constructs a PaymobFlutterLibPlatform.
  PaymobFlutterLibPlatform() : super(token: _token);

  static final Object _token = Object();

  static PaymobFlutterLibPlatform _instance = MethodChannelPaymobFlutterLib();

  /// The default instance of [PaymobFlutterLibPlatform] to use.
  ///
  /// Defaults to [MethodChannelPaymobFlutterLib].
  static PaymobFlutterLibPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PaymobFlutterLibPlatform] when
  /// they register themselves.
  static set instance(PaymobFlutterLibPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<PaymentResult?> startPayActivityNoToken(Payment payment) {
    throw UnimplementedError(
        'startPayActivityNoToken() has not been implemented.');
  }

  Future<String?> startPayActivityToken(Payment payment) {
    throw UnimplementedError(
        'startPayActivityToken() has not been implemented.');
  }
}
