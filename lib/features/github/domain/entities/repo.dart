import 'package:freezed_annotation/freezed_annotation.dart';

part 'repo.freezed.dart';

@freezed
class Repo with _$Repo {
  const factory Repo({
    required int id,
    required String name,
    required String fullName,
    String? language,
    @Default(0) int stargazersCount,
    @Default(0) int forksCount,
    String? description,
  }) = _Repo;
}
