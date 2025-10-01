import 'dart:async';
import 'dart:convert';

import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/features/notes/data/datasources/local/notes_sync_dao.dart';
import 'package:devhub_gpt/features/notes/data/datasources/remote/dto/remote_note_dto.dart';
import 'package:devhub_gpt/features/notes/data/datasources/remote/notes_remote_data_source.dart';
import 'package:devhub_gpt/features/notes/data/repositories/notes_repository_drift.dart';
import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/services/notes_sync_service.dart';

class NotesSyncServiceImpl implements NotesSyncService {
  NotesSyncServiceImpl({
    required NotesRepositoryDrift localRepository,
    required NotesRemoteDataSource remoteDataSource,
    required NotesSyncDao queueDao,
    Duration retryInterval = const Duration(seconds: 20),
  })  : _local = localRepository,
        _remote = remoteDataSource,
        _queue = queueDao,
        _retryInterval = retryInterval;

  final NotesRepositoryDrift _local;
  final NotesRemoteDataSource _remote;
  final NotesSyncDao _queue;
  final Duration _retryInterval;

  bool _started = false;
  StreamSubscription<NotesRealtimeEvent>? _realtimeSubscription;
  Timer? _retryTimer;
  DateTime? _lastSyncedAt;

  @override
  Future<void> ensureStarted() async {
    if (_started) return;
    _started = true;
    await _initialSync();
    _listenRealtime();
    _scheduleRetry();
  }

  Future<void> _initialSync() async {
    try {
      final existing = await _local.listAll();
      if (existing.isNotEmpty) {
        _lastSyncedAt = existing.first.updatedAt;
      }
      final remoteNotes = await _remote.fetchNotes(updatedSince: _lastSyncedAt);
      if (remoteNotes.isNotEmpty) {
        await _local.mergeIncoming(
          remoteNotes.map((e) => e.toIncoming()).toList(),
        );
        _lastSyncedAt = _maxUpdatedAt(remoteNotes);
      }
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Initial notes sync failed: $error',
        area: 'notes_sync',
      );
      AppLogger.error(
        'Initial notes sync trace',
        error: error,
        stackTrace: stackTrace,
        area: 'notes_sync',
      );
    }
    await flushPending();
  }

  DateTime? _maxUpdatedAt(Iterable<RemoteNoteDto> notes) {
    DateTime? max;
    for (final dto in notes) {
      if (max == null || dto.updatedAt.isAfter(max)) {
        max = dto.updatedAt;
      }
    }
    return max ?? _lastSyncedAt;
  }

  void _listenRealtime() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _remote
        .subscribe(updatedSince: _lastSyncedAt)
        .listen(_handleRealtimeEvent, onError: (error, stackTrace) {
      AppLogger.warning(
        'Realtime notes stream error: $error',
        area: 'notes_sync',
      );
      AppLogger.error(
        'Realtime error trace',
        error: error,
        stackTrace: stackTrace,
        area: 'notes_sync',
      );
      _restartRealtime();
    }, onDone: _restartRealtime);
  }

  void _restartRealtime() {
    if (!_started) return;
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (_started) {
        _listenRealtime();
      }
    });
  }

  Future<void> _handleRealtimeEvent(NotesRealtimeEvent event) async {
    switch (event) {
      case NoteUpsertedEvent(:final note):
        await _local.mergeIncoming([note.toIncoming()]);
        _lastSyncedAt =
            _lastSyncedAt == null || note.updatedAt.isAfter(_lastSyncedAt!)
                ? note.updatedAt
                : _lastSyncedAt;
        await _queue.removeUpsertFor(note.id);
        await _queue.removeDeleteFor(note.id);
      case NoteDeletedEvent(:final noteId):
        await _local.deleteNote(noteId);
        await _queue.removeUpsertFor(noteId);
        await _queue.removeDeleteFor(noteId);
    }
  }

  @override
  Future<void> flushPending() async {
    final pending = await _queue.pending();
    for (final entry in pending) {
      final success = await _sendMutation(entry);
      if (!success) {
        _scheduleRetry();
        break;
      }
    }
  }

  Future<bool> _sendMutation(NoteMutationEntry entry) async {
    try {
      switch (entry.type) {
        case NoteMutationType.upsert:
          final payload = entry.payload;
          if (payload == null) {
            await _queue.removeById(entry.id);
            return true;
          }
          final dto = RemoteNoteDto.fromJson(
            jsonDecode(payload) as Map<String, dynamic>,
          );
          final remoteNote = await _remote.upsert(dto);
          await _queue.removeById(entry.id);
          await _local.mergeIncoming([remoteNote.toIncoming()]);
          _lastSyncedAt = _lastSyncedAt == null ||
                  remoteNote.updatedAt.isAfter(_lastSyncedAt!)
              ? remoteNote.updatedAt
              : _lastSyncedAt;
        case NoteMutationType.delete:
          await _remote.delete(entry.noteId);
          await _queue.removeById(entry.id);
          await _local.deleteNote(entry.noteId);
      }
      return true;
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to push note mutation ${entry.id}: $error',
        area: 'notes_sync',
      );
      AppLogger.error(
        'Mutation push trace',
        error: error,
        stackTrace: stackTrace,
        area: 'notes_sync',
      );
      return false;
    }
  }

  void _scheduleRetry() {
    _retryTimer ??= Timer.periodic(_retryInterval, (_) => flushPending());
  }

  @override
  Future<void> scheduleUpsert(Note note) async {
    final dto = RemoteNoteDto.fromDomain(note);
    final entry = NoteMutationEntry.upsert(
      noteId: note.id,
      payload: jsonEncode(dto.toJson()),
    );
    await _queue.upsert(entry);
    final success = await _sendMutation(entry);
    if (!success) {
      _scheduleRetry();
    }
  }

  @override
  Future<void> scheduleDelete(String noteId, {DateTime? deletedAt}) async {
    await _queue.removeUpsertFor(noteId);
    final entry = NoteMutationEntry.delete(
      noteId: noteId,
      enqueuedAt: deletedAt,
    );
    await _queue.upsert(entry);
    final success = await _sendMutation(entry);
    if (!success) {
      _scheduleRetry();
    }
  }

  @override
  Future<void> dispose() async {
    _started = false;
    _retryTimer?.cancel();
    _retryTimer = null;
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
  }
}
