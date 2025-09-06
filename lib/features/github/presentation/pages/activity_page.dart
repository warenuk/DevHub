import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key, required this.owner, required this.repo});
  final String owner;
  final String repo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(activityProvider((owner: owner, name: repo)));
    return Scaffold(
      appBar: AppBar(title: Text('Activity: $owner/$repo')),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) return const Center(child: Text('No activity'));
          return ListView.separated(
            itemCount: events.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = events[i];
              return ListTile(
                title: Text(e.type),
                subtitle: Text(e.summary ?? '—'),
                trailing:
                    Text(TimeOfDay.fromDateTime(e.createdAt).format(context)),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
