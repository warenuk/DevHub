import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_providers.dart';
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
      // Під час створення сесії додаємо user-id/email у заголовки для бекенда.
      final user = await ref.read(currentUserProvider.future);
      final sessionId = await _api.createCheckoutSession(
        plan,
        userId: user?.id,
        userEmail: user?.email,
      );
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
