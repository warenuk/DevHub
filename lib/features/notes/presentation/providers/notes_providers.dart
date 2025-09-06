import 'package:devhub_gpt/features/notes/data/repositories/in_memory_notes_repository.dart';
import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';
import 'package:devhub_gpt/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:devhub_gpt/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:devhub_gpt/features/notes/domain/usecases/list_notes_usecase.dart';
import 'package:devhub_gpt/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return InMemoryNotesRepository();
});

class NotesController extends StateNotifier<AsyncValue<List<Note>>>
    with _NoteActions {
  NotesController(this._repo) : super(const AsyncValue.data(<Note>[])) {
    _refresh();
  }
  final NotesRepository _repo;

  Future<void> _refresh() async {
    state = const AsyncValue.loading();
    final list = await ListNotesUseCase(_repo).call();
    state = AsyncValue.data(list);
  }

  @override
  Future<void> add(String title, String content) async {
    await CreateNoteUseCase(_repo).call(title: title, content: content);
    await _refresh();
  }

  @override
  Future<void> update(Note note) async {
    await UpdateNoteUseCase(_repo).call(note);
    await _refresh();
  }

  @override
  Future<void> remove(String id) async {
    await DeleteNoteUseCase(_repo).call(id);
    await _refresh();
  }
}

mixin _NoteActions {
  Future<void> add(String title, String content);
  Future<void> update(Note note);
  Future<void> remove(String id);
}

final notesControllerProvider =
    StateNotifierProvider<NotesController, AsyncValue<List<Note>>>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  return NotesController(repo);
});
