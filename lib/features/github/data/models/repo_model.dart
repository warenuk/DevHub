import 'package:devhub_gpt/features/github/domain/entities/repo.dart';

class RepoModel {
  RepoModel({
    required this.id,
    required this.name,
    required this.fullName,
    this.language,
    this.stargazersCount = 0,
    this.forksCount = 0,
    this.description,
  });

  factory RepoModel.fromJson(Map<String, dynamic> json) => RepoModel(
    id: json['id'] as int,
    name: json['name'] as String,
    fullName: json['full_name'] as String,
    language: json['language'] as String?,
    stargazersCount: (json['stargazers_count'] as num?)?.toInt() ?? 0,
    forksCount: (json['forks_count'] as num?)?.toInt() ?? 0,
    description: json['description'] as String?,
  );

  final int id;
  final String name;
  final String fullName;
  final String? language;
  final int stargazersCount;
  final int forksCount;
  final String? description;

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
