import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';

class CommitModel {
  CommitModel({
    required this.id,
    required this.message,
    required this.author,
    required this.date,
  });

  factory CommitModel.fromJson(Map<String, dynamic> json) {
    final sha = (json['sha'] ?? '').toString();
    final commit = json['commit'] as Map<String, dynamic>? ?? {};
    final author = commit['author'] as Map<String, dynamic>?;
    return CommitModel(
      id: sha,
      message: (commit['message'] as String?)?.trim() ?? '',
      author: (author?['name'] as String?) ?? 'unknown',
      date: DateTime.tryParse((author?['date'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  final String id;
  final String message;
  final String author;
  final DateTime date;

  CommitInfo toDomain({required String repoFullName}) => CommitInfo(
        id: id,
        message: message,
        author: author,
        date: date,
        repoFullName: repoFullName,
      );
}
