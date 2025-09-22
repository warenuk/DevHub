import 'package:freezed_annotation/freezed_annotation.dart';

part 'pull_request.freezed.dart';

@freezed
class PullRequest with _$PullRequest {
  const factory PullRequest({
    required int id,
    required int number,
    required String title,
    required String state,
    required String author,
  }) = _PullRequest;
}
