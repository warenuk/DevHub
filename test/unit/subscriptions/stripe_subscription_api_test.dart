import 'package:devhub_gpt/features/subscriptions/data/stripe_subscription_api.dart';
import 'package:devhub_gpt/features/subscriptions/domain/active_subscription.dart';
import 'package:devhub_gpt/features/subscriptions/domain/subscription_plan.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
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
        () =>
            dio.postUri<Map<String, dynamic>>(any(), data: any(named: 'data')),
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
        () =>
            dio.postUri<Map<String, dynamic>>(any(), data: any(named: 'data')),
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
        () =>
            dio.postUri<Map<String, dynamic>>(any(), data: any(named: 'data')),
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

    test('fetchSubscriptionStatus returns parsed data', () async {
      when(() => dio.getUri<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          data: {
            'subscriptionId': 'sub_123',
            'subscription_status': 'active',
            'priceId': 'price_456',
            'productId': 'prod_789',
            'current_period_end': 12345,
            'customer': 'cus_001',
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final ActiveSubscription? result = await api.fetchSubscriptionStatus(
        'sub_123',
      );

      expect(result, isNotNull);
      expect(result!.subscriptionId, 'sub_123');
      expect(result.status, 'active');
      expect(result.priceId, 'price_456');
      verify(
        () => dio.getUri<Map<String, dynamic>>(
          Uri.parse(
            'https://backend.test/api/subscriptions/status?subscriptionId=sub_123',
          ),
        ),
      ).called(1);
    });

    test('fetchSubscriptionStatus returns null on 404', () async {
      when(() => dio.getUri<Map<String, dynamic>>(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      final result = await api.fetchSubscriptionStatus('sub_missing');

      expect(result, isNull);
    });

    test('fetchSubscriptionStatus wraps errors', () async {
      when(() => dio.getUri<Map<String, dynamic>>(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 500,
            data: {'error': 'boom'},
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      expect(
        () => api.fetchSubscriptionStatus('sub_123'),
        throwsA(isA<StripeResponseException>()),
      );
    });
  });
}
