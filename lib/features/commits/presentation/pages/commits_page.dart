import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart'
    show kUseFirebase;
import 'package:devhub_gpt/features/commits/presentation/providers/commits_providers.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommitsPage extends ConsumerWidget {
  const CommitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recentCommitsProvider);
    final tokenAsync = ref.watch(githubTokenProvider);
    final rememberSession = ref.watch(githubRememberSessionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Recent Commits')),
      body: async.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Завантаження комітів…'),
          ),
        ),
        error: (e, _) {
          final msg = e.toString();
          if (msg.contains('Unauthorized')) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_open, size: 40),
                    const SizedBox(height: 12),
                    const Text('Потрібен GitHub‑вхід для перегляду комітів'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final n = ref.read(githubAuthNotifierProvider.notifier);
                        if (kIsWeb && kUseFirebase) {
                          n.signInWeb();
                        } else {
                          n.start();
                        }
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with GitHub'),
                    ),
                    if (kIsWeb)
                      SwitchListTile.adaptive(
                        value: rememberSession,
                        onChanged: (value) => ref
                            .read(githubRememberSessionProvider.notifier)
                            .state = value,
                        title: const Text('Пам’ятати GitHub сеанс'),
                        subtitle: const Text(
                          'Сеанс зберігається до 7 днів.',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            );
          }
          return Center(child: Text('Error: $e'));
        },
        data: (list) {
          final token = tokenAsync.maybeWhen(
            data: (t) => t,
            orElse: () => null,
          );
          final hasToken = token != null && token.isNotEmpty;
          if (!hasToken && list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_open, size: 40),
                    const SizedBox(height: 12),
                    const Text('Підключіть GitHub, щоб бачити коміти'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final n = ref.read(githubAuthNotifierProvider.notifier);
                        if (kIsWeb && kUseFirebase) {
                          n.signInWeb();
                        } else {
                          n.start();
                        }
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with GitHub'),
                    ),
                    if (kIsWeb)
                      SwitchListTile.adaptive(
                        value: rememberSession,
                        onChanged: (value) => ref
                            .read(githubRememberSessionProvider.notifier)
                            .state = value,
                        title: const Text('Пам’ятати GitHub сеанс'),
                        subtitle: const Text(
                          'Сеанс зберігається до 7 днів.',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            );
          }
          if (list.isEmpty) return const Center(child: Text('No commits yet'));
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = list[i];
              return ListTile(
                title: Text(c.message),
                subtitle: Text('${c.author} • ${c.date.toLocal()}'),
              );
            },
          );
        },
      ),
    );
  }
}
