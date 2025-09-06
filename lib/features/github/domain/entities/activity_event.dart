class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.type,
    required this.repoFullName,
    required this.createdAt,
    this.summary,
  });

  final String id;
  final String type; // PushEvent, PullRequestEvent, etc.
  final String repoFullName;
  final DateTime createdAt;
  final String? summary;
}
