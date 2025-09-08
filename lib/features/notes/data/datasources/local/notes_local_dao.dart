import 'package:devhub_gpt/core/db/app_database.dart';
import 'package:devhub_gpt/features/notes/domain/entities/note.dart' as domain;
import 'package:drift/drift.dart' as d;

class NotesLocalDao {
  NotesLocalDao(this._db);
  final AppDatabase _db;

  Future<List<domain.Note>> listNotes() async {
    final rows = await (_db.select(_db.notes)
          ..orderBy(
            [
              (t) => d.OrderingTerm(
                    expression: t.updatedAt,
                    mode: d.OrderingMode.desc,
                  ),
            ],
          ))
        .get();
    return rows
        .map(
          (r) => domain.Note(
            id: r.id,
            title: r.title,
            content: r.content,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
        )
        .toList();
  }

  Future<domain.Note> insert({
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final id = '${now.microsecondsSinceEpoch}';
    await _db.into(_db.notes).insert(
          NotesCompanion.insert(
            id: id,
            title: title,
            content: content,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return domain.Note(
      id: id,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<domain.Note> update(domain.Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await (_db.update(_db.notes)..where((t) => t.id.equals(updated.id))).write(
      NotesCompanion(
        title: d.Value(updated.title),
        content: d.Value(updated.content),
        updatedAt: d.Value(updated.updatedAt),
      ),
    );
    return updated;
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
  }
}
