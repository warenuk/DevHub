import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_oauth_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_web_oauth_data_source.dart';
import 'package:devhub_gpt/features/github/data/repositories/github_auth_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/in_memory_token_store.dart';

class _TokenGithubWebOAuthDataSource extends GithubWebOAuthDataSource {
  _TokenGithubWebOAuthDataSource(this.token);
  final String token;
  int calls = 0;

  @override
  Future<String> signIn({
    List<String> scopes = const ['repo', 'read:user'],
  }) async {
    calls++;
    return token;
  }
}

class _ThrowingGithubWebOAuthDataSource extends GithubWebOAuthDataSource {
  _ThrowingGithubWebOAuthDataSource(this.error);
  final fb.FirebaseAuthException error;

  @override
  Future<String> signIn({
    List<String> scopes = const ['repo', 'read:user'],
  }) async {
    throw error;
  }
}

void main() {
  test('signInWithWeb stores token on web', () async {
    if (!kIsWeb) {
      return;
    }
    final store = InMemoryTokenStore();
    final webSource = _TokenGithubWebOAuthDataSource('token-123');
    final repo = GithubAuthRepositoryImpl(
      GithubOAuthRemoteDataSource(Dio()),
      store,
      web: webSource,
    );

    final result = await repo.signInWithWeb(rememberMe: true);

    expect(webSource.calls, 1);
    result.fold(
      (failure) => fail('Expected success but got $failure'),
      (token) => expect(token, 'token-123'),
    );
    expect(await store.read(), 'token-123');
  });

  test('signInWithWeb maps FirebaseAuthException to AuthFailure', () async {
    if (!kIsWeb) {
      return;
    }
    final store = InMemoryTokenStore();
    final repo = GithubAuthRepositoryImpl(
      GithubOAuthRemoteDataSource(Dio()),
      store,
      web: _ThrowingGithubWebOAuthDataSource(
        fb.FirebaseAuthException(
          code: 'popup-closed-by-user',
          message: 'Вікно авторизації було закрито. Спробуйте ще раз.',
        ),
      ),
    );

    final result = await repo.signInWithWeb(rememberMe: false);

    result.fold((failure) {
      expect(failure, isA<AuthFailure>());
      expect(failure.message, contains('Вікно авторизації'));
    }, (_) => fail('Expected AuthFailure for FirebaseAuthException'));
    expect(await store.read(), isNull);
  });
}
