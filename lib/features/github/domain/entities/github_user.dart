class GithubUser {
  const GithubUser({
    required this.login,
    required this.avatarUrl,
  });

  final String login;     // нік користувача (НЕ ім'я)
  final String avatarUrl; // url аватарки
}