import 'package:devhub_gpt/shared/config/remote_config/application/remote_config_controller.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_feature_flags.dart';
import 'package:devhub_gpt/shared/config/remote_config/presentation/widgets/remote_config_welcome_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  RemoteConfigFeatureFlags _flags({
    bool enabled = true,
    String message = 'Remote updates are live! 🎉',
    int maxLines = 4,
    List<String> locales = const <String>['en'],
  }) {
    return RemoteConfigFeatureFlags(
      welcomeBannerEnabled: enabled,
      markdownMaxLines: maxLines,
      supportedLocales: locales,
      forcedThemeMode: null,
      welcomeMessage: message,
    );
  }

  Future<void> _pumpBanner(
    WidgetTester tester, {
    RemoteConfigFeatureFlags? flags,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          remoteConfigFeatureFlagsProvider.overrideWithValue(flags),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: RemoteConfigWelcomeBanner(),
          ),
        ),
      ),
    );
  }

  testWidgets('does not render when flags are null', (tester) async {
    await _pumpBanner(tester, flags: null);

    expect(find.byType(RemoteConfigWelcomeBanner), findsOneWidget);
    expect(find.byIcon(Icons.campaign_outlined), findsNothing);
  });

  testWidgets('does not render when banner is disabled', (tester) async {
    await _pumpBanner(tester, flags: _flags(enabled: false));

    expect(find.byIcon(Icons.campaign_outlined), findsNothing);
  });

  testWidgets('renders message when enabled', (tester) async {
    const String message = 'Welcome to DevHub!';
    await _pumpBanner(tester, flags: _flags(message: message));

    expect(find.byIcon(Icons.campaign_outlined), findsOneWidget);
    expect(find.text('Remote config update'), findsOneWidget);
    expect(find.text(message), findsOneWidget);
  });

  testWidgets('respects max lines from remote config', (tester) async {
    await _pumpBanner(
      tester,
      flags: _flags(message: 'line1\nline2\nline3', maxLines: 2),
    );

    final Text messageText =
        tester.widget<Text>(find.text('line1\nline2\nline3'));
    expect(messageText.maxLines, equals(2));
  });
}
