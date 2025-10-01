class IncomingNote {
  const IncomingNote({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime updatedAt;
}
