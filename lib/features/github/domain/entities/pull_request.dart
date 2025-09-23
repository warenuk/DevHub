class PullRequest {
  const PullRequest({
    required this.id,
    required this.number,
    required this.title,
    required this.state,
    required this.author,
  });

  final int id;
  final int number;
  final String title;
  final String state; // open, closed, merged
  final String author;
}
