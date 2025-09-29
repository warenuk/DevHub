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
  testWidgets('DevHub renders login when onboarding is completed', (
    WidgetTester tester,
  ) async {
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

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
