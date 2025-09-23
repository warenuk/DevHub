class Repo {
  const Repo({
    required this.id,
    required this.name,
    required this.fullName,
    this.language,
    this.stargazersCount = 0,
    this.forksCount = 0,
    this.description,
  });

  final int id;
  final String name;
  final String fullName;
  final String? language;
  final int stargazersCount;
  final int forksCount;
  final String? description;
}
