import 'package:devhub_gpt/features/github/domain/entities/pull_request.dart';

class PullRequestModel {
  const PullRequestModel({
    required this.id,
    required this.number,
    required this.title,
    required this.state,
    required this.author,
  });

  final int id;
  final int number;
  final String title;
  final String state;
  final String author;

  factory PullRequestModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return PullRequestModel(
      id: (json['id'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      title: json['title'] as String? ?? '',
      state: json['state'] as String? ?? 'open',
      author: (user?['login'] as String?) ?? 'unknown',
    );
  }

  PullRequest toDomain() => PullRequest(
        id: id,
        number: number,
        title: title,
        state: state,
        author: author,
      );
}
