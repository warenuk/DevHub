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
import 'package:integration_test/integration_test.dart';

import '../test/helpers/in_memory_token_store.dart';

class _IntegrationGithubWebOAuthDataSource extends GithubWebOAuthDataSource {
  _IntegrationGithubWebOAuthDataSource({this.token, this.throwable});
  final String? token;
  final fb.FirebaseAuthException? throwable;
  int calls = 0;

  @override
  Future<String> signIn({List<String> scopes = const ['repo', 'read:user']}) async {
    calls++;
    if (throwable != null) {
      throw throwable!;
    }
    if (token != null) {
      return token!;
    }
    return 'integration-token';
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('web GitHub sign-in updates session state', (tester) async {
    if (!kIsWeb) {
      return;
    }
    final store = InMemoryTokenStore();
    final webSource = _IntegrationGithubWebOAuthDataSource(token: 'integration-token');
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        githubWebOAuthDataSourceProvider.overrideWithValue(webSource),
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

    expect(webSource.calls, 1);
    expect(await store.read(), 'integration-token');
    expect(container.read(githubAuthNotifierProvider), isA<GithubAuthAuthorized>());
  });

  testWidgets('web GitHub sign-in surfaces popup errors', (tester) async {
    if (!kIsWeb) {
      return;
    }
    final store = InMemoryTokenStore();
    final webSource = _IntegrationGithubWebOAuthDataSource(
      throwable: fb.FirebaseAuthException(
        code: 'popup-closed-by-user',
        message: 'Вікно авторизації було закрито. Спробуйте ще раз.',
      ),
    );
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        githubWebOAuthDataSourceProvider.overrideWithValue(webSource),
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

    expect(webSource.calls, 1);
    final state = container.read(githubAuthNotifierProvider);
    expect(state, isA<GithubAuthError>());
    expect((state as GithubAuthError).message, contains('Вікно авторизації'));
    expect(await store.read(), isNull);
  });
}
