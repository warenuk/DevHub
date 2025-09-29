import 'package:devhub_gpt/features/commits/presentation/pages/commits_page.dart';
import 'package:devhub_gpt/shared/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/pump_until_stable.dart';

void main() {
  testWidgets('CommitsPage renders list', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: CommitsPage()),
      ),
    );
    await pumpUntilStable(tester);
    expect(find.text('Recent Commits'), findsOneWidget);
  });
}
