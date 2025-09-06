import 'package:devhub_gpt/features/notes/domain/entities/note.dart';

abstract class NotesRepository {
  Future<List<Note>> listNotes();
  Future<Note> createNote({required String title, required String content});
  Future<Note> updateNote(Note note);
  Future<void> deleteNote(String id);
}
