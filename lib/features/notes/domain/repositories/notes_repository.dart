import 'package:devhub_gpt/features/notes/domain/entities/note.dart';

/// Контракт доменного шару для нотаток.
///
/// Методи не кидають винятків — помилки обробляються на рівні реалізацій
/// (data layer) та презентуються у відповідних use‑case або контролерах.
abstract class NotesRepository {
  /// Повертає список усіх нотаток.
  Future<List<Note>> listNotes();

  /// Створює нову нотатку.
  Future<Note> createNote({required String title, required String content});

  /// Оновлює існуючу нотатку та повертає її актуальний стан.
  Future<Note> updateNote(Note note);

  /// Видаляє нотатку за ідентифікатором.
  Future<void> deleteNote(String id);
}
