import 'dart:js_util' as js_util;
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
final Object stripeObj = stripe as Object;
final Object checkoutArgs = js_util.jsify({'sessionId': sessionId}) as Object;
final Object jsPromise = js_util.callMethod<Object>(
  stripeObj,
  'redirectToCheckout',
  [checkoutArgs],
) as Object;
final Object? callResult = await js_util.promiseToFuture<Object?>(jsPromise);

if (callResult == null) {
  return;
}

final Object nonNullResult = callResult as Object;
final Object? error = js_util.getProperty<Object?>(nonNullResult, 'error');
if (error != null) {
  final String? message = js_util.getProperty<String?>(error, 'message');
  throw StripeResponseException(
    message ?? 'Stripe повернув помилку під час редиректу.',
  );
}
}
}

StripeCheckoutLauncher buildStripeCheckoutLauncher(String publishableKey) {
return WebStripeCheckoutLauncher(publishableKey);
}
