import 'package:devhub_gpt/features/notes/data/models/incoming_note.dart';
import 'package:devhub_gpt/features/notes/domain/entities/note.dart' as domain;

class RemoteNoteDto {
  const RemoteNoteDto({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RemoteNoteDto.fromJson(Map<String, dynamic> json) {
    return RemoteNoteDto(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory RemoteNoteDto.fromDomain(domain.Note note) {
    return RemoteNoteDto(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  IncomingNote toIncoming() => IncomingNote(
        id: id,
        title: title,
        content: content,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
