class CommitInfo {
  const CommitInfo({
    required this.id,
    required this.message,
    required this.author,
    required this.date,
  });

  final String id;
  final String message;
  final String author;
  final DateTime date;
}
