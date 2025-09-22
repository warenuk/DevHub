import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_event_model.freezed.dart';

String? _summarizePayload(
  String type,
  Map<String, dynamic>? payload,
) {
  if (type == 'PushEvent') {
    final commits = (payload?['commits'] as List?)?.length ?? 0;
    return 'Pushed $commits commits';
  }
  if (type == 'PullRequestEvent') {
    final action = payload?['action'] as String? ?? 'opened';
    return 'PR $action';
  }
  return null;
}

@freezed
class ActivityEventModel with _$ActivityEventModel {
  const factory ActivityEventModel({
    required String id,
    required String type,
    required String repoFullName,
    required DateTime createdAt,
    String? summary,
  }) = _ActivityEventModel;

  factory ActivityEventModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at'] as String? ?? '';
    final createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    return _ActivityEventModel(
      id: (json['id'] ?? '').toString(),
      type: json['type'] as String? ?? 'Event',
      repoFullName: json['repo_full_name'] as String? ?? '',
      createdAt: createdAt,
      summary: json['summary'] as String?,
    );
  }

  factory ActivityEventModel.fromGithubJson(Map<String, dynamic> json) {
    final repo = json['repo'] as Map<String, dynamic>?;
    final payload = json['payload'] as Map<String, dynamic>?;
    final type = json['type'] as String? ?? 'Event';
    final createdAtRaw = json['created_at'] as String? ?? '';
    final createdAt =
        DateTime.tryParse(createdAtRaw)?.toLocal() ?? DateTime.now();
    return ActivityEventModel(
      id: (json['id'] ?? '').toString(),
      type: type,
      repoFullName: (repo?['name'] as String?) ?? 'unknown/unknown',
      createdAt: createdAt,
      summary: _summarizePayload(type, payload),
    );
  }
}

extension ActivityEventModelX on ActivityEventModel {
  ActivityEvent toDomain() => ActivityEvent(
        id: id,
        type: type,
        repoFullName: repoFullName,
        createdAt: createdAt,
        summary: summary,
      );
}
