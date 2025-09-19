import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:devhub_gpt/features/shell/presentation/widgets/app_side_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  late final ProviderSubscription<AsyncValue<String?>> _tokenSub;
  late final ProviderSubscription<int> _sessionSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tokenSub = ref.listenManual<AsyncValue<String?>>(
      githubTokenProvider,
      (previous, next) {
        final newToken = next.value;
        final prevToken = previous?.value;
        if (newToken == null || newToken.isEmpty) return;
        if (newToken == prevToken) return;
        // ignore: discarded_futures
        ref.read(githubSyncServiceProvider).syncAll();
      },
    );
    _sessionSub = ref.listenManual<int>(
      githubSessionVersionProvider,
      (previous, next) {
        if (previous == next) return;
        // ignore: discarded_futures
        ref.read(githubSyncServiceProvider).syncAll();
      },
    );
    // Перший тихий синк при побудові оболонки (після логіну/редіректу).
    // Лише умовні запити (ETag), тому без підвисань.
    // ignore: discarded_futures
    ref.read(githubSyncServiceProvider).syncAll();
  }

  @override
  void dispose() {
    _tokenSub.close();
    _sessionSub.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Повернулися у фокус — тихий рефреш даних.
      // ignore: discarded_futures
      ref.read(githubSyncServiceProvider).syncAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DevHub')),
      body: Row(
        children: [
          const SizedBox(width: 4),
          const AppSideNav(),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
