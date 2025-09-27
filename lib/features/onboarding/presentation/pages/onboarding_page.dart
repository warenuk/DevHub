import 'package:devhub_gpt/core/router/app_routes.dart';
import 'package:devhub_gpt/features/onboarding/domain/entities/onboarding_variant.dart';
import 'package:devhub_gpt/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:devhub_gpt/features/onboarding/presentation/variants/blueprint_onboarding_flow.dart';
import 'package:devhub_gpt/features/onboarding/presentation/variants/orbit_onboarding_flow.dart';
import 'package:devhub_gpt/features/onboarding/presentation/variants/pulse_onboarding_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  Future<void> _complete(BuildContext context, WidgetRef ref) async {
    final prefs = ref.read(onboardingPreferencesProvider);
    await prefs.markCompleted();
    ref.invalidate(onboardingCompletedProvider);
    const LoginRoute().go(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = ref.watch(onboardingVariantProvider);
    final accent = ref.watch(onboardingVariantAccentProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _buildFlow(variant, accent, context, ref),
    );
  }

  Widget _buildFlow(
    OnboardingVariant variant,
    Color accent,
    BuildContext context,
    WidgetRef ref,
  ) {
    final complete = () => _complete(context, ref);
    switch (variant) {
      case OnboardingVariant.orbit:
        return OrbitOnboardingFlow(
          key: const ValueKey('onboarding-orbit'),
          accent: accent,
          onComplete: complete,
        );
      case OnboardingVariant.blueprint:
        return BlueprintOnboardingFlow(
          key: const ValueKey('onboarding-blueprint'),
          accent: accent,
          onComplete: complete,
        );
      case OnboardingVariant.pulse:
        return PulseOnboardingFlow(
          key: const ValueKey('onboarding-pulse'),
          accent: accent,
          onComplete: complete,
        );
    }
  }
}
