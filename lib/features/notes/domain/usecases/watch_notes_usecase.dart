import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';

class WatchNotesUseCase {
  const WatchNotesUseCase(this._repo);
  final NotesRepository _repo;

  Stream<List<Note>> call() => _repo.watchNotes();
}
