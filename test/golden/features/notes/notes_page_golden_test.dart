import 'dart:io';

import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';
import 'package:devhub_gpt/features/notes/presentation/pages/notes_page.dart';
import 'package:devhub_gpt/features/notes/presentation/providers/notes_providers.dart';
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

final Uri _baseUri = Directory('test/golden/features/notes/').uri;

void main() {
  final notes = [
    Note(
      id: 'n1',
      title: 'Release checklist',
      content: '1. Update changelog\n2. Tag release',
      createdAt: DateTime(2024, 5, 1, 8),
      updatedAt: DateTime(2024, 5, 2, 9),
    ),
    Note(
      id: 'n2',
      title: 'Post-mortem',
      content: 'Summary of outage mitigation steps.',
      createdAt: DateTime(2024, 4, 12, 10),
      updatedAt: DateTime(2024, 4, 13, 14),
    ),
  ];

  testWidgets('NotesPage golden - list view', (tester) async {
    final previousComparator = goldenFileComparator;
    goldenFileComparator = Sha256GoldenComparator(_baseUri);
    addTearDown(() => goldenFileComparator = previousComparator);

    tester.view.physicalSize = const Size(1024, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const rootKey = ValueKey('notes-golden-root');

    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: ProviderScope(
          overrides: [
            notesRepositoryProvider.overrideWithValue(_FakeNotesRepository(notes)),
          ],
          child: const MaterialApp(home: NotesPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(rootKey),
      matchesGoldenFile('goldens/notes_page_desktop.sha256'),
    );
  });
}
