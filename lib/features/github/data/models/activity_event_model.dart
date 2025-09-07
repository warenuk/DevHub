import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';

class ActivityEventModel {
  ActivityEventModel({
    required this.id,
    required this.type,
    required this.repoFullName,
    required this.createdAt,
    this.summary,
  });

  final String id;
  final String type;
  final String repoFullName;
  final DateTime createdAt;
  final String? summary;

  factory ActivityEventModel.fromJson(Map<String, dynamic> json) {
    final repo = json['repo'] as Map<String, dynamic>?;
    final payload = json['payload'] as Map<String, dynamic>?;
    String? summarize() {
      final t = json['type'] as String?;
      if (t == 'PushEvent') {
        final commits = (payload?['commits'] as List?)?.length ?? 0;
        return 'Pushed $commits commits';
      }
      if (t == 'PullRequestEvent') {
        final action = payload?['action'] as String? ?? 'opened';
        return 'PR $action';
      }
      return null;
    }

    return ActivityEventModel(
      id: (json['id'] ?? '').toString(),
      type: json['type'] as String? ?? 'Event',
      repoFullName: (repo?['name'] as String?) ?? 'unknown/unknown',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      summary: summarize(),
    );
  }

  ActivityEvent toDomain() => ActivityEvent(
        id: id,
        type: type,
        repoFullName: repoFullName,
        createdAt: createdAt,
        summary: summary,
      );
}
