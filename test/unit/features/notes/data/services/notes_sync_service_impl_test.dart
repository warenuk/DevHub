import 'dart:async';

import 'package:devhub_gpt/core/db/app_database.dart';
import 'package:devhub_gpt/features/notes/data/datasources/local/notes_sync_dao.dart';
import 'package:devhub_gpt/features/notes/data/datasources/remote/dto/remote_note_dto.dart';
import 'package:devhub_gpt/features/notes/data/datasources/remote/notes_remote_data_source.dart';
import 'package:devhub_gpt/features/notes/data/repositories/notes_repository_drift.dart';
import 'package:devhub_gpt/features/notes/data/services/notes_sync_service_impl.dart';
import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNotesRemoteDataSource implements NotesRemoteDataSource {
  FakeNotesRemoteDataSource();

  final StreamController<NotesRealtimeEvent> _controller =
      StreamController<NotesRealtimeEvent>.broadcast();
  final List<RemoteNoteDto> upserts = <RemoteNoteDto>[];
  final List<String> deletes = <String>[];
  final List<RemoteNoteDto> store = <RemoteNoteDto>[];

  bool failFetch = false;
  bool failUpsert = false;
  bool failDelete = false;

  @override
  Future<List<RemoteNoteDto>> fetchNotes({DateTime? updatedSince}) async {
    if (failFetch) {
      throw Exception('fetch failed');
    }
    if (updatedSince == null) {
      return List<RemoteNoteDto>.from(store);
    }
    return store
        .where((note) => note.updatedAt.isAfter(updatedSince))
        .toList(growable: false);
  }

  @override
  Future<RemoteNoteDto> upsert(RemoteNoteDto note) async {
    if (failUpsert) {
      throw Exception('upsert offline');
    }
    store.removeWhere((n) => n.id == note.id);
    store.add(note);
    upserts.add(note);
    return note;
  }

  @override
  Future<void> delete(String id) async {
    if (failDelete) {
      throw Exception('delete offline');
    }
    store.removeWhere((n) => n.id == id);
    deletes.add(id);
  }

  @override
  Stream<NotesRealtimeEvent> subscribe({DateTime? updatedSince}) {
    return _controller.stream;
  }

  void emit(NotesRealtimeEvent event) {
    _controller.add(event);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

RemoteNoteDto buildRemoteNote(String id, {DateTime? updatedAt}) {
  final now = updatedAt ?? DateTime.now().toUtc();
  return RemoteNoteDto(
    id: id,
    title: 'Remote $id',
    content: 'Content $id',
    createdAt: now.subtract(const Duration(minutes: 1)),
    updatedAt: now,
  );
}

void main() {
  late AppDatabase db;
  late NotesRepositoryDrift repo;
  late NotesSyncDao dao;
  late FakeNotesRemoteDataSource remote;
  late NotesSyncServiceImpl service;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = NotesRepositoryDrift(db);
    dao = NotesSyncDao(db);
    remote = FakeNotesRemoteDataSource();
    service = NotesSyncServiceImpl(
      localRepository: repo,
      remoteDataSource: remote,
      queueDao: dao,
      retryInterval: const Duration(milliseconds: 200),
    );
  });

  tearDown(() async {
    await service.dispose();
    await remote.dispose();
    await db.close();
  });

  test('ensureStarted merges remote notes into local cache', () async {
    final remoteNote = buildRemoteNote('remote-1');
    remote.store.add(remoteNote);

    await service.ensureStarted();
    await pumpEventQueue();

    final list = await repo.listNotes();
    expect(list.single.id, remoteNote.id);
    expect(list.single.title, remoteNote.title);
  });

  test('scheduleUpsert sends immediately when remote is online', () async {
    await service.ensureStarted();
    final created = await repo.createNote(title: 'Local', content: 'test');

    await service.scheduleUpsert(created);
    expect(await dao.pending(), isEmpty);
    expect(remote.upserts.single.id, created.id);
  });

  test('scheduleUpsert queues when remote is offline and flushes later',
      () async {
    await service.ensureStarted();
    final created = await repo.createNote(title: 'Offline', content: 'A');

    remote.failUpsert = true;
    await service.scheduleUpsert(created);
    var pending = await dao.pending();
    expect(pending.length, 1);

    remote.failUpsert = false;
    await service.flushPending();
    pending = await dao.pending();
    expect(pending, isEmpty);
    expect(remote.store.any((note) => note.id == created.id), isTrue);
  });

  test('scheduleDelete queues and retries on next flush when offline',
      () async {
    await service.ensureStarted();
    final created = await repo.createNote(title: 'Temp', content: 'tmp');
    await service.scheduleUpsert(created);
    expect(remote.store.any((n) => n.id == created.id), isTrue);

    remote.failDelete = true;
    await service.scheduleDelete(created.id);
    expect((await dao.pending()).single.type, NoteMutationType.delete);

    remote.failDelete = false;
    await service.flushPending();
    expect(await dao.pending(), isEmpty);
    expect(remote.store.any((n) => n.id == created.id), isFalse);
  });

  test('realtime upsert event updates local cache', () async {
    await service.ensureStarted();
    final dto = buildRemoteNote('upsert-remote',
        updatedAt: DateTime.now().toUtc().add(const Duration(minutes: 1)));

    remote.emit(NoteUpsertedEvent(dto));
    await pumpEventQueue();

    final list = await repo.listNotes();
    expect(list.single.id, dto.id);
  });

  test('realtime delete event removes note locally', () async {
    await service.ensureStarted();
    final note = await repo.createNote(title: 'ToRemove', content: 'x');

    remote.emit(NoteDeletedEvent(noteId: note.id));
    await pumpEventQueue();

    final list = await repo.listNotes();
    expect(list, isEmpty);
  });
}
