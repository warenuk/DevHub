import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RepositoriesPage extends ConsumerWidget {
  const RepositoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reposAsync = ref.watch(reposProvider);
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
      body: reposAsync.when(
        data: (repos) {
          if (repos.isEmpty) {
            return const Center(child: Text('No repositories'));
          }
          return Column(
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
                child: RefreshIndicator(
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
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
