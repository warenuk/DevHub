import 'package:devhub_gpt/features/commits/presentation/providers/commits_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommitsPage extends ConsumerWidget {
  const CommitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recentCommitsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Recent Commits')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
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
