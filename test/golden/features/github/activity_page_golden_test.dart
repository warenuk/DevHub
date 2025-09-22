import 'dart:io';

import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/presentation/pages/activity_page.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/sha256_golden_comparator.dart';

final Uri _baseUri = Directory('test/golden/features/github/').uri;

void main() {
  final events = [
    ActivityEvent(
      id: '1',
      type: 'PushEvent',
      repoFullName: 'acme/devhub',
      createdAt: DateTime(2024, 5, 12, 9, 30),
      summary: 'Pushed 2 commits to main',
    ),
    ActivityEvent(
      id: '2',
      type: 'PullRequestEvent',
      repoFullName: 'acme/devhub',
      createdAt: DateTime(2024, 5, 11, 15, 12),
      summary: 'Merged PR #42',
    ),
  ];

  testWidgets('ActivityPage golden - with events', (tester) async {
    final previousComparator = goldenFileComparator;
    goldenFileComparator = Sha256GoldenComparator(_baseUri);
    addTearDown(() => goldenFileComparator = previousComparator);

    tester.view.physicalSize = const Size(1024, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const rootKey = ValueKey('activity-golden-root');

    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: ProviderScope(
          overrides: [
            githubTokenProvider.overrideWith((ref) async => 'token'),
            activityProvider.overrideWith(
              (ref, params) => Future.value(events),
            ),
          ],
          child: const MaterialApp(
            home: ActivityPage(owner: 'acme', repo: 'devhub'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(rootKey),
      matchesGoldenFile('goldens/activity_page_desktop.sha256'),
    );
  });
}
