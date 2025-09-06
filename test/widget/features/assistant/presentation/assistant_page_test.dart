import 'package:devhub_gpt/features/assistant/presentation/pages/assistant_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AssistantPage renders input and send button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AssistantPage()),
      ),
    );
    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Send'), findsOneWidget);
  });
}
