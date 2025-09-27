import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:devhub_gpt/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:devhub_gpt/shared/config/remote_config/application/remote_config_controller.dart';
import 'package:devhub_gpt/shared/widgets/app_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    final onboardingAsync = ref.watch(onboardingCompletedProvider);
    final featureFlags = ref.watch(remoteConfigFeatureFlagsProvider);

    final bool isLoggedIn = authAsync.maybeWhen(
      data: (user) => user != null,
      orElse: () => false,
    );
    final bool onboardingReady = onboardingAsync.maybeWhen(
      data: (_) => true,
      error: (_, __) => true,
      orElse: () => false,
    );
    final bool shouldShowOnboarding = !isLoggedIn &&
        onboardingAsync.maybeWhen(
          data: (value) => !value,
          error: (_, __) => false,
          orElse: () => false,
        ) &&
        featureFlags != null;

    if (shouldShowOnboarding && onboardingReady) {
      return const OnboardingPage();
    }

    return const Scaffold(body: Center(child: AppProgressIndicator()));
  }
}
