import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/config/env.dart';
import '../application/stripe_checkout_launcher.dart';
import '../application/stripe_checkout_launcher_factory.dart';
import 'stripe_subscription_api.dart';

final stripePublishableKeyProvider = Provider<String>((ref) {
  return Env.stripePublishableKey;
});

final stripeBackendUrlProvider = Provider<String>((ref) {
  return Env.stripeBackendUrl;
});

final stripeSubscriptionApiProvider = Provider<StripeSubscriptionApi>((ref) {
  final backendUrl = ref.watch(stripeBackendUrlProvider);
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: const {'Content-Type': 'application/json'},
    ),
  );
  return StripeSubscriptionApi(dio: dio, backendUrl: backendUrl);
});

final stripeCheckoutLauncherProvider = Provider<StripeCheckoutLauncher>((ref) {
  final publishableKey = ref.watch(stripePublishableKeyProvider);
  return createStripeCheckoutLauncher(publishableKey);
});

final stripeConfigurationStatusProvider = Provider<bool>((ref) {
  return Env.stripeIsConfigured;
});
