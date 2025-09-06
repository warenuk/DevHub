import 'package:devhub_gpt/features/github/presentation/pages/repositories_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RepositoriesPage shows title and search field', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: RepositoriesPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('My Repositories'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });
}

