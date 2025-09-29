import 'dart:async';

import 'package:devhub_gpt/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:devhub_gpt/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:devhub_gpt/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart' as domain;
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:devhub_gpt/main.dart';
import 'package:devhub_gpt/shared/config/remote_config/application/remote_config_controller.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_feature_flags.dart';
import 'package:devhub_gpt/shared/providers/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  domain.User makeUser() => domain.User(
    id: 'u1',
    email: 'test@example.com',
    name: 'Test User',
    createdAt: DateTime(2024, 1, 1),
    isEmailVerified: true,
  );

  testWidgets('Authenticated user redirects to /dashboard', (tester) async {
    final user = makeUser();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) {
            final local = MemoryAuthLocalDataSource();
            final remote = MockAuthRemoteDataSource();
            return AuthRepositoryImpl(remote: remote, local: local);
          }),
          authStateProvider.overrideWith(
            (ref) => Stream<domain.User?>.value(user),
          ),
          currentUserProvider.overrideWith((ref) async => user),
          onboardingCompletedProvider.overrideWith((ref) async => true),
          remoteConfigFeatureFlagsProvider.overrideWithValue(
            const RemoteConfigFeatureFlags(
              welcomeBannerEnabled: true,
              markdownMaxLines: 6,
              supportedLocales: ['en'],
              forcedThemeMode: null,
              welcomeMessage: '',
              onboardingVariant: 1,
            ),
          ),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const DevHubApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.scrollUntilVisible(find.text('Block 3 shortcuts'), 200);

    // Dashboard content should be present
    expect(find.text('Block 3 shortcuts'), findsOneWidget);
    expect(find.text('Commit Activity'), findsOneWidget);
  });

  testWidgets('Unauthenticated user redirects to /auth/login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) {
            final local = MemoryAuthLocalDataSource();
            final remote = MockAuthRemoteDataSource();
            return AuthRepositoryImpl(remote: remote, local: local);
          }),
          authStateProvider.overrideWith(
            (ref) => Stream<domain.User?>.value(null),
          ),
          currentUserProvider.overrideWith((ref) async => null),
          onboardingCompletedProvider.overrideWith((ref) async => true),
          remoteConfigFeatureFlagsProvider.overrideWithValue(
            const RemoteConfigFeatureFlags(
              welcomeBannerEnabled: true,
              markdownMaxLines: 6,
              supportedLocales: ['en'],
              forcedThemeMode: null,
              welcomeMessage: '',
              onboardingVariant: 1,
            ),
          ),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const DevHubApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Login screen should be visible
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
