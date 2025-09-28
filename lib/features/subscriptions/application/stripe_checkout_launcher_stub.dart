import 'stripe_checkout_launcher.dart';

class UnsupportedStripeCheckoutLauncher implements StripeCheckoutLauncher {
  const UnsupportedStripeCheckoutLauncher(this.publishableKey);

  final String publishableKey;

  @override
  Future<void> redirectToCheckout({required String sessionId}) {
    final reason = publishableKey.isEmpty
        ? 'Не вказано публічний ключ Stripe. Передайте STRIPE_PUBLISHABLE_KEY через dart-define.'
        : 'Stripe Checkout доступний лише у веб-версії. Поточна платформа не підтримується.';
    throw UnsupportedError(reason);
  }
}

StripeCheckoutLauncher buildStripeCheckoutLauncher(String publishableKey) {
  return UnsupportedStripeCheckoutLauncher(publishableKey);
}
