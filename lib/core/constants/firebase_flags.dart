import 'package:flutter/foundation.dart';

/// Flags that toggle Firebase services without removing dependencies.
///
/// They are controlled via Dart defines at build/runtime level.
/// Example: `flutter run --dart-define=USE_FIREBASE=false`.
const bool kUseFirebase = bool.fromEnvironment(
  'USE_FIREBASE',
  defaultValue: true,
);

/// Dedicated flag for Firebase Authentication usage.
/// Falls back to [kUseFirebase] when specific override is not provided.
const bool kUseFirebaseAuth =
    bool.fromEnvironment('USE_FIREBASE_AUTH', defaultValue: true) &&
    kUseFirebase;

/// Dedicated flag for Firebase Cloud Messaging.
/// Disabled automatically for web tests when Firebase is disabled.
const bool kUseFirebaseMessaging =
    bool.fromEnvironment('USE_FIREBASE_MESSAGING', defaultValue: true) &&
    kUseFirebase;

const bool kInFlutterTest = bool.fromEnvironment(
  'FLUTTER_TEST',
  defaultValue: false,
);

/// Helper that checks if the current target platform is supported by
/// `firebase_messaging`.
bool get isFirebaseMessagingSupportedPlatform {
  if (kInFlutterTest) return false;
  if (kIsWeb) return true;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return true;
    case TargetPlatform.fuchsia:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return false;
  }
}
