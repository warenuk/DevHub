import 'package:firebase_auth/firebase_auth.dart' as fb;

class GithubWebOAuthDataSource {
  const GithubWebOAuthDataSource();

  Future<String> signIn({
    List<String> scopes = const ['repo', 'read:user'],
  }) async {
    final provider = fb.GithubAuthProvider();
    for (final s in scopes) {
      provider.addScope(s);
    }
    provider.setCustomParameters({'allow_signup': 'false'});

    final auth = fb.FirebaseAuth.instance;
    try {
      // If already authenticated (e.g., email/password), try link first
      if (auth.currentUser != null) {
        final linked = await auth.currentUser!.linkWithPopup(provider);
        final token = _extractToken(linked);
        if (token != null && token.isNotEmpty) return token;
        throw StateError('Missing GitHub access token after linking');
      }

      // No current user -> sign in with GitHub
      final signed = await auth.signInWithPopup(provider);
      final token = _extractToken(signed);
      if (token != null && token.isNotEmpty) return token;
      throw StateError('Missing GitHub access token after sign-in');
    } on fb.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          {
            final pending = e.credential; // GitHub credential to link later
            final email = e.email;
            if (email != null && pending != null) {
              throw fb.FirebaseAuthException(
                code: 'login-with-existing-provider',
                message:
                    'Обліковка $email вже існує з іншим методом входу. Спершу виконайте автентифікацію існуючим способом (наприклад, email/пароль), а потім додайте GitHub у налаштуваннях.',
              );
            }
            rethrow;
          }
        case 'credential-already-in-use':
          {
            final cred = e.credential;
            if (cred != null) {
              final res = await auth.signInWithCredential(cred);
              final token = _extractToken(res);
              if (token != null && token.isNotEmpty) return token;
            }
            rethrow;
          }
        case 'provider-already-linked':
          {
            final re = await auth.currentUser!.reauthenticateWithPopup(
              provider,
            );
            final token = _extractToken(re);
            if (token != null && token.isNotEmpty) return token;
            rethrow;
          }
        case 'requires-recent-login':
          {
            if (auth.currentUser != null) {
              await auth.currentUser!.reauthenticateWithPopup(provider);
              final linked = await auth.currentUser!.linkWithPopup(provider);
              final token = _extractToken(linked);
              if (token != null && token.isNotEmpty) return token;
            }
            rethrow;
          }
        case 'popup-closed-by-user':
          throw fb.FirebaseAuthException(
            code: 'popup-closed-by-user',
            message: 'Вікно авторизації було закрито. Спробуйте ще раз.',
          );
        default:
          rethrow;
      }
    }
  }

  String? _extractToken(fb.UserCredential cred) {
    final o = cred.credential;
    if (o is fb.OAuthCredential) {
      return o.accessToken;
    }
    return null;
  }
}
