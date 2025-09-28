import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/subscription_providers.dart';
import '../data/stripe_subscription_api.dart';
import '../domain/subscription_plan.dart';
import 'stripe_checkout_launcher.dart';

class SubscriptionController extends AsyncNotifier<void> {
  StripeSubscriptionApi get _api => ref.read(stripeSubscriptionApiProvider);
  StripeCheckoutLauncher get _launcher =>
      ref.read(stripeCheckoutLauncherProvider);

  @override
  Future<void> build() async {}

  Future<void> startCheckout(SubscriptionPlan plan) async {
    state = const AsyncLoading();
    try {
      final sessionId = await _api.createCheckoutSession(plan);
      await _launcher.redirectToCheckout(sessionId: sessionId);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final subscriptionCheckoutControllerProvider =
    AsyncNotifierProvider<SubscriptionController, void>(
  SubscriptionController.new,
);

String subscriptionErrorMessage(Object error) {
  if (error is StripeConfigurationException) {
    return error.message;
  }
  if (error is StripeResponseException) {
    return error.message;
  }
  if (error is UnsupportedError) {
    return error.message ?? 'Поточна платформа не підтримує Stripe Checkout.';
  }
  return 'Виникла невідома помилка: $error';
}
