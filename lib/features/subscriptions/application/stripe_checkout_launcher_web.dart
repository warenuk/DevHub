import 'package:js/js_util.dart' as js_util;
import 'package:stripe_js/stripe_js.dart';

import '../data/stripe_subscription_api.dart';
import 'stripe_checkout_launcher.dart';

class WebStripeCheckoutLauncher implements StripeCheckoutLauncher {
  WebStripeCheckoutLauncher(this.publishableKey);

  final String publishableKey;
  Stripe? _stripe;

  Future<Stripe> _ensureClient() async {
    if (_stripe == null) {
      await loadStripe();
      _stripe = Stripe(publishableKey);
    }
    return _stripe!;
  }

  @override
  Future<void> redirectToCheckout({required String sessionId}) async {
    if (publishableKey.isEmpty) {
      throw const StripeConfigurationException(
        'Не вказано публічний ключ Stripe. Передайте STRIPE_PUBLISHABLE_KEY через dart-define.',
      );
    }

    final stripe = await _ensureClient();
    final result = await js_util.promiseToFuture<Object?>(
      js_util.callMethod(
        stripe,
        'redirectToCheckout',
        [js_util.jsify({'sessionId': sessionId})],
      ),
    );

    if (result == null) {
      return;
    }

    final error = js_util.getProperty(result, 'error');
    if (error != null) {
      final message = js_util.getProperty(error, 'message') as String?;
      throw StripeResponseException(
        message ?? 'Stripe повернув помилку під час редиректу.',
      );
    }
  }
}

StripeCheckoutLauncher buildStripeCheckoutLauncher(String publishableKey) {
  return WebStripeCheckoutLauncher(publishableKey);
}
