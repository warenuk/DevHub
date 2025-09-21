import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/domain/entities/oauth.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_auth_repository.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_auth_notifier.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/in_memory_token_store.dart';

class _FakeGithubAuthRepository implements GithubAuthRepository {
  _FakeGithubAuthRepository({Either<Failure, String>? signInResult})
      : _signInResult = signInResult ?? const Right('token');

  Either<Failure, GithubDeviceCode> startResult = const Right(
    GithubDeviceCode(
      deviceCode: 'd',
      userCode: 'u',
      verificationUri: 'https://example.com',
      expiresIn: 900,
      interval: 5,
    ),
  );
  Either<Failure, GithubAuthToken> pollResult = const Right(
    GithubAuthToken(accessToken: 'token', tokenType: 'bearer', scope: 'repo'),
  );
  final Either<Failure, String> _signInResult;
  bool deleteCalled = false;
  int signInCalls = 0;

  @override
  Future<void> deleteToken() async {
    deleteCalled = true;
  }

  @override
  Future<Either<Failure, GithubAuthToken>> pollForToken({
    required String clientId,
    required String deviceCode,
    int interval = 5,
  }) async {
    return pollResult;
  }

  @override
  Future<Either<Failure, String>> signInWithWeb({
    List<String> scopes = const ['repo', 'read:user'],
    required bool rememberMe,
    Duration? ttl,
  }) async {
    signInCalls++;
    return _signInResult;
  }

  @override
  Future<Either<Failure, GithubDeviceCode>> startDeviceFlow({
    required String clientId,
    String scope = 'repo read:user',
  }) async {
    return startResult;
  }

  @override
  Future<void> saveToken(
    String token, {
    required bool rememberMe,
    Duration? ttl,
  }) async {}

  @override
  Future<String?> readToken() async => 'token';
}

void main() {
  test('signInWeb updates state to authorized on success', () async {
    final fakeStore = InMemoryTokenStore();
    final fakeRepo = _FakeGithubAuthRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(fakeStore),
        githubAuthRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(githubAuthNotifierProvider.notifier);

    await notifier.signInWeb();

    expect(fakeRepo.signInCalls, 1);
    expect(container.read(githubAuthNotifierProvider), isA<GithubAuthAuthorized>());
  });

  test('signInWeb exposes error from repository', () async {
    final fakeRepo = _FakeGithubAuthRepository(
      signInResult: const Left(AuthFailure('popup-closed-by-user')),
    );
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
        githubAuthRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(githubAuthNotifierProvider.notifier);

    await notifier.signInWeb();

    final state = container.read(githubAuthNotifierProvider);
    expect(state, isA<GithubAuthError>());
    expect((state as GithubAuthError).message, 'popup-closed-by-user');
  });

  test('loadFromStorage transitions to authorized when token exists', () async {
    final store = InMemoryTokenStore();
    await store.write(
      'persisted-token',
      rememberMe: true,
    );
    final fakeRepo = _FakeGithubAuthRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        githubAuthRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(githubAuthNotifierProvider.notifier);
    await notifier.loadFromStorage();

    expect(container.read(githubAuthNotifierProvider), isA<GithubAuthAuthorized>());
  });

  test('signOut clears repository token and resets state', () async {
    final fakeRepo = _FakeGithubAuthRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
        githubAuthRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(githubAuthNotifierProvider.notifier);
    container.read(githubRememberSessionProvider.notifier).state = true;

    await notifier.signOut();

    expect(fakeRepo.deleteCalled, isTrue);
    expect(container.read(githubAuthNotifierProvider), isA<GithubAuthIdle>());
    expect(container.read(githubRememberSessionProvider), isFalse);
  });
}
