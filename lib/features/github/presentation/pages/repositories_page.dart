import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RepositoriesPage extends ConsumerWidget {
  const RepositoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reposAsync = ref.watch(reposProvider);
    final tokenAsync = ref.watch(githubTokenProvider);
    final queryCtrl = TextEditingController(text: ref.watch(repoQueryProvider));
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Repositories'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(reposProvider.future),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: queryCtrl,
              decoration: const InputDecoration(
                hintText: 'Filter by name…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) =>
                  ref.read(repoQueryProvider.notifier).state = v.trim(),
            ),
          ),
          Expanded(
            child: reposAsync.when(
              data: (repos) {
                final token =
                    tokenAsync.maybeWhen(data: (t) => t, orElse: () => null);
                if ((token == null || token.isEmpty)) {
                  return _GithubCta(
                    onConnect: () {
                      final n = ref.read(githubAuthNotifierProvider.notifier);
                      if (kIsWeb) {
                        n.signInWeb();
                      } else {
                        n.start();
                      }
                    },
                  );
                }
                if (repos.isEmpty) {
                  return const Center(child: Text('No repositories'));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(reposProvider.future),
                  child: ListView.separated(
                    itemCount: repos.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final r = repos[index];
                      return ListTile(
                        title: Text(r.fullName),
                        subtitle: Text(r.description ?? '—'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 16),
                            const SizedBox(width: 4),
                            Text('${r.stargazersCount}'),
                            const SizedBox(width: 12),
                            const Icon(Icons.call_split, size: 16),
                            const SizedBox(width: 4),
                            Text('${r.forksCount}'),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) {
                final msg = e.toString();
                if (msg.contains('Unauthorized')) {
                  return _GithubCta(
                    onConnect: () {
                      final n = ref.read(githubAuthNotifierProvider.notifier);
                      if (kIsWeb) {
                        n.signInWeb();
                      } else {
                        n.start();
                      }
                    },
                  );
                }
                return Center(child: Text('Error: $e'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GithubCta extends StatelessWidget {
  const _GithubCta({required this.onConnect});
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_open, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Підключіть GitHub, щоб побачити репозиторії',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onConnect,
              icon: const Icon(Icons.login),
              label: const Text('Sign in with GitHub'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/settings'),
              child: const Text('Ввести токен у Налаштуваннях'),
            ),
          ],
        ),
      ),
    );
  }
}
