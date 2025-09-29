import 'dart:convert';

import 'package:devhub_gpt/features/subscriptions/data/subscription_providers.dart';
import 'package:devhub_gpt/features/subscriptions/domain/active_subscription.dart';
import 'package:devhub_gpt/features/subscriptions/presentation/providers/active_subscription_providers.dart';
import 'package:devhub_gpt/features/subscriptions/data/stripe_subscription_api.dart';
import 'package:devhub_gpt/shared/providers/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockStripeSubscriptionApi extends Mock
    implements StripeSubscriptionApi {}

void main() {
  test('loads cached subscription and refreshes remote status', () async {
    SharedPreferences.setMockInitialValues({
      'active_subscription': jsonEncode({
        'subscriptionId': 'sub_cached',
        'status': 'active',
        'priceId': 'price_cached',
        'productId': 'prod_cached',
        'currentPeriodEnd': 9999999999,
      }),
    });
    final prefs = await SharedPreferences.getInstance();
    final api = _MockStripeSubscriptionApi();
    final updated = ActiveSubscription(
      subscriptionId: 'sub_cached',
      status: 'active',
      priceId: 'price_updated',
      productId: 'prod_cached',
      currentPeriodEnd:
          DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch ~/
              1000,
    );
    when(() => api.fetchSubscriptionStatus('sub_cached'))
        .thenAnswer((_) async => updated);

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        stripeSubscriptionApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(activeSubscriptionProvider), isNull);

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final loaded = container.read(activeSubscriptionProvider);
    expect(loaded, isNotNull);
    expect(loaded!.subscriptionId, 'sub_cached');
    expect(loaded.priceId, 'price_updated');
    verify(() => api.fetchSubscriptionStatus('sub_cached')).called(1);
    expect(
      prefs.getString('active_subscription'),
      contains('price_updated'),
    );
  });

  test('set(null) clears repository and state', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final api = _MockStripeSubscriptionApi();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        stripeSubscriptionApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(activeSubscriptionProvider.notifier);
    final subscription = ActiveSubscription(
      subscriptionId: 'sub_123',
      status: 'active',
      priceId: 'price_123',
      productId: 'prod_123',
      currentPeriodEnd:
          DateTime.now().add(const Duration(days: 10)).millisecondsSinceEpoch ~/
              1000,
    );

    await controller.set(subscription);
    expect(container.read(activeSubscriptionProvider), isNotNull);
    expect(prefs.getString('active_subscription'), isNotNull);

    await controller.set(null);
    expect(container.read(activeSubscriptionProvider), isNull);
    expect(prefs.getString('active_subscription'), isNull);
  });

  test('refresh is a no-op when subscription id missing', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final api = _MockStripeSubscriptionApi();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        stripeSubscriptionApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(activeSubscriptionProvider.notifier);
    await controller.refresh();
    verifyNever(() => api.fetchSubscriptionStatus(any()));
  });
}
