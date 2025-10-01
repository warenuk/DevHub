import 'dart:async';

import 'package:devhub_gpt/features/notes/data/datasources/local/notes_sync_dao.dart';
import 'package:devhub_gpt/features/notes/data/datasources/remote/notes_remote_data_source.dart';
import 'package:devhub_gpt/features/notes/data/repositories/notes_repository_drift.dart';
import 'package:devhub_gpt/features/notes/data/services/notes_sync_service_impl.dart';
import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';
import 'package:devhub_gpt/features/notes/domain/services/notes_sync_service.dart';
import 'package:devhub_gpt/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:devhub_gpt/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:devhub_gpt/features/notes/domain/usecases/list_notes_usecase.dart';
import 'package:devhub_gpt/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:devhub_gpt/features/notes/domain/usecases/watch_notes_usecase.dart';
import 'package:devhub_gpt/shared/providers/database_provider.dart';
import 'package:devhub_gpt/shared/providers/dio_provider.dart';
import 'package:devhub_gpt/shared/utils/test_environment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
// Hive removed in favor of Drift-backed storage

final notesRepositoryDriftProvider = Provider<NotesRepositoryDrift>((ref) {
  final db = ref.watch(databaseProvider);
  return NotesRepositoryDrift(db);
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return ref.watch(notesRepositoryDriftProvider);
});

final notesRemoteDataSourceProvider = Provider<NotesRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return HttpNotesRemoteDataSource(dio: dio);
});

final notesSyncDaoProvider = Provider<NotesSyncDao>((ref) {
  final db = ref.watch(databaseProvider);
  return NotesSyncDao(db);
});

final notesSyncServiceProvider = Provider<NotesSyncService>((ref) {
  final local = ref.watch(notesRepositoryDriftProvider);
  final remote = ref.watch(notesRemoteDataSourceProvider);
  final queue = ref.watch(notesSyncDaoProvider);
  if (isRunningInFlutterTest()) {
    return _NotesSyncServiceStub();
  }
  final service = NotesSyncServiceImpl(
    localRepository: local,
    remoteDataSource: remote,
    queueDao: queue,
  );
  Future.microtask(service.ensureStarted);
  ref.onDispose(() async {
    await service.dispose();
  });
  return service;
});

class NotesController extends StateNotifier<AsyncValue<List<Note>>>
    with _NoteActions {
  NotesController(this._repo, this._syncService)
      : _testMode = isRunningInFlutterTest(),
        super(const AsyncValue.loading()) {
    _initialize();
  }

  final NotesRepository _repo;
  final NotesSyncService _syncService;
  final bool _testMode;
  StreamSubscription<List<Note>>? _subscription;

  Future<void> _initialize() async {
    await _refresh();
    if (_testMode) {
      return;
    }
    _subscription = WatchNotesUseCase(_repo).call().listen(
          (notes) => state = AsyncValue.data(notes),
          onError: (error, stackTrace) =>
              state = AsyncValue.error(error, stackTrace),
        );
    unawaited(_syncService.ensureStarted());
  }

  Future<void> _refresh() async {
    state = const AsyncValue.loading();
    try {
      final list = await ListNotesUseCase(_repo).call();
      state = AsyncValue.data(list);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Future<void> add(String title, String content) async {
    try {
      final note = await CreateNoteUseCase(_repo).call(
        title: title,
        content: content,
      );
      await _syncService.scheduleUpsert(note);
      if (_testMode) {
        await _refresh();
      }
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  @override
  Future<void> update(Note note) async {
    try {
      final updated = await UpdateNoteUseCase(_repo).call(note);
      await _syncService.scheduleUpsert(updated);
      if (_testMode) {
        await _refresh();
      }
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  @override
  Future<void> remove(String id) async {
    try {
      final deletedAt = DateTime.now();
      await DeleteNoteUseCase(_repo).call(id);
      await _syncService.scheduleDelete(id, deletedAt: deletedAt);
      if (_testMode) {
        await _refresh();
      }
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

mixin _NoteActions {
  Future<void> add(String title, String content);
  Future<void> update(Note note);
  Future<void> remove(String id);
}

final notesControllerProvider =
    StateNotifierProvider<NotesController, AsyncValue<List<Note>>>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  final sync = ref.watch(notesSyncServiceProvider);
  return NotesController(repo, sync);
});

class _NotesSyncServiceStub implements NotesSyncService {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> ensureStarted() async {}

  @override
  Future<void> flushPending() async {}

  @override
  Future<void> scheduleDelete(String noteId, {DateTime? deletedAt}) async {}

  @override
  Future<void> scheduleUpsert(Note note) async {}
}
