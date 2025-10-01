import 'package:devhub_gpt/core/db/app_database.dart';
import 'package:devhub_gpt/features/notes/data/datasources/local/notes_sync_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late NotesSyncDao dao;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = NotesSyncDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('upsert replaces previous mutation for same note', () async {
    final first = NoteMutationEntry.upsert(
      noteId: 'note-1',
      payload: '{"id":"note-1","title":"A"}',
      enqueuedAt: DateTime.utc(2024, 1, 1),
    );
    await dao.upsert(first);

    final second = NoteMutationEntry.upsert(
      noteId: 'note-1',
      payload: '{"id":"note-1","title":"B"}',
      enqueuedAt: DateTime.utc(2024, 1, 2),
    );
    await dao.upsert(second);

    final pending = await dao.pending();
    expect(pending.length, 1);
    expect(pending.single.id, 'upsert-note-1');
    expect(pending.single.payload, contains('"title":"B"'));
    expect(pending.single.enqueuedAt.isAfter(first.enqueuedAt), isTrue);
  });

  test('delete operations are stored and removable by helper', () async {
    final deleteEntry = NoteMutationEntry.delete(
      noteId: 'note-2',
      enqueuedAt: DateTime.utc(2024, 2, 10),
    );
    await dao.upsert(deleteEntry);

    expect((await dao.pending()).single.type, NoteMutationType.delete);

    await dao.removeDeleteFor('note-2');
    expect(await dao.pending(), isEmpty);
  });

  test('clear removes all pending mutations', () async {
    await dao.upsert(
      NoteMutationEntry.upsert(
        noteId: 'note-1',
        payload: '{"id":"note-1"}',
      ),
    );
    await dao.upsert(
      NoteMutationEntry.delete(
        noteId: 'note-2',
      ),
    );

    expect((await dao.pending()).length, 2);
    await dao.clear();
    expect(await dao.pending(), isEmpty);
  });
}
