import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_event.freezed.dart';

@freezed
class ActivityEvent with _$ActivityEvent {
  const factory ActivityEvent({
    required String id,
    required String type,
    required String repoFullName,
    required DateTime createdAt,
    String? summary,
  }) = _ActivityEvent;
}
