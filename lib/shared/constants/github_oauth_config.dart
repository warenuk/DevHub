class GithubOAuthConfig {
  GithubOAuthConfig._();

  // Provide GitHub OAuth App Client ID via --dart-define or replace here.
  static const clientId = String.fromEnvironment(
    'GITHUB_CLIENT_ID',
    // Leave empty by default; use dart-define or sample file for local runs.
    defaultValue: '',
  );
  static const defaultScope = 'repo read:user';
}
