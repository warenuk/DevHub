import 'package:devhub_gpt/features/commits/presentation/pages/commits_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CommitsPage renders list', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CommitsPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Recent Commits'), findsOneWidget);
  });
}
