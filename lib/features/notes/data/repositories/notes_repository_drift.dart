import 'package:devhub_gpt/core/db/app_database.dart';
import 'package:devhub_gpt/features/notes/domain/entities/note.dart' as domain;
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';
import 'package:drift/drift.dart';

class IncomingNote {
  const IncomingNote({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.createdAt,
  });
  final String id;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime updatedAt;
}

/// Репозиторій нотаток на Drift з політикою конфліктів LWW (last-write-wins).
class NotesRepositoryDrift implements NotesRepository {
  NotesRepositoryDrift(this.db);
  final AppDatabase db;

  domain.Note _toDomain(NoteRow r) => domain.Note(
        id: r.id,
        title: r.title,
        content: r.content,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  /// Створити/оновити локальну нотатку.
  Future<void> upsertLocal({
    required String id,
    required String title,
    required String content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) async {
    final now = DateTime.now();
    final row = await (db.select(db.notes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    final created = createdAt ?? row?.createdAt ?? now;
    final updated = updatedAt ?? now;
    await db.into(db.notes).insertOnConflictUpdate(
          NotesCompanion(
            id: Value(id),
            title: Value(title),
            content: Value(content),
            createdAt: Value(created),
            updatedAt: Value(updated),
          ),
        );
  }

  /// Злити віддалені нотатки з локальними за правилом LWW.
  /// Якщо віддалена `updatedAt` новіша — перезаписуємо локальну.
  /// Якщо локальної немає — вставляємо.
  Future<void> mergeIncoming(List<IncomingNote> incoming) async {
    await db.transaction(() async {
      for (final n in incoming) {
        final local = await (db.select(db.notes)
              ..where((t) => t.id.equals(n.id)))
            .getSingleOrNull();
        if (local == null) {
          await db.into(db.notes).insert(
                NotesCompanion(
                  id: Value(n.id),
                  title: Value(n.title),
                  content: Value(n.content),
                  createdAt: Value(n.createdAt ?? n.updatedAt),
                  updatedAt: Value(n.updatedAt),
                ),
              );
          continue;
        }
        // LWW: якщо віддалена новіша — перезапис
        if (n.updatedAt.isAfter(local.updatedAt)) {
          await (db.update(db.notes)..where((t) => t.id.equals(n.id))).write(
            NotesCompanion(
              title: Value(n.title),
              content: Value(n.content),
              updatedAt: Value(n.updatedAt),
            ),
          );
        }
      }
    });
  }

  Future<List<NoteRow>> listAll() async {
    return (db.select(db.notes)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  // ---- NotesRepository API ----
  @override
  Future<List<domain.Note>> listNotes() async {
    final rows = await (db.select(db.notes)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<domain.Note> createNote(
      {required String title, required String content}) async {
    final now = DateTime.now();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await db.into(db.notes).insert(
          NotesCompanion(
            id: Value(id),
            title: Value(title),
            content: Value(content),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return domain.Note(
        id: id, title: title, content: content, createdAt: now, updatedAt: now);
  }

  @override
  Future<domain.Note> updateNote(domain.Note note) async {
    final upd = note.updatedAt.isAfter(note.createdAt)
        ? note.updatedAt
        : DateTime.now();
    await (db.update(db.notes)..where((t) => t.id.equals(note.id))).write(
      NotesCompanion(
        title: Value(note.title),
        content: Value(note.content),
        updatedAt: Value(upd),
      ),
    );
    return note.copyWith(updatedAt: upd);
  }

  @override
  Future<void> deleteNote(String id) async {
    await (db.delete(db.notes)..where((t) => t.id.equals(id))).go();
  }
}
