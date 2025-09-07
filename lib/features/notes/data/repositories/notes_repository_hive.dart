import 'package:devhub_gpt/features/notes/data/datasources/local/hive_notes_local_data_source.dart';
import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';

class HiveNotesRepository implements NotesRepository {
  HiveNotesRepository(this._local);
  final HiveNotesLocalDataSource _local;

  @override
  Future<Note> createNote({required String title, required String content}) {
    return _local.insert(title: title, content: content);
  }

  @override
  Future<void> deleteNote(String id) => _local.delete(id);

  @override
  Future<List<Note>> listNotes() => _local.loadAll();

  @override
  Future<Note> updateNote(Note note) => _local.update(note);
}
