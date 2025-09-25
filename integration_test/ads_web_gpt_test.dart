// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:devhub_gpt/features/settings/presentation/pages/settings_page.dart';
import 'package:devhub_gpt/shared/ads/ads_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders GPT demo slot when ADS_MODE=web_gpt', (tester) async {
    if (!kIsWeb) {
      return;
    }
    final config = AdsConfig.fromEnvironment();
    if (config.mode != AdsMode.webGpt) {
      return;
    }

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: SettingsPage())),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final slotElement = html.document.getElementById(config.slotId);
    expect(slotElement, isNotNull, reason: 'GPT slot element should exist');
    final rect = slotElement!.getBoundingClientRect();
    expect(
      rect.width,
      moreOrLessEquals(config.slotSize.width.toDouble(), epsilon: 1),
    );
    expect(
      rect.height,
      moreOrLessEquals(config.slotSize.height.toDouble(), epsilon: 1),
    );
    expect(slotElement.parent?.id, '${config.slotId}-container');

    expect(find.text('Ad slot disabled'), findsNothing);
  });

  testWidgets('keeps ad slot disabled placeholder when ADS_MODE=off', (
    tester,
  ) async {
    if (!kIsWeb) {
      return;
    }
    final config = AdsConfig.fromEnvironment();
    if (config.mode == AdsMode.webGpt) {
      return;
    }

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: SettingsPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ad slot disabled'), findsOneWidget);
    final slotElement = html.document.getElementById(config.slotId);
    expect(slotElement, isNotNull);
    expect(slotElement!.parent?.id, anyOf(isNull, 'devhub-gpt-host'));
  });
}
