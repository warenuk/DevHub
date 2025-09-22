import 'dart:io';

import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:devhub_gpt/features/github/presentation/pages/repositories_page.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/sha256_golden_comparator.dart';

final Uri _baseUri = Directory('test/golden/features/github/').uri;

void main() {
  final repos = [
    const Repo(
      id: 1,
      name: 'devhub',
      fullName: 'acme/devhub',
      language: 'Dart',
      stargazersCount: 420,
      forksCount: 28,
      description: 'Flutter dashboard',
    ),
    const Repo(
      id: 2,
      name: 'devhub-api',
      fullName: 'acme/devhub-api',
      language: 'TypeScript',
      stargazersCount: 210,
      forksCount: 12,
      description: 'Backend services',
    ),
  ];

  testWidgets('RepositoriesPage golden - filtered list', (tester) async {
    final previousComparator = goldenFileComparator;
    goldenFileComparator = Sha256GoldenComparator(_baseUri);
    addTearDown(() => goldenFileComparator = previousComparator);

    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const rootKey = ValueKey('repositories-golden-root');

    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: ProviderScope(
          overrides: [
            reposCacheProvider.overrideWith((ref) => Stream.value(repos)),
            githubTokenProvider.overrideWith((ref) async => 'token'),
            repoQueryProvider.overrideWith((ref) => 'dev'),
            currentGithubUserProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(home: RepositoriesPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(rootKey),
      matchesGoldenFile('goldens/repositories_page_desktop.sha256'),
    );
  });
}
