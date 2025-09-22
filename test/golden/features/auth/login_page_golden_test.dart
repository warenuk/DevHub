import 'dart:io';

import 'package:devhub_gpt/features/auth/presentation/pages/login_page.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_web_oauth_data_source.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_token_store.dart';
import '../../helpers/sha256_golden_comparator.dart';

class _NoopGithubWebOAuthDataSource extends GithubWebOAuthDataSource {
  const _NoopGithubWebOAuthDataSource();

  @override
  Future<String> signIn({
    List<String> scopes = const ['repo', 'read:user'],
  }) async {
    throw UnimplementedError('Golden test should not trigger GitHub sign-in');
  }
}

final Uri _goldenBaseUri = Directory('test/golden/features/auth/').uri;

void main() {
  const rootBoundaryKey = ValueKey('login-page-root');

  testWidgets('LoginPage golden - light theme', (tester) async {
    final previousComparator = goldenFileComparator;
    goldenFileComparator = Sha256GoldenComparator(_goldenBaseUri);
    addTearDown(() => goldenFileComparator = previousComparator);

    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      RepaintBoundary(
        key: rootBoundaryKey,
        child: ProviderScope(
          overrides: [
            tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
            githubWebOAuthDataSourceProvider
                .overrideWithValue(const _NoopGithubWebOAuthDataSource()),
          ],
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const LoginPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(rootBoundaryKey),
      matchesGoldenFile('goldens/login_page_light.sha256'),
    );
  });
}
