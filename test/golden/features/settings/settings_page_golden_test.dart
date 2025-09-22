import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart' as auth;
import 'package:devhub_gpt/features/auth/domain/repositories/auth_repository.dart';
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/github/domain/entities/oauth.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_auth_repository.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_auth_notifier.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/features/settings/presentation/pages/settings_page.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_token_store.dart';
import '../../helpers/sha256_golden_comparator.dart';

class _FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _storage[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
    }
  }
}

class _FakeGithubAuthRepository implements GithubAuthRepository {
  String? _token;

  @override
  Future<Either<Failure, GithubDeviceCode>> startDeviceFlow({
    required String clientId,
    String scope = 'repo read:user',
  }) async {
    return const Right<Failure, GithubDeviceCode>(
       GithubDeviceCode(
        deviceCode: 'device',
        userCode: 'user',
        verificationUri: 'https://github.dev/code',
        expiresIn: 900,
        interval: 5,
      ),
    );
  }

  @override
  Future<Either<Failure, GithubAuthToken>> pollForToken({
    required String clientId,
    required String deviceCode,
    int interval = 5,
  }) async {
    const token = 'gho_example';
    _token = token;
    return const Right<Failure, GithubAuthToken>(
       GithubAuthToken(
        accessToken: token,
        tokenType: 'bearer',
        scope: 'repo',
      ),
    );
  }

  @override
  Future<void> saveToken(
    String token, {
    required bool rememberMe,
    Duration? ttl,
  }) async {
    _token = token;
  }

  @override
  Future<void> deleteToken() async {
    _token = null;
  }

  @override
  Future<Either<Failure, String>> signInWithWeb({
    List<String> scopes = const ['repo', 'read:user'],
    required bool rememberMe,
    Duration? ttl,
  }) async => const Right('gho_example');

  @override
  Future<String?> readToken() async => _token;
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, auth.User>> signInWithEmail(
    String email,
    String password,
  ) async => const Left(ServerFailure('unused'));

  @override
  Future<Either<Failure, auth.User>> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async => const Left(ServerFailure('unused'));

  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);

  @override
  Stream<auth.User?> watchAuthState() => const Stream.empty();

  @override
  Future<Either<Failure, void>> resetPassword(String email) async =>
      const Right(null);

  @override
  Future<Either<Failure, auth.User>> updateProfile(
    Map<String, dynamic> data,
  ) async => const Left(ServerFailure('unused'));

  @override
  Future<Either<Failure, auth.User?>> getCurrentUser() async =>
      const Right(null);
}

final Uri _baseUri = Directory('test/golden/features/settings/').uri;

void main() {
  testWidgets('SettingsPage golden - configured account', (tester) async {
    final previousComparator = goldenFileComparator;
    goldenFileComparator = Sha256GoldenComparator(_baseUri);
    addTearDown(() => goldenFileComparator = previousComparator);

    tester.view.physicalSize = const Size(1024, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final secureStorage = _FakeSecureStorage();
    await secureStorage.write(key: 'ai_key', value: 'sk-live-123');

    final tokenStore = InMemoryTokenStore();
    await tokenStore.write('gho_example', rememberMe: true);

    const rootKey = ValueKey('settings-golden-root');

    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(secureStorage),
            tokenStoreProvider.overrideWithValue(tokenStore),
            githubAuthRepositoryProvider.overrideWith((ref) => _FakeGithubAuthRepository()),
            authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
            githubRememberSessionProvider.overrideWith((ref) => true),
          ],
          child: const MaterialApp(home: SettingsPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(rootKey),
      matchesGoldenFile('goldens/settings_page_desktop.sha256'),
    );
  });
}
