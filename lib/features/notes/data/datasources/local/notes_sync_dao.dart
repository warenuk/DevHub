import 'package:devhub_gpt/core/db/app_database.dart';

enum NoteMutationType { upsert, delete }

class NoteMutationEntry {
  const NoteMutationEntry({
    required this.id,
    required this.noteId,
    required this.type,
    required this.enqueuedAt,
    this.payload,
  });

  factory NoteMutationEntry.upsert({
    required String noteId,
    required String payload,
    DateTime? enqueuedAt,
  }) {
    final now = enqueuedAt ?? DateTime.now();
    return NoteMutationEntry(
      id: 'upsert-$noteId',
      noteId: noteId,
      type: NoteMutationType.upsert,
      payload: payload,
      enqueuedAt: now,
    );
  }

  factory NoteMutationEntry.delete({
    required String noteId,
    DateTime? enqueuedAt,
    String? payload,
  }) {
    final now = enqueuedAt ?? DateTime.now();
    return NoteMutationEntry(
      id: 'delete-$noteId',
      noteId: noteId,
      type: NoteMutationType.delete,
      payload: payload,
      enqueuedAt: now,
    );
  }

  final String id;
  final String noteId;
  final NoteMutationType type;
  final String? payload;
  final DateTime enqueuedAt;

  Map<String, Object?> toColumns() => {
        'id': id,
        'note_id': noteId,
        'type': type.name,
        'payload': payload,
        'enqueued_at': enqueuedAt.millisecondsSinceEpoch,
      };

  static NoteMutationEntry fromRow(Map<String, Object?> data) {
    final rawType = data['type'] as String?;
    final rawEnqueued = data['enqueued_at'];
    return NoteMutationEntry(
      id: data['id'] as String,
      noteId: data['note_id'] as String,
      type: NoteMutationType.values.firstWhere(
        (t) => t.name == rawType,
        orElse: () => throw StateError('Unknown note mutation type: $rawType'),
      ),
      payload: data['payload'] as String?,
      enqueuedAt: _parseEpoch(rawEnqueued),
    );
  }

  static DateTime _parseEpoch(Object? value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: false);
    }
    if (value is BigInt) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: false);
    }
    if (value is String) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(value),
          isUtc: false);
    }
    throw StateError('Unsupported epoch value: $value');
  }
}

class NotesSyncDao {
  NotesSyncDao(this._db);
  final AppDatabase _db;

  Future<void> upsert(NoteMutationEntry entry) async {
    final columns = entry.toColumns();
    await _db.customStatement(
      'INSERT OR REPLACE INTO note_mutations (id, note_id, type, payload, enqueued_at) VALUES (?1, ?2, ?3, ?4, ?5)',
      [
        columns['id'],
        columns['note_id'],
        columns['type'],
        columns['payload'],
        columns['enqueued_at'],
      ],
    );
  }

  Future<void> removeById(String id) async {
    await _db.customStatement(
      'DELETE FROM note_mutations WHERE id = ?1',
      [id],
    );
  }

  Future<void> removeUpsertFor(String noteId) async {
    await removeById('upsert-$noteId');
  }

  Future<void> removeDeleteFor(String noteId) async {
    await removeById('delete-$noteId');
  }

  Future<List<NoteMutationEntry>> pending() async {
    final rows = await _db
        .customSelect(
          'SELECT id, note_id, type, payload, enqueued_at FROM note_mutations ORDER BY enqueued_at ASC',
        )
        .get();
    return rows.map((row) => NoteMutationEntry.fromRow(row.data)).toList();
  }

  Future<void> clear() async {
    await _db.customStatement('DELETE FROM note_mutations');
  }
}
