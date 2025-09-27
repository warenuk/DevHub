import 'package:devhub_gpt/shared/config/remote_config/remote_config_defaults.dart';

/// Available visual variants for the onboarding experience.
///
/// The variant is selected by a numeric flag from Firebase Remote Config.
/// Values outside of the known range gracefully fall back to [orbit].
enum OnboardingVariant {
  /// Neon-inspired orbit animation with floating cards.
  orbit(1),

  /// Blueprint-styled wireframes with scanning highlights.
  blueprint(2),

  /// Pulse-driven gradients with live widgets.
  pulse(3);

  const OnboardingVariant(this.remoteValue);

  /// Value stored in Remote Config for this variant.
  final int remoteValue;

  /// Returns the matching variant for [value], defaulting to [orbit].
  static OnboardingVariant fromRemoteValue(int? value) {
    for (final variant in OnboardingVariant.values) {
      if (variant.remoteValue == value) {
        return variant;
      }
    }
    // `RemoteConfigDefaults.onboardingVariant` keeps the default in sync.
    return OnboardingVariant.values.firstWhere(
      (v) => v.remoteValue == RemoteConfigDefaults.onboardingVariant,
      orElse: () => OnboardingVariant.orbit,
    );
  }
}
