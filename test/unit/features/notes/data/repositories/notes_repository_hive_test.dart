import 'package:devhub_gpt/features/notes/data/datasources/local/hive_notes_local_data_source.dart';
import 'package:devhub_gpt/features/notes/data/repositories/notes_repository_hive.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('hive_notes_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    if (Hive.isBoxOpen('notes_box_test')) {
      final box = Hive.box<String>('notes_box_test');
      await box.clear();
      await box.close();
    }
  });

  tearDownAll(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('HiveNotesRepository CRUD and sorting', () async {
    final box = await Hive.openBox<String>('notes_box_test');
    final repo = HiveNotesRepository(HiveNotesLocalDataSource(box));

    // Initially empty
    expect(await repo.listNotes(), isEmpty);

    // Create
    final a = await repo.createNote(title: 'A', content: 'a');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final b = await repo.createNote(title: 'B', content: 'b');

    // List
    final list1 = await repo.listNotes();
    expect(list1.length, 2);

    // Update (should bump updatedAt and place first)
    final updatedA = await repo.updateNote(a.copyWith(title: 'A1'));
    expect(updatedA.title, 'A1');

    final list2 = await repo.listNotes();
    expect(list2.first.id, updatedA.id);

    // Delete
    await repo.deleteNote(b.id);
    final list3 = await repo.listNotes();
    expect(list3.length, 1);
    expect(list3.first.id, updatedA.id);
  });
}
