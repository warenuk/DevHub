import 'package:devhub_gpt/features/assistant/presentation/pages/assistant_page.dart';
import 'package:devhub_gpt/shared/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AssistantPage renders input and send button', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: AssistantPage()),
      ),
    );
    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Send'), findsOneWidget);
  });
}
