import 'package:devhub_gpt/features/github/domain/entities/pull_request.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pull_request_model.freezed.dart';

String _extractAuthor(Map<String, dynamic>? user) {
  final login = user?['login'];
  if (login is String && login.isNotEmpty) {
    return login;
  }
  return 'unknown';
}

@freezed
class PullRequestModel with _$PullRequestModel {
  const factory PullRequestModel({
    required int id,
    required int number,
    required String title,
    required String state,
    required String author,
  }) = _PullRequestModel;

  factory PullRequestModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return _PullRequestModel(
      id: (json['id'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      title: json['title'] as String? ?? '',
      state: json['state'] as String? ?? 'open',
      author: _extractAuthor(user),
    );
  }

  factory PullRequestModel.fromGithubJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return PullRequestModel(
      id: (json['id'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      title: json['title'] as String? ?? '',
      state: json['state'] as String? ?? 'open',
      author: _extractAuthor(user),
    );
  }
}

extension PullRequestModelX on PullRequestModel {
  PullRequest toDomain() => PullRequest(
        id: id,
        number: number,
        title: title,
        state: state,
        author: author,
      );
}
