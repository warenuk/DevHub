import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';

class UpdateNoteUseCase {
  const UpdateNoteUseCase(this._repo);
  final NotesRepository _repo;

  Future<Note> call(Note note) => _repo.updateNote(note);
}
