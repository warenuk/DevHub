import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'repo_model.freezed.dart';

@freezed
class RepoModel with _$RepoModel {
  const factory RepoModel({
    required int id,
    required String name,
    required String fullName,
    String? language,
    @Default(0) int stargazersCount,
    @Default(0) int forksCount,
    String? description,
  }) = _RepoModel;

  factory RepoModel.fromJson(Map<String, dynamic> json) => _RepoModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        fullName: json['full_name'] as String? ?? '',
        language: json['language'] as String?,
        stargazersCount:
            (json['stargazers_count'] as num?)?.toInt() ?? 0,
        forksCount: (json['forks_count'] as num?)?.toInt() ?? 0,
        description: json['description'] as String?,
      );
}

extension RepoModelX on RepoModel {
  Repo toDomain() => Repo(
        id: id,
        name: name,
        fullName: fullName,
        language: language,
        stargazersCount: stargazersCount,
        forksCount: forksCount,
        description: description,
      );
}
