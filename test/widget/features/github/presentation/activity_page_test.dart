import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/presentation/pages/activity_page.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ActivityPage shows list', (tester) async {
    final events = [
      ActivityEvent(
        id: '1',
        type: 'PushEvent',
        repoFullName: 'u/r',
        createdAt: DateTime(2024, 1, 1, 10),
        summary: 'Pushed 1 commits',
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activityProvider.overrideWithProvider(
            FutureProvider.autoDispose.family((ref, _) async => events),
          ),
        ],
        child: const MaterialApp(home: ActivityPage(owner: 'u', repo: 'r')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Activity: u/r'), findsOneWidget);
    expect(find.text('PushEvent'), findsOneWidget);
  });
}
