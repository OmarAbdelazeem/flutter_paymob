import 'package:flutter/services.dart';

/// Result from the official Paymob SDK (payWithPaymob).
/// Status is "Successfull" | "Rejected" | "Pending" (doc spelling).
/// Details may contain token and masked_pan when card was saved (e.g. on iOS).
class PaymobSdkResult {
  const PaymobSdkResult({
    required this.status,
    this.details,
  });

  final String status;
  final Map<String, dynamic>? details;

  bool get isSuccess => status == 'Successfull';
  bool get isRejected => status == 'Rejected';
  bool get isPending => status == 'Pending';

  String? get token => details?['token'] as String?;
  String? get maskedPan => details?['masked_pan'] as String?;
}

/// Bridge to the official Paymob iOS/Android SDKs via method channel.
/// Backend must use Create Intention API and provide client_secret (and app
/// must have public_key from config or session).
class PaymobSdkService {
  PaymobSdkService() : _channel = const MethodChannel('paymob_sdk_flutter');

  final MethodChannel _channel;

  /// Calls the native Paymob SDK with publicKey and clientSecret (from
  /// Create Intention API). Optional UI params: appName, button colors,
  /// saveCardDefault, showSaveCard.
  /// Returns [PaymobSdkResult] with status and optional details (e.g. token
  /// and masked_pan for save-card flow when SDK returns them).
  Future<PaymobSdkResult> payWithPaymob({
    required String publicKey,
    required String clientSecret,
    String? appName,
    Color? buttonBackgroundColor,
    Color? buttonTextColor,
    bool saveCardDefault = false,
    bool showSaveCard = true,
  }) async {
    final args = <String, dynamic>{
      'publicKey': publicKey,
      'clientSecret': clientSecret,
      'saveCardDefault': saveCardDefault,
      'showSaveCard': showSaveCard,
    };
    if (appName != null) args['appName'] = appName;
    if (buttonBackgroundColor != null) {
      args['buttonBackgroundColor'] = buttonBackgroundColor.toARGB32();
    }
    if (buttonTextColor != null) {
      args['buttonTextColor'] = buttonTextColor.toARGB32();
    }

    final raw = await _channel.invokeMethod<dynamic>('payWithPaymob', args);

    return _parseResult(raw);
  }

  PaymobSdkResult _parseResult(dynamic raw) {
    if (raw == null) {
      return const PaymobSdkResult(status: 'Rejected');
    }
    if (raw is String) {
      return PaymobSdkResult(status: raw);
    }
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final status = map['status'] as String? ?? 'Rejected';
      final details = map['details'] as Map<String, dynamic>?;
      return PaymobSdkResult(status: status, details: details != null ? Map<String, dynamic>.from(details) : null);
    }
    return const PaymobSdkResult(status: 'Rejected');
  }
}
