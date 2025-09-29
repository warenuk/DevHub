import 'package:devhub_gpt/features/subscriptions/application/stripe_checkout_launcher.dart';
import 'package:devhub_gpt/features/subscriptions/application/subscription_controller.dart';
import 'package:devhub_gpt/features/subscriptions/data/subscription_providers.dart';
import 'package:devhub_gpt/features/subscriptions/data/stripe_subscription_api.dart';
import 'package:devhub_gpt/features/subscriptions/domain/subscription_plan.dart';
import 'package:devhub_gpt/shared/providers/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockStripeSubscriptionApi extends Mock implements StripeSubscriptionApi {}

class MockStripeCheckoutLauncher extends Mock
    implements StripeCheckoutLauncher {}

void main() {
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

  late MockStripeSubscriptionApi api;
  late MockStripeCheckoutLauncher launcher;
  late ProviderContainer container;

  setUp(() async {
    api = MockStripeSubscriptionApi();
    launcher = MockStripeCheckoutLauncher();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        stripeSubscriptionApiProvider.overrideWithValue(api),
        stripeCheckoutLauncherProvider.overrideWithValue(launcher),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('startCheckout triggers api and launcher', () async {
    when(
      () => api.createCheckoutSession(plan),
    ).thenAnswer((_) async => 'sess_123');
    when(
      () => launcher.redirectToCheckout(sessionId: 'sess_123'),
    ).thenAnswer((_) async {});

    final controller = container.read(
      subscriptionCheckoutControllerProvider.notifier,
    );
    final future = controller.startCheckout(plan);

    expect(controller.state, isA<AsyncLoading<void>>());
    await future;

    expect(controller.state, isA<AsyncData<void>>());
    verify(() => api.createCheckoutSession(plan)).called(1);
    verify(() => launcher.redirectToCheckout(sessionId: 'sess_123')).called(1);
  });

  test('startCheckout stores error when api fails', () async {
    when(
      () => api.createCheckoutSession(plan),
    ).thenAnswer((_) async => throw const StripeResponseException('oops'));

    final controller = container.read(
      subscriptionCheckoutControllerProvider.notifier,
    );
    await controller.startCheckout(plan);

    expect(controller.state, isA<AsyncError<void>>());
    final error = (controller.state as AsyncError<void>).error;
    expect(error, isA<StripeResponseException>());
    verifyNever(
      () => launcher.redirectToCheckout(sessionId: any(named: 'sessionId')),
    );
  });

  group('subscriptionErrorMessage', () {
    test('formats configuration exception', () {
      const error = StripeConfigurationException('missing');
      expect(subscriptionErrorMessage(error), 'missing');
    });

    test('formats response exception', () {
      const error = StripeResponseException('invalid');
      expect(subscriptionErrorMessage(error), 'invalid');
    });

    test('formats unsupported error', () {
      final error = UnsupportedError('unsupported');
      expect(subscriptionErrorMessage(error), 'unsupported');
    });

    test('falls back to default message', () {
      expect(subscriptionErrorMessage(Exception('boom')), contains('boom'));
    });
  });
}
