import 'package:devhub_gpt/features/github/domain/entities/github_user.dart';

class GithubUserModel {
  GithubUserModel({
    required this.login,
    required this.avatarUrl,
  });

  factory GithubUserModel.fromJson(Map<String, dynamic> json) =>
      GithubUserModel(
        login: json['login'] as String,
        avatarUrl: json['avatar_url'] as String,
      );

  final String login;
  final String avatarUrl;

  GithubUser toDomain() => GithubUser(login: login, avatarUrl: avatarUrl);
}
