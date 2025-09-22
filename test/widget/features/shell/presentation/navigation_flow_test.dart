import 'package:devhub_gpt/core/router/app_routes.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/features/shell/presentation/main_shell.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/in_memory_token_store.dart';

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

class _FakeGithubSyncService extends GithubSyncService {
  _FakeGithubSyncService(super.ref);

  final List<String> calls = [];

  @override
  Future<void> syncRepos() async => calls.add('repos');

  @override
  Future<void> syncRecentCommits() async => calls.add('commits');

  @override
  Future<void> syncAll() async => calls.add('all');
}

class _FakeScreen extends StatelessWidget {
  const _FakeScreen(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        key: ValueKey('screen-$label'),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MainShell navigation', () {
    testWidgets('navigates between primary tabs via side navigation',
        (tester) async {
      final secureStorage = _FakeSecureStorage();
      final tokenStore = InMemoryTokenStore();
      await tokenStore.write('token', rememberMe: true);

      late _FakeGithubSyncService syncService;

      final router = GoRouter(
        initialLocation: DashboardRoute.path,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(
                path: DashboardRoute.path,
                builder: (context, state) => const _FakeScreen('Dashboard'),
              ),
              GoRoute(
                path: RepositoriesRoute.path,
                builder: (context, state) => const _FakeScreen('Repositories'),
              ),
              GoRoute(
                path: NotesRoute.path,
                builder: (context, state) => const _FakeScreen('Notes'),
              ),
              GoRoute(
                path: SettingsRoute.path,
                builder: (context, state) => const _FakeScreen('Settings'),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(secureStorage),
            tokenStoreProvider.overrideWithValue(tokenStore),
            githubSyncServiceProvider.overrideWith((ref) {
              syncService = _FakeGithubSyncService(ref);
              return syncService;
            }),
            githubTokenProvider.overrideWith((ref) async => 'token'),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('screen-Dashboard')), findsOneWidget);
      expect(syncService.calls.contains('all'), isTrue);

      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('screen-Repositories')), findsOneWidget);

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('screen-Notes')), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('screen-Settings')), findsOneWidget);
    });

    testWidgets('navigates to repository activity details route', (tester) async {
      final secureStorage = _FakeSecureStorage();
      final tokenStore = InMemoryTokenStore();
      await tokenStore.write('token', rememberMe: true);

      final router = GoRouter(
        initialLocation: DashboardRoute.path,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(
                path: DashboardRoute.path,
                builder: (context, state) => const _FakeScreen('Dashboard'),
              ),
              GoRoute(
                path: ActivityRoute.path,
                builder: (context, state) {
                  final owner = state.pathParameters['owner']!;
                  final repo = state.pathParameters['repo']!;
                  return _FakeScreen('Activity $owner/$repo');
                },
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(secureStorage),
            tokenStoreProvider.overrideWithValue(tokenStore),
            githubSyncServiceProvider.overrideWith((ref) {
              return _FakeGithubSyncService(ref);
            }),
            githubTokenProvider.overrideWith((ref) async => 'token'),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      final ctx = tester.element(find.byType(MainShell));
      const ActivityRoute(owner: 'acme', repo: 'devhub').go(ctx);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('screen-Activity acme/devhub')),
        findsOneWidget,
      );
    });
  });
}
