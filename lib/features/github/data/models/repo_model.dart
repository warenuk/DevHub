// ignore_for_file: invalid_annotation_target

import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'repo_model.freezed.dart';
part 'repo_model.g.dart';

@freezed
class RepoModel with _$RepoModel {
  const factory RepoModel({
    required int id,
    required String name,
    @JsonKey(name: 'full_name') required String fullName,
    String? language,
    @JsonKey(name: 'stargazers_count') @Default(0) int stargazersCount,
    @JsonKey(name: 'forks_count') @Default(0) int forksCount,
    String? description,
  }) = _RepoModel;

  factory RepoModel.fromJson(Map<String, dynamic> json) =>
      _$RepoModelFromJson(json);
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
