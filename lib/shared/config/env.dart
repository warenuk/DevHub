import 'package:flutter/foundation.dart';

enum AppFlavor { dev, stage, prod }

class Env {
  static const flavorStr = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );
  static AppFlavor get flavor => switch (flavorStr) {
        'prod' => AppFlavor.prod,
        'stage' => AppFlavor.stage,
        _ => AppFlavor.dev,
      };

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );
  static const enableTlsPinning = bool.fromEnvironment(
    'TLS_PINNING',
    defaultValue: false,
  );
  // Optional: override host to pin (defaults to host of apiBaseUrl)
  static const tlsPinHost = String.fromEnvironment(
    'TLS_PIN_HOST',
    defaultValue: '',
  );
  // Base64(SHA-256(cert DER)) pins: primary + backup
  static const tlsPinCertSha256 = String.fromEnvironment(
    'TLS_PIN_CERT_SHA256',
    defaultValue: '',
  );
  static const tlsPinCertSha256Backup = String.fromEnvironment(
    'TLS_PIN_CERT_SHA256_2',
    defaultValue: '',
  );

  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51SCEFwCg3QIJ5AEfFAwNn6jEcEQqkc4WR3D5e6O17SIBmCV33BRdOj2MhsXw3HdzE9k0qNRqxujEMnR3tghPdWWh00seAblCd1',
  );

  static const stripeBackendUrl = String.fromEnvironment(
    'STRIPE_BACKEND_URL',
    defaultValue: 'http://localhost:8899',
  );

  static bool get stripeIsConfigured =>
      stripePublishableKey.isNotEmpty && stripeBackendUrl.isNotEmpty;

  static bool get verboseHttpLogs => !kReleaseMode || flavor != AppFlavor.prod;
}
