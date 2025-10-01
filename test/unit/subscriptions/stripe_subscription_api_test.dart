import 'package:devhub_gpt/features/subscriptions/data/stripe_subscription_api.dart';
import 'package:devhub_gpt/features/subscriptions/domain/subscription_plan.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
    registerFallbackValue(Options());
  });

  group('StripeSubscriptionApi', () {
    const plan = SubscriptionPlan(
      id: 'starter',
      priceId: 'price_123',
      name: 'Starter',
      description: 'desc',
      amount: 990,
      currency: 'usd',
      interval: 'month',
      features: ['one'],
    );

    late MockDio dio;
    late StripeSubscriptionApi api;

    setUp(() {
      dio = MockDio();
      api = StripeSubscriptionApi(
        dio: dio,
        backendUrl: 'https://backend.test/api/',
      );
    });

    test('creates checkout session with correct payload', () async {
      when(
        () => dio.postUri<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'sessionId': 'sess_123'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final sessionId = await api.createCheckoutSession(plan);

      expect(sessionId, 'sess_123');
      verify(
        () => dio.postUri<Map<String, dynamic>>(
          Uri.parse(
            'https://backend.test/api/subscriptions/create-checkout-session',
          ),
          data: {'priceId': 'price_123'},
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('throws when priceId is missing', () async {
      const invalidPlan = SubscriptionPlan(
        id: 'starter',
        priceId: '',
        name: 'Starter',
        description: 'desc',
        amount: 990,
        currency: 'usd',
        interval: 'month',
        features: ['one'],
      );

      expect(
        () => api.createCheckoutSession(invalidPlan),
        throwsA(isA<StripeConfigurationException>()),
      );
    });

    test('throws when backend url is empty', () async {
      api = StripeSubscriptionApi(dio: dio, backendUrl: '');

      expect(
        () => api.createCheckoutSession(plan),
        throwsA(isA<StripeConfigurationException>()),
      );
    });

    test('throws when response is missing sessionId', () async {
      when(
        () => dio.postUri<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: const <String, dynamic>{},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => api.createCheckoutSession(plan),
        throwsA(isA<StripeResponseException>()),
      );
    });

    test('wraps DioException into StripeResponseException', () async {
      when(
        () => dio.postUri<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 500,
            data: {'error': 'server'},
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      expect(
        () => api.createCheckoutSession(plan),
        throwsA(isA<StripeResponseException>()),
      );
    });
  });
}
