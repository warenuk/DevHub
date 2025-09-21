import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_oauth_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_web_oauth_data_source.dart';
import 'package:devhub_gpt/features/github/data/repositories/github_auth_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/in_memory_token_store.dart';

class _StubGithubWebOAuthDataSource extends GithubWebOAuthDataSource {
  const _StubGithubWebOAuthDataSource();

  @override
  Future<String> signIn({List<String> scopes = const ['repo', 'read:user']}) async =>
      'stub-token';
}

void main() {
  test('signInWithWeb returns failure on non-web platforms', () async {
    final repo = GithubAuthRepositoryImpl(
      GithubOAuthRemoteDataSource(Dio()),
      InMemoryTokenStore(),
      web: const _StubGithubWebOAuthDataSource(),
    );

    final result = await repo.signInWithWeb(rememberMe: false);

    result.fold(
      (failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('Web GitHub sign-in is not available'));
      },
      (_) => fail('Expected failure on non-web platform'),
    );
  });
}
