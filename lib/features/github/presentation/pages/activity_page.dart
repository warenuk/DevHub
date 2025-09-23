import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key, required this.owner, required this.repo});
  final String owner;
  final String repo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(activityProvider((owner: owner, name: repo)));
    final tokenAsync = ref.watch(githubTokenProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Activity: $owner/$repo')),
      body: eventsAsync.when(
        data: (events) {
          final token = tokenAsync.maybeWhen(
            data: (t) => t,
            orElse: () => null,
          );
          final hasToken = token != null && token.isNotEmpty;
          if (!hasToken && events.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_open, size: 40),
                    const SizedBox(height: 12),
                    const Text('Потрібен GitHub‑вхід для перегляду активності'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final n = ref.read(githubAuthNotifierProvider.notifier);
                        if (kIsWeb) {
                          n.signInWeb();
                        } else {
                          n.start();
                        }
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with GitHub'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (events.isEmpty) return const Center(child: Text('No activity'));
          return ListView.separated(
            itemCount: events.length,
            separatorBuilder: (context, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = events[i];
              return ListTile(
                title: Text(e.type),
                subtitle: Text(e.summary ?? '—'),
                trailing: Text(
                  TimeOfDay.fromDateTime(e.createdAt).format(context),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Завантаження активності…'),
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
                    const Text('Потрібен GitHub‑вхід для перегляду активності'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final n = ref.read(githubAuthNotifierProvider.notifier);
                        if (kIsWeb) {
                          n.signInWeb();
                        } else {
                          n.start();
                        }
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with GitHub'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(child: Text('Error: $e'));
        },
      ),
    );
  }
}
