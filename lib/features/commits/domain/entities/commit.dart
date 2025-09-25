class CommitInfo {
  const CommitInfo({
    required this.id,
    required this.message,
    required this.author,
    required this.date,
    required this.repoFullName,
  });

  final String id;
  final String message;
  final String author;
  final DateTime date;
  final String repoFullName;

  CommitInfo copyWith({
    String? id,
    String? message,
    String? author,
    DateTime? date,
    String? repoFullName,
  }) {
    return CommitInfo(
      id: id ?? this.id,
      message: message ?? this.message,
      author: author ?? this.author,
      date: date ?? this.date,
      repoFullName: repoFullName ?? this.repoFullName,
    );
  }

  Uri get webUrl => Uri.parse('https://github.com/$repoFullName/commit/$id');
}
