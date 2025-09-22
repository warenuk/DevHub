import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'commit_model.freezed.dart';
part 'commit_model.g.dart';

@freezed
class CommitModel with _$CommitModel {
  const factory CommitModel({
    required String id,
    required String message,
    required String author,
    required DateTime date,
  }) = _CommitModel;

  factory CommitModel.fromJson(Map<String, dynamic> json) =>
      _$CommitModelFromJson(json);

  factory CommitModel.fromGitHubJson(Map<String, dynamic> json) {
    final sha = (json['sha'] ?? '').toString();
    final commit = json['commit'] as Map<String, dynamic>? ?? {};
    final author = commit['author'] as Map<String, dynamic>?;
    return CommitModel(
      id: sha,
      message: (commit['message'] as String?)?.trim() ?? '',
      author: (author?['name'] as String?) ?? 'unknown',
      date:
          DateTime.tryParse((author?['date'] as String?) ?? '') ?? DateTime.now(),
    );
  }
}

extension CommitModelX on CommitModel {
  CommitInfo toDomain() => CommitInfo(
        id: id,
        message: message,
        author: author,
        date: date,
      );
}

extension CommitInfoX on CommitInfo {
  CommitModel toDto() => CommitModel(
        id: id,
        message: message,
        author: author,
        date: date,
      );
}
