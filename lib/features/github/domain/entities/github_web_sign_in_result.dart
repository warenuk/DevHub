class GithubWebSignInResult {
  const GithubWebSignInResult._({
    required this.redirectInProgress,
    this.accessToken,
  });

  factory GithubWebSignInResult.authorized(String token) =>
      GithubWebSignInResult._(accessToken: token, redirectInProgress: false);

  const GithubWebSignInResult.redirecting()
      : this._(redirectInProgress: true, accessToken: null);

  final bool redirectInProgress;
  final String? accessToken;
}
