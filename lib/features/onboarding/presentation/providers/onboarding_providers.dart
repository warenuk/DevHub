import 'package:devhub_gpt/core/theme/app_palette.dart';
import 'package:devhub_gpt/features/onboarding/data/onboarding_preferences.dart';
import 'package:devhub_gpt/features/onboarding/domain/entities/onboarding_variant.dart';
import 'package:devhub_gpt/shared/config/remote_config/application/remote_config_controller.dart';
import 'package:devhub_gpt/shared/config/remote_config/remote_config_defaults.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingPreferencesProvider = Provider<OnboardingPreferences>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return OnboardingPreferences(storage);
});

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = ref.watch(onboardingPreferencesProvider);
  try {
    return await prefs.isCompleted();
  } catch (_) {
    // У разі помилки зчитування не блокуємо користувача на онбордингу.
    return true;
  }
});

final onboardingVariantProvider = Provider<OnboardingVariant>((ref) {
  final flags = ref.watch(remoteConfigFeatureFlagsProvider);
  final value =
      flags?.onboardingVariant ?? RemoteConfigDefaults.onboardingVariant;
  return OnboardingVariant.fromRemoteValue(value);
});

/// Provides accent colors that align each onboarding variant with the app palette.
final onboardingVariantAccentProvider = Provider<Color>((ref) {
  final variant = ref.watch(onboardingVariantProvider);
  switch (variant) {
    case OnboardingVariant.orbit:
      return AppPalette.accent;
    case OnboardingVariant.blueprint:
      return const Color(0xFF5DE0FF);
    case OnboardingVariant.pulse:
      return const Color(0xFFFFA85D);
  }
});
