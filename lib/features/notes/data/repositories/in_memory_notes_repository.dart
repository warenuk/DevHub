import 'dart:async';

import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:devhub_gpt/features/notes/domain/repositories/notes_repository.dart';

class InMemoryNotesRepository implements NotesRepository {
  static int _counter = 0;
  final List<Note> _notes = <Note>[];
  final StreamController<List<Note>> _controller =
      StreamController<List<Note>>.broadcast();

  InMemoryNotesRepository() {
    _controller.onListen = () {
      _controller.add(List<Note>.unmodifiable(_notes));
    };
  }

  void _emit() {
    if (_controller.hasListener) {
      _controller.add(List<Note>.unmodifiable(_notes));
    }
  }

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
    _emit();
    return note;
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    _emit();
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
      _emit();
      return updated;
    }
    _notes.insert(0, note);
    _emit();
    return note;
  }

  @override
  Stream<List<Note>> watchNotes() => _controller.stream;
}
