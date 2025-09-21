import 'package:devhub_gpt/features/auth/presentation/pages/login_page.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_web_oauth_data_source.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_auth_notifier.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_token_store.dart';

class _SuccessGithubWebOAuthDataSource extends GithubWebOAuthDataSource {
  _SuccessGithubWebOAuthDataSource(this.token);
  final String token;
  int calls = 0;

  @override
  Future<String> signIn({List<String> scopes = const ['repo', 'read:user']}) async {
    calls++;
    return token;
  }
}

class _FailingGithubWebOAuthDataSource extends GithubWebOAuthDataSource {
  _FailingGithubWebOAuthDataSource(this.exception);
  final fb.FirebaseAuthException exception;
  int calls = 0;

  @override
  Future<String> signIn({List<String> scopes = const ['repo', 'read:user']}) async {
    calls++;
    throw exception;
  }
}

void main() {
  testWidgets(
    'tapping GitHub button stores token via web flow',
    (tester) async {
    final fakeStore = InMemoryTokenStore();
    final fakeWeb = _SuccessGithubWebOAuthDataSource('web-token');
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(fakeStore),
        githubWebOAuthDataSourceProvider.overrideWithValue(fakeWeb),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with GitHub'));
    await tester.pump();

    expect(fakeWeb.calls, 1);
    final stored = await fakeStore.read();
    expect(stored, 'web-token');
    expect(container.read(githubAuthNotifierProvider), isA<GithubAuthAuthorized>());
    },
    skip: !kIsWeb,
  );

  testWidgets(
    'GitHub popup failure surfaces error state',
    (tester) async {
    final fakeStore = InMemoryTokenStore();
    final fakeWeb = _FailingGithubWebOAuthDataSource(
      fb.FirebaseAuthException(
        code: 'popup-closed-by-user',
        message: 'Вікно авторизації було закрито. Спробуйте ще раз.',
      ),
    );
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(fakeStore),
        githubWebOAuthDataSourceProvider.overrideWithValue(fakeWeb),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with GitHub'));
    await tester.pump();

    expect(fakeWeb.calls, 1);
    final state = container.read(githubAuthNotifierProvider);
    expect(state, isA<GithubAuthError>());
    expect((state as GithubAuthError).message, contains('Вікно авторизації'));
    final stored = await fakeStore.read();
    expect(stored, isNull);
    },
    skip: !kIsWeb,
  );
}
