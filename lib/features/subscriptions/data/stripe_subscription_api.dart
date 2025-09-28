import 'package:dio/dio.dart';

import '../domain/subscription_plan.dart';

class StripeConfigurationException implements Exception {
  const StripeConfigurationException(this.message);

  final String message;

  @override
  String toString() => 'Stripe configuration error: $message';
}

class StripeResponseException implements Exception {
  const StripeResponseException(this.message);

  final String message;

  @override
  String toString() => 'Stripe response error: $message';
}

class StripeSubscriptionApi {
  StripeSubscriptionApi({
    required Dio dio,
    required this.backendUrl,
  }) : _dio = dio;

  final Dio _dio;
  final String backendUrl;

  Future<String> createCheckoutSession(SubscriptionPlan plan) async {
    if (plan.priceId.isEmpty) {
      throw const StripeConfigurationException(
        'Для плану не вказано ідентифікатор ціни Stripe.',
      );
    }

    if (backendUrl.isEmpty) {
      throw const StripeConfigurationException(
        'Не налаштовано бекенд для Stripe. Додайте STRIPE_BACKEND_URL у dart-define.',
      );
    }

    final base = backendUrl.endsWith('/') ? backendUrl : '$backendUrl/';
    final uri = Uri.parse(base).resolve('subscriptions/create-checkout-session');

    try {
      final isProduct = plan.priceId.startsWith('prod_');
      final payload = isProduct
          ? <String, dynamic>{'productId': plan.priceId}
          : <String, dynamic>{'priceId': plan.priceId};

      final response = await _dio.postUri<Map<String, dynamic>>(
        uri,
        data: payload,
      );
      final data = response.data;
      final sessionId = data?['sessionId'] as String?;
      if (sessionId == null || sessionId.isEmpty) {
        throw const StripeResponseException(
          'Stripe повернув відповідь без sessionId.',
        );
      }
      return sessionId;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw const StripeResponseException('Тайм-аут 10с при зверненні до бекенда.');
      }
      final status = error.response?.statusCode;
      final body = error.response?.data;
      throw StripeResponseException(
        'Не вдалося створити сесію оплати (HTTP $status): $body',
      );
    }
  }
}
