import 'package:freezed_annotation/freezed_annotation.dart';

part 'commit.freezed.dart';
part 'commit.g.dart';

@freezed
class CommitInfo with _$CommitInfo {
  const factory CommitInfo({
    required String id,
    required String message,
    required String author,
    required DateTime date,
  }) = _CommitInfo;

  factory CommitInfo.fromJson(Map<String, dynamic> json) =>
      _$CommitInfoFromJson(json);
}
