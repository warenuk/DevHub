// ignore_for_file: invalid_annotation_target

import 'package:devhub_gpt/features/github/domain/entities/github_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_user_model.freezed.dart';
part 'github_user_model.g.dart';

@freezed
class GithubUserModel with _$GithubUserModel {
  const factory GithubUserModel({
    required String login,
    @JsonKey(name: 'avatar_url') required String avatarUrl,
  }) = _GithubUserModel;

  factory GithubUserModel.fromJson(Map<String, dynamic> json) =>
      _$GithubUserModelFromJson(json);
}

extension GithubUserModelX on GithubUserModel {
  GithubUser toDomain() => GithubUser(login: login, avatarUrl: avatarUrl);
}
