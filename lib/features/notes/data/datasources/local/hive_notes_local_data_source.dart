import 'dart:convert';

import 'package:devhub_gpt/features/notes/domain/entities/note.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveNotesLocalDataSource {
  HiveNotesLocalDataSource(this._box);
  final Box<String> _box;

  static const String boxName = 'notes_box';

  static Map<String, dynamic> _toMap(Note n) => {
        'id': n.id,
        'title': n.title,
        'content': n.content,
        'createdAt': n.createdAt.toIso8601String(),
        'updatedAt': n.updatedAt.toIso8601String(),
      };

  static Note _fromMap(Map<String, dynamic> m) => Note(
        id: m['id'] as String,
        title: m['title'] as String,
        content: m['content'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
        updatedAt: DateTime.parse(m['updatedAt'] as String),
      );

  Future<List<Note>> loadAll() async {
    final values = _box.values;
    final list = values
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .map(_fromMap)
        .toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<Note> insert({required String title, required String content}) async {
    final now = DateTime.now();
    final n = Note(
      id: '${now.microsecondsSinceEpoch}',
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    await _box.put(n.id, jsonEncode(_toMap(n)));
    return n;
  }

  Future<Note> update(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await _box.put(updated.id, jsonEncode(_toMap(updated)));
    return updated;
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
