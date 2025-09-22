import 'package:devhub_gpt/features/github/domain/entities/github_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_user_model.freezed.dart';

@freezed
class GithubUserModel with _$GithubUserModel {
  const factory GithubUserModel({
    required String login,
    required String avatarUrl,
  }) = _GithubUserModel;

  factory GithubUserModel.fromJson(Map<String, dynamic> json) =>
      _GithubUserModel(
        login: json['login'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String? ?? '',
      );
}

extension GithubUserModelX on GithubUserModel {
  GithubUser toDomain() => GithubUser(login: login, avatarUrl: avatarUrl);
}
