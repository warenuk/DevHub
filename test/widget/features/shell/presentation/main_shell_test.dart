import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/features/shell/presentation/main_shell.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_until_stable.dart';

class _FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store[key];
  }

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
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }
}

class _FakeGithubSyncService extends GithubSyncService {
  _FakeGithubSyncService(super.ref);

  final List<String> calls = [];

  @override
  Future<void> syncRepos() async {
    calls.add('repos');
  }

  @override
  Future<void> syncRecentCommits() async {
    calls.add('commits');
  }

  @override
  Future<void> syncAll() async {
    calls.add('all');
  }
}

typedef _Harness = ({
  _FakeGithubSyncService sync,
  ProviderContainer container,
  _FakeSecureStorage storage,
});

Future<_Harness> _pumpShell(WidgetTester tester) async {
  final storage = _FakeSecureStorage();
  late _FakeGithubSyncService fakeSync;
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => MainShell(child: const SizedBox()),
      ),
    ],
  );

  addTearDown(router.dispose);

  final view = tester.view;
  view.physicalSize = const Size(1400, 900);
  view.devicePixelRatio = 1;

  addTearDown(() {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
        githubSyncServiceProvider.overrideWith((ref) {
          fakeSync = _FakeGithubSyncService(ref);
          return fakeSync;
        }),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );

  await pumpUntilStable(tester);

  final container = ProviderScope.containerOf(
    tester.element(find.byType(MainShell)),
  );

  return (sync: fakeSync, container: container, storage: storage);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('performs an eager sync when the shell is built', (tester) async {
    final harness = await _pumpShell(tester);

    expect(harness.sync.calls.where((c) => c == 'all').length, 1);
  });

  testWidgets('triggers sync when GitHub token changes', (tester) async {
    final harness = await _pumpShell(tester);

    expect(harness.sync.calls.where((c) => c == 'all').length, 1);

    await harness.storage.write(key: 'github_token', value: 'abc');
    harness.container.invalidate(githubTokenProvider);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(harness.sync.calls.where((c) => c == 'all').length, 2);

    // Re-invalidating without changing the token should not cause another sync.
    harness.container.invalidate(githubTokenProvider);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(harness.sync.calls.where((c) => c == 'all').length, 2);

    // Clearing the token should not trigger a sync either.
    await harness.storage.write(key: 'github_token', value: '');
    harness.container.invalidate(githubTokenProvider);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(harness.sync.calls.where((c) => c == 'all').length, 2);
  });

  testWidgets('triggers sync when the session version increments', (
    tester,
  ) async {
    final harness = await _pumpShell(tester);

    expect(harness.sync.calls.where((c) => c == 'all').length, 1);

    final notifier = harness.container.read(
      githubSessionVersionProvider.notifier,
    );
    notifier.state++;

    await tester.pump();

    expect(harness.sync.calls.where((c) => c == 'all').length, 2);
  });

  testWidgets('triggers sync when the app lifecycle resumes', (tester) async {
    final harness = await _pumpShell(tester);

    expect(harness.sync.calls.where((c) => c == 'all').length, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(harness.sync.calls.where((c) => c == 'all').length, 2);
  });
}
