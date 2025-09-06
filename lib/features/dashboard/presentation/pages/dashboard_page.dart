import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    const titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              e.toString(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
          data: (user) {
            if (user == null) {
              return const Center(child: Text('No user data'));
            }
            return ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quick actions', style: titleStyle),
                        ElevatedButton.icon(
                          onPressed: () => ref
                              .read(authControllerProvider.notifier)
                              .signOut(),
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign out'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Block 3 shortcuts', style: titleStyle),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            OutlinedButton.icon(
                              key: const ValueKey('btnGithubRepos'),
                              onPressed: () => context.go('/github/repos'),
                              icon: const Icon(Icons.book_outlined),
                              label: const Text('GitHub Repos'),
                            ),
                            OutlinedButton.icon(
                              key: const ValueKey('btnNotes'),
                              onPressed: () => context.go('/notes'),
                              icon: const Icon(Icons.note_outlined),
                              label: const Text('Notes'),
                            ),
                            OutlinedButton.icon(
                              key: const ValueKey('btnCommits'),
                              onPressed: () => context.go('/commits'),
                              icon: const Icon(Icons.commit),
                              label: const Text('Commits'),
                            ),
                            OutlinedButton.icon(
                              key: const ValueKey('btnAssistant'),
                              onPressed: () => context.go('/assistant'),
                              icon: const Icon(Icons.smart_toy_outlined),
                              label: const Text('Assistant'),
                            ),
                            OutlinedButton.icon(
                              key: const ValueKey('btnSettings'),
                              onPressed: () => context.go('/settings'),
                              icon: const Icon(Icons.settings_outlined),
                              label: const Text('Settings'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Account info', style: titleStyle),
                        const SizedBox(height: 8),
                        _InfoRow(label: 'Name', value: user.name),
                        _InfoRow(label: 'Email', value: user.email),
                        _InfoRow(
                          label: 'Email verified',
                          value: user.isEmailVerified ? 'Yes' : 'No',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
