import 'package:devhub_gpt/features/notes/domain/entities/note.dart';

abstract class NotesSyncService {
  /// Ensure that the realtime stream + initial sync are running.
  Future<void> ensureStarted();

  /// Flush pending offline mutations immediately.
  Future<void> flushPending();

  /// Queue note upsert for remote synchronization.
  Future<void> scheduleUpsert(Note note);

  /// Queue deletion of [noteId] for remote synchronization.
  Future<void> scheduleDelete(String noteId, {DateTime? deletedAt});

  /// Dispose of realtime subscriptions and timers.
  Future<void> dispose();
}
