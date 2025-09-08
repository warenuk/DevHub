import 'package:devhub_gpt/core/db/app_database.dart';
import 'package:devhub_gpt/features/notes/data/datasources/local/notes_local_dao.dart';
import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';

class DriftNotesRepository implements NotesRepository {
  DriftNotesRepository(AppDatabase db) : _dao = NotesLocalDao(db);
  final NotesLocalDao _dao;

  @override
  Future<Note> createNote({required String title, required String content}) {
    return _dao.insert(title: title, content: content);
  }

  @override
  Future<void> deleteNote(String id) => _dao.delete(id);

  @override
  Future<List<Note>> listNotes() => _dao.listNotes();

  @override
  Future<Note> updateNote(Note note) => _dao.update(note);
}
