import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';

class InMemoryNotesRepository implements NotesRepository {
  static int _counter = 0;
  final List<Note> _notes = <Note>[];

  @override
  Future<Note> createNote({
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: '${now.microsecondsSinceEpoch}_${_counter++}',
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    _notes.insert(0, note);
    return note;
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
  }

  @override
  Future<List<Note>> listNotes() async {
    return List<Note>.unmodifiable(_notes);
  }

  @override
  Future<Note> updateNote(Note note) async {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      final updated = note.copyWith(updatedAt: DateTime.now());
      _notes[idx] = updated;
      return updated;
    }
    _notes.insert(0, note);
    return note;
  }
}
