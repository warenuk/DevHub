import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/commits/presentation/providers/commits_providers.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/features/github/presentation/widgets/github_user_badge.dart';
import 'package:devhub_gpt/features/notes/presentation/providers/notes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final notesAsync = ref.watch(notesControllerProvider);
    final commitsAsync = ref.watch(recentCommitsProvider);
    final reposAsync = ref.watch(reposOverviewProvider);
    const titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: GithubUserBadge(),
          ),
        ],
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

            // Global loader: показуємо один лоадер, поки дашбордні дані підвантажуються
            final isLoading =
                notesAsync.isLoading || commitsAsync.isLoading || reposAsync.isLoading;
            if (isLoading) {
              return const _GlobalLoader();
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
                const SizedBox(height: 12),
                // Shortcuts first
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
                // Then account info
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
                const SizedBox(height: 12),
                // Then overview panels
                _OverviewRow(
                  notesAsync: notesAsync,
                  commitsAsync: commitsAsync,
                  reposAsync: reposAsync,
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

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({
    required this.notesAsync,
    required this.commitsAsync,
    required this.reposAsync,
  });

  final AsyncValue<List<dynamic>> notesAsync;
  final AsyncValue<List<dynamic>> commitsAsync;
  final AsyncValue<List<dynamic>> reposAsync;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final cardNotes = _MetricCard(
          title: 'Notes',
          icon: Icons.note_outlined,
          child: _NotesPanel(notesAsync: notesAsync),
        );
        final cardCommits = _MetricCard(
          title: 'Commits',
          icon: Icons.commit,
          child: _CommitsPanel(commitsAsync: commitsAsync),
        );
        final cardRepos = _MetricCard(
          title: 'GitHub Repos',
          icon: Icons.book_outlined,
          child: _ReposPanel(reposAsync: reposAsync),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cardNotes),
              const SizedBox(width: 12),
              Expanded(child: cardCommits),
              const SizedBox(width: 12),
              Expanded(child: cardRepos),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            cardNotes,
            const SizedBox(height: 12),
            cardCommits,
            const SizedBox(height: 12),
            cardRepos,
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 168), // ~+40% мінімальної висоти
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24), // трішки більший вертикальний паддінг
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    ),
    );
  }
}

class _NotesPanel extends StatelessWidget {
  const _NotesPanel({required this.notesAsync});
  final AsyncValue<List<dynamic>> notesAsync;

  @override
  Widget build(BuildContext context) {
    return notesAsync.when(
      loading: () => const _MiniLoader(),
      error: (e, _) =>
          Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
      data: (list) {
        final items = list.take(5).toList(); // було 3 → стало 5
        if (items.isEmpty) return const Text('No notes');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final n in items)
              Tooltip(
                message: 'Title: ${n.title}\nUpdated: ${n.updatedAt.toLocal()}\n\n${n.content}',
                waitDuration: const Duration(milliseconds: 200),
                child: InkWell(
                  onTap: () => context.go('/notes'),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '• ${n.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CommitsPanel extends StatelessWidget {
  const _CommitsPanel({required this.commitsAsync});
  final AsyncValue<List<dynamic>> commitsAsync;

  @override
  Widget build(BuildContext context) {
    return commitsAsync.when(
      loading: () => const _MiniLoader(),
      error: (e, _) =>
          Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
      data: (list) {
        final items = list.take(5).toList(); // було 3 → стало 5
        if (items.isEmpty) return const Text('No commits');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final c in items)
              Tooltip(
                message: (StringBuffer()
                    ..writeln(c.message)
                    ..writeln('Author: ${c.author}')
                    ..writeln('Date: ${c.date.toLocal()}')
                    ..writeln('SHA: ${c.id}')).toString(),
                waitDuration: const Duration(milliseconds: 200),
                child: InkWell(
                  onTap: () => context.go('/commits'),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '• ${c.message}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReposPanel extends StatelessWidget {
  const _ReposPanel({required this.reposAsync});
  final AsyncValue<List<dynamic>> reposAsync;

  @override
  Widget build(BuildContext context) {
    return reposAsync.when(
      loading: () => const _MiniLoader(),
      error: (e, _) =>
          Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
      data: (list) {
        final items = list.take(5).toList(); // було 3 → стало 5
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text('${list.length}')),
                const SizedBox(width: 8),
                const Text('repos'),
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('No repos')
            else
              ...items.map((r) => Tooltip(
                    message:
                        '${r.fullName}\n${r.description ?? ''}\nLang: ${r.language ?? '-'}   ⭐ ${r.stargazersCount}   Forks: ${r.forksCount}',
                    waitDuration: const Duration(milliseconds: 200),
                    child: InkWell(
                      onTap: () => context.go('/repos'),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '• ${r.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  )),
          ],
        );
      },
    );
  }
}

class _MiniLoader extends StatelessWidget {
  const _MiniLoader();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
}

class _GlobalLoader extends StatelessWidget {
  const _GlobalLoader();
  @override
  Widget build(BuildContext context) => const Center(
        child: SizedBox(
          height: 48,
          width: 48,
          child: CircularProgressIndicator(),
        ),
      );
}
