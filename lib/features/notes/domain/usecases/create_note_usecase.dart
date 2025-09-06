import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';

class CreateNoteUseCase {
  const CreateNoteUseCase(this._repo);
  final NotesRepository _repo;

  Future<Note> call({required String title, required String content}) {
    return _repo.createNote(title: title, content: content);
  }
}
