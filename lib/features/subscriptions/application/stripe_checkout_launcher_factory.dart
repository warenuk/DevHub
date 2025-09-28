import 'stripe_checkout_launcher.dart';
import 'stripe_checkout_launcher_stub.dart'
    if (dart.library.html) 'stripe_checkout_launcher_web.dart';

StripeCheckoutLauncher createStripeCheckoutLauncher(String publishableKey) {
  return buildStripeCheckoutLauncher(publishableKey);
}
