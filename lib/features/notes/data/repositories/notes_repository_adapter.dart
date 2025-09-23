import 'package:devhub_gpt/core/db/app_database.dart';
import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';
import 'package:drift/drift.dart';

/// Drift-реалізація [NotesRepository].
class NotesRepositoryAdapter implements NotesRepository {
  NotesRepositoryAdapter(this.db);
  final AppDatabase db;

  Note _toDomain(NoteRow r) => Note(
    id: r.id,
    title: r.title,
    content: r.content,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  );

  @override
  Future<List<Note>> listNotes() async {
    final rows = await (db.select(
      db.notes,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<Note> createNote({
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await db
        .into(db.notes)
        .insert(
          NotesCompanion(
            id: Value(id),
            title: Value(title),
            content: Value(content),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<Note> updateNote(Note note) async {
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
