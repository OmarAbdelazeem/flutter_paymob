import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/payment_status_response.dart';
import '../models/session_request.dart';
import '../models/session_response.dart';
import 'user_service.dart';

class PaymentApiService {
  late final Dio _dio;

  PaymentApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Creates a Paymob session (backend should use Create Intention API) and
  /// returns client_secret and optional public_key for the official Paymob SDK.
  Future<SessionResponse> createPaymobSession(SessionRequest request) async {
    if (kDebugMode) {
      debugPrint('[Paymob] createPaymobSession payload=${jsonEncode(request.toJson())}');
    }
    final response = await _dio.post<Map<String, dynamic>>(
      '/payments/paymob/session',
      data: request.toJson(),
      options: Options(
        headers: {
          'X-User-Id': UserService.instance.userId,
        },
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }

    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty response from session API');
    }

    return SessionResponse.fromJson(data);
  }

  /// Gets the current payment status for an order.
  Future<PaymentStatusResponse> getPaymentStatus(String merchantOrderId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/orders/$merchantOrderId/payment-status',
    );

    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }

    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty response from payment-status API');
    }

    return PaymentStatusResponse.fromJson(data);
  }

  /// Gets a demo merchant order ID for testing (optional).
  Future<String> getDemoOrderId() async {
    final response = await _dio.post<Map<String, dynamic>>('/demo/orders');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }

    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty response from demo/orders API');
    }

    final merchantOrderId = data['merchant_order_id'] as String?;
    if (merchantOrderId == null || merchantOrderId.isEmpty) {
      throw const FormatException('Missing merchant_order_id in demo response');
    }

    return merchantOrderId;
  }
}
