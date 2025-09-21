import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_oauth_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_web_oauth_data_source.dart';
import 'package:devhub_gpt/features/github/data/repositories/github_auth_repository_impl.dart';
import 'package:devhub_gpt/features/github/domain/entities/github_web_sign_in_result.dart';
import 'package:devhub_gpt/shared/network/token_store.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubSecureStorage extends FlutterSecureStorage {
  final Map<String, String?> _store = {};

  @override
  Future<void> write({
    required String key,
    String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
    MacOsOptions? mOptions,
    WebOptions? webOptions,
  }) async {
    _store[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
    MacOsOptions? mOptions,
    WebOptions? webOptions,
  }) async {
    return _store[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
    MacOsOptions? mOptions,
    WebOptions? webOptions,
  }) async {
    _store.remove(key);
  }
}

class _FakeGithubWebOAuthDataSource implements GithubWebOAuthDataSourceBase {
  _FakeGithubWebOAuthDataSource(
      {this.signInValue = 'token', this.redirectValue});

  String signInValue;
  String? redirectValue;
  fb.FirebaseAuthException? signInError;
  fb.FirebaseAuthException? redirectError;
  int signInCalls = 0;
  int consumeCalls = 0;

  @override
  Future<String> signIn(
      {List<String> scopes = const ['repo', 'read:user']}) async {
    signInCalls++;
    if (signInError != null) throw signInError!;
    return signInValue;
  }

  @override
  Future<String?> consumeRedirectResult() async {
    consumeCalls++;
    if (redirectError != null) throw redirectError!;
    return redirectValue;
  }
}

void main() {
  late GithubAuthRepositoryImpl repository;
  late _FakeGithubWebOAuthDataSource web;
  late TokenStore store;

  setUp(() {
    web = _FakeGithubWebOAuthDataSource();
    store = TokenStore(_StubSecureStorage());
    repository = GithubAuthRepositoryImpl(
      GithubOAuthRemoteDataSource(Dio()),
      store,
      web: web,
      isWebOverride: true,
    );
  });

  test('signInWithWeb stores token and clears remember preference', () async {
    final result = await repository.signInWithWeb(rememberMe: true);

    expect(result.isRight(), isTrue);
    final success =
        result.getOrElse(() => const GithubWebSignInResult.redirecting());
    expect(success.redirectInProgress, isFalse);
    expect(success.accessToken, equals('token'));

    final payload = await store.readPayload();
    expect(payload, isNotNull);
    expect(payload!.token, equals('token'));
    expect(payload.rememberMe, isTrue);
    final pref = await store.readRememberPreference();
    expect(pref, isNull);
  });

  test('signInWithWeb returns redirect result when popup blocked', () async {
    web.signInValue = kGithubRedirectPendingToken;
    final result = await repository.signInWithWeb(rememberMe: false);

    expect(result.isRight(), isTrue);
    final success =
        result.getOrElse(() => const GithubWebSignInResult.redirecting());
    expect(success.redirectInProgress, isTrue);
    final payload = await store.readPayload();
    expect(payload, isNull);
    final pref = await store.readRememberPreference();
    expect(pref, isFalse);
  });

  test('completePendingWebSignIn persists redirect token and clears pref',
      () async {
    await store.cacheRememberPreference(true);
    web.redirectValue = 'redirect-token';

    final option = await repository.completePendingWebSignIn();

    expect(option.isSome(), isTrue);
    expect(option.getOrElse(() => ''), equals('redirect-token'));
    final payload = await store.readPayload();
    expect(payload, isNotNull);
    expect(payload!.token, equals('redirect-token'));
    expect(payload.rememberMe, isTrue);
    final pref = await store.readRememberPreference();
    expect(pref, isNull);
  });

  test('completePendingWebSignIn returns None when no redirect data', () async {
    final option = await repository.completePendingWebSignIn();

    expect(option, const None());
    final payload = await store.readPayload();
    expect(payload, isNull);
  });
}
