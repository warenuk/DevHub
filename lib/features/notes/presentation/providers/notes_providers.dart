import 'package:devhub_gpt/features/notes/data/datasources/local/hive_notes_local_data_source.dart';
import 'package:devhub_gpt/features/notes/data/repositories/in_memory_notes_repository.dart';
import 'package:devhub_gpt/features/notes/data/repositories/notes_repository_hive.dart';
import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';
import 'package:devhub_gpt/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:devhub_gpt/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:devhub_gpt/features/notes/domain/usecases/list_notes_usecase.dart';
import 'package:devhub_gpt/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  // За замовчуванням — InMemory для простоти тестів.
  // У проді/рантаймі ми робимо override у main.dart на HiveNotesRepository.
  return InMemoryNotesRepository();
});

final hiveNotesRepositoryProvider =
    FutureProvider<NotesRepository>((ref) async {
  if (!Hive.isAdapterRegistered(0)) {
    // no adapters used; we store JSON strings — просто ensure init
  }
  if (!Hive.isBoxOpen(HiveNotesLocalDataSource.boxName)) {
    await Hive.initFlutter();
  }
  final box = await Hive.openBox<String>(HiveNotesLocalDataSource.boxName);
  return HiveNotesRepository(HiveNotesLocalDataSource(box));
});

class NotesController extends StateNotifier<AsyncValue<List<Note>>>
    with _NoteActions {
  NotesController(this._repo) : super(const AsyncValue.data(<Note>[])) {
    _refresh();
  }
  final NotesRepository _repo;

  Future<void> _refresh() async {
    state = const AsyncValue.loading();
    try {
      final list = await ListNotesUseCase(_repo).call();
      state = AsyncValue.data(list);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  @override
  Future<void> add(String title, String content) async {
    try {
      await CreateNoteUseCase(_repo).call(title: title, content: content);
      await _refresh();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  @override
  Future<void> update(Note note) async {
    try {
      await UpdateNoteUseCase(_repo).call(note);
      await _refresh();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  @override
  Future<void> remove(String id) async {
    try {
      await DeleteNoteUseCase(_repo).call(id);
      await _refresh();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
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
