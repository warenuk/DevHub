import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show visibleForTesting;

const String kGithubRedirectPendingToken = '__github_redirect_pending__';

abstract class GithubWebOAuthDataSourceBase {
  Future<String> signIn({List<String> scopes = const ['repo', 'read:user']});
  Future<String?> consumeRedirectResult();
}

class GithubWebOAuthDataSource implements GithubWebOAuthDataSourceBase {
  GithubWebOAuthDataSource({fb.FirebaseAuth? auth}) : _auth = auth;

  final fb.FirebaseAuth? _auth;

  fb.FirebaseAuth get _firebaseAuth => _auth ?? fb.FirebaseAuth.instance;

  @override
  Future<String> signIn({
    List<String> scopes = const ['repo', 'read:user'],
  }) async {
    final provider = fb.GithubAuthProvider();
    for (final s in scopes) {
      provider.addScope(s);
    }
    provider.setCustomParameters({'allow_signup': 'false'});

    // If ми повернулися з редіректу, то вже є готовий результат.
    final redirected = await consumeRedirectResult();
    if (redirected != null && redirected.isNotEmpty) {
      return redirected;
    }

    late final fb.FirebaseAuth auth;
    try {
      auth = _firebaseAuth;
      // If already authenticated (e.g., email/password), try link first
      if (auth.currentUser != null) {
        final linked = await auth.currentUser!.linkWithPopup(provider);
        return _requireToken(linked, context: 'linking');
      }

      // No current user -> sign in with GitHub
      final signed = await auth.signInWithPopup(provider);
      return _requireToken(signed, context: 'sign-in');
    } on fb.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          {
            final pending = e.credential; // GitHub credential to link later
            final email = e.email;
            if (email != null && pending != null) {
              // ignore: deprecated_member_use
              final methods = await auth.fetchSignInMethodsForEmail(email);
              if (methods.contains('password')) {
                throw fb.FirebaseAuthException(
                  code: 'password-login-required',
                  message:
                      'Ця адреса вже використовується з паролем. Увійдіть email/пароль, потім повторіть GitHub для привʼязки.',
                );
              }
              if (methods.contains('github.com')) {
                final signed = await auth.signInWithPopup(provider);
                final token = _extractToken(signed);
                if (token != null && token.isNotEmpty) return token;
              }
              throw fb.FirebaseAuthException(
                code: 'login-with-existing-provider',
                message:
                    'Обліковка вже існує з іншим провайдером (${methods.join(', ')}). Увійдіть ним, потім повторіть GitHub.',
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
            final re =
                await auth.currentUser!.reauthenticateWithPopup(provider);
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
        case 'operation-not-supported-in-this-environment':
        case 'popup-blocked':
          await _startRedirect(provider, auth);
          return kGithubRedirectPendingToken;
        case 'popup-closed-by-user':
          throw fb.FirebaseAuthException(
            code: 'popup-closed-by-user',
            message: 'Вікно авторизації було закрито. Спробуйте ще раз.',
          );
        default:
          rethrow;
      }
    } on fb.FirebaseException catch (e) {
      throw fb.FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  @override
  Future<String?> consumeRedirectResult() async {
    try {
      final auth = _firebaseAuth;
      final result = await auth.getRedirectResult();
      if (result.user == null && result.credential == null) {
        return null;
      }
      final token = _extractToken(result);
      if (token != null && token.isNotEmpty) {
        return token;
      }
    } on fb.FirebaseAuthException catch (e) {
      // "no-current-user"/"no-auth-event" означає, що редірект ще не завершився
      // або був скасований — у такому випадку просто продовжуємо з popup flow.
      if (shouldIgnoreRedirectError(e.code)) {
        return null;
      }
      rethrow;
    } on fb.FirebaseException catch (e) {
      throw fb.FirebaseAuthException(code: e.code, message: e.message);
    }
    return null;
  }

  String? _extractToken(fb.UserCredential cred) {
    final o = cred.credential;
    if (o is fb.OAuthCredential) {
      return o.accessToken;
    }
    return null;
  }

  String _requireToken(
    fb.UserCredential credential, {
    required String context,
  }) {
    final token = _extractToken(credential);
    if (token != null && token.isNotEmpty) {
      return token;
    }
    throw StateError('Missing GitHub access token after $context');
  }

  Future<void> _startRedirect(
    fb.GithubAuthProvider provider,
    fb.FirebaseAuth auth,
  ) async {
    if (auth.currentUser != null) {
      await auth.currentUser!.linkWithRedirect(provider);
    } else {
      await auth.signInWithRedirect(provider);
    }
  }
}

@visibleForTesting
bool shouldIgnoreRedirectError(String code) {
  switch (code) {
    case 'no-current-user':
    case 'no-auth-event':
    case 'auth/no-auth-event':
      return true;
    default:
      return false;
  }
}
