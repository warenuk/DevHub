import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';

class ListNotesUseCase {
  const ListNotesUseCase(this._repo);
  final NotesRepository _repo;

  Future<List<Note>> call() => _repo.listNotes();
}
