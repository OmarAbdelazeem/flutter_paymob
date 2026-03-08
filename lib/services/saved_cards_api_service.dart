import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/saved_card.dart';
import 'user_service.dart';

class SavedCardsApiService {
  late final Dio _dio;

  SavedCardsApiService() {
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

  Map<String, String> _headers() => {
        'X-User-Id': UserService.instance.userId,
      };

  /// POST /users/me/cards - save card after payment when user chose "Save this card".
  Future<SavedCard> saveCard({
    required String paymobToken,
    required String maskedPan,
    String? cardBrand,
    String? lastFour,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/users/me/cards',
      data: {
        'paymob_token': paymobToken,
        'masked_pan': maskedPan,
        if (cardBrand != null) 'card_brand': cardBrand,
        if (lastFour != null) 'last_four': lastFour,
      },
      options: Options(headers: _headers()),
    );

    if (response.statusCode != 201) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }

    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty response from save card API');
    }

    return SavedCard.fromJson(data);
  }

  /// GET /users/me/cards - list saved cards.
  Future<List<SavedCard>> listCards() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/users/me/cards',
      options: Options(headers: _headers()),
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
      return [];
    }

    final list = data['cards'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => SavedCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /users/me/cards/:cardId - get token + masked_pan for Paymob SDK.
  Future<CardDetailsForPayment> getCardDetails(String cardId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/users/me/cards/$cardId',
      options: Options(headers: _headers()),
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
      throw const FormatException('Empty response from get card details API');
    }

    return CardDetailsForPayment.fromJson(data);
  }

  /// DELETE /users/me/cards/:cardId - remove saved card.
  Future<void> removeCard(String cardId) async {
    final response = await _dio.delete<void>(
      '/users/me/cards/$cardId',
      options: Options(headers: _headers()),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
