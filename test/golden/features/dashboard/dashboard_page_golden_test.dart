import 'dart:io';

import 'package:devhub_gpt/features/auth/domain/entities/user.dart' as auth;
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:devhub_gpt/features/dashboard/presentation/providers/commit_chart_providers.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';
import 'package:devhub_gpt/features/notes/presentation/providers/notes_providers.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/sha256_golden_comparator.dart';

class _FakeNotesRepository implements NotesRepository {
  _FakeNotesRepository(this._notes);

  final List<Note> _notes;

  @override
  Future<Note> createNote({required String title, required String content}) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteNote(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Note>> listNotes() async => _notes;

  @override
  Future<Note> updateNote(Note note) {
    throw UnimplementedError();
  }
}

final Uri _baseUri = Directory('test/golden/features/dashboard/').uri;

void main() {
  final user = auth.User(
    id: 'u1',
    email: 'jane@devhub.test',
    name: 'Jane Dev',
    avatarUrl: 'https://example.com/avatar.png',
    createdAt: DateTime(2024, 1, 1),
    isEmailVerified: true,
  );

  final notes = [
    Note(
      id: 'n1',
      title: 'Sprint planning',
      content: 'Outline roadmap',
      createdAt: DateTime(2024, 4, 1, 9),
      updatedAt: DateTime(2024, 4, 2, 10),
    ),
    Note(
      id: 'n2',
      title: 'Release retro',
      content: 'Celebrate!',
      createdAt: DateTime(2024, 3, 10, 12),
      updatedAt: DateTime(2024, 3, 12, 12),
    ),
  ];

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

  final commits = [
    CommitInfo(
      id: 'c1',
      message: 'feat: add offline cache',
      author: 'Jane Dev',
      date: DateTime(2024, 5, 12, 10),
    ),
    CommitInfo(
      id: 'c2',
      message: 'fix: login retry flow',
      author: 'John Dev',
      date: DateTime(2024, 5, 11, 14),
    ),
  ];

  final chartPoints = [
    ChartPoint(DateTime(2024, 5, 6), 1, const ['feat: offline cache']),
    ChartPoint(DateTime(2024, 5, 7), 0, const []),
    ChartPoint(DateTime(2024, 5, 8), 2, const ['fix: login retry', 'chore: ci']),
    ChartPoint(DateTime(2024, 5, 9), 0, const []),
    ChartPoint(DateTime(2024, 5, 10), 1, const ['refactor: notes']),
    ChartPoint(DateTime(2024, 5, 11), 0, const []),
    ChartPoint(DateTime(2024, 5, 12), 3, const ['feat: offline cache', 'docs', 'ci']),
  ];

  testWidgets('DashboardPage golden - desktop layout', (tester) async {
    final previousComparator = goldenFileComparator;
    goldenFileComparator = Sha256GoldenComparator(_baseUri);
    addTearDown(() => goldenFileComparator = previousComparator);

    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const rootKey = ValueKey('dashboard-golden-root');

    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(user)),
            currentUserProvider.overrideWith((ref) async => user),
            notesRepositoryProvider.overrideWithValue(_FakeNotesRepository(notes)),
            reposCacheProvider.overrideWith((ref) => Stream.value(repos)),
            recentCommitsCacheProvider.overrideWith((ref) => Stream.value(commits)),
            commitChartDataProvider.overrideWithValue(AsyncValue.data(chartPoints)),
            chartPeriodProvider.overrideWith((ref) => ChartPeriod.days7),
            githubTokenProvider.overrideWith((ref) async => 'token'),
            currentGithubUserProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(rootKey),
      matchesGoldenFile('goldens/dashboard_page_desktop.sha256'),
    );
  });
}
