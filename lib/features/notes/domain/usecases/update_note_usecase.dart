import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';

class UpdateNoteUseCase {
  const UpdateNoteUseCase(this._repo);
  final NotesRepository _repo;

  Future<Note> call(Note note) {
    final t = note.title.trim();
    if (t.isEmpty) {
      throw ArgumentError('Title must not be empty');
    }
    return _repo.updateNote(note.copyWith(title: t));
  }
}
