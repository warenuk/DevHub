import 'package:devhub_gpt/core/router/app_routes.dart';
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/dashboard/presentation/widgets/commit_line_chart.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/features/github/presentation/widgets/github_user_badge.dart';
import 'package:devhub_gpt/features/notes/presentation/providers/notes_providers.dart';
import 'package:devhub_gpt/shared/widgets/app_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final authStream = ref.watch(authStateProvider);
    final notesAsync = ref.watch(notesControllerProvider);
    final commitsAsync = ref.watch(recentCommitsCacheProvider);
    final reposAsync = ref.watch(reposCacheProvider);
    const titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: const Text('Dashboard'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: GithubUserBadge(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: userAsync.when(
          loading: () {
            final unauth = authStream.maybeWhen(
              data: (u) => u == null,
              orElse: () => false,
            );
            if (unauth) return const _AuthCta();
            return const Center(child: AppProgressIndicator(size: 32));
          },
          error: (e, _) => Center(
            child: Text(
              e.toString(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
          data: (user) {
            if (user == null) {
              return const _AuthCta();
            }

            // Глобальний лоадер тільки якщо немає кешу взагалі.
            final stillLoading = notesAsync.isLoading ||
                commitsAsync.isLoading ||
                reposAsync.isLoading;

            return ListView(
              children: [
                if (stillLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Оновлюємо дані…'),
                  ),
                // Move the commit activity chart to the top area of the dashboard
                const CommitActivityCard(),
                const SizedBox(height: 12),
                // Shortcuts
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
                              onPressed: () =>
                                  const RepositoriesRoute().go(context),
                              icon: const Icon(Icons.book_outlined),
                              label: const Text('GitHub Repos'),
                            ),
                            OutlinedButton.icon(
                              key: const ValueKey('btnNotes'),
                              onPressed: () => const NotesRoute().go(context),
                              icon: const Icon(Icons.note_outlined),
                              label: const Text('Notes'),
                            ),
                            OutlinedButton.icon(
                              key: const ValueKey('btnCommits'),
                              onPressed: () => const CommitsRoute().go(context),
                              icon: const Icon(Icons.commit),
                              label: const Text('Commits'),
                            ),
                            OutlinedButton.icon(
                              key: const ValueKey('btnAssistant'),
                              onPressed: () =>
                                  const AssistantRoute().go(context),
                              icon: const Icon(Icons.smart_toy_outlined),
                              label: const Text('Assistant'),
                            ),
                            OutlinedButton.icon(
                              key: const ValueKey('btnSettings'),
                              onPressed: () =>
                                  const SettingsRoute().go(context),
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
        constraints:
            const BoxConstraints(minHeight: 168), // ~+40% мінімальної висоти
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            24,
            16,
            24,
          ), // трішки більший вертикальний паддінг
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
                message:
                    'Title: ${n.title}\nUpdated: ${n.updatedAt.toLocal()}\n\n${n.content}',
                waitDuration: const Duration(milliseconds: 200),
                child: InkWell(
                  onTap: () => const NotesRoute().go(context),
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
                      ..writeln('SHA: ${c.id}'))
                    .toString(),
                waitDuration: const Duration(milliseconds: 200),
                child: InkWell(
                  onTap: () => const CommitsRoute().go(context),
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
              ...items.map(
                (r) => Tooltip(
                  message:
                      '${r.fullName}\n${r.description ?? ''}\nLang: ${r.language ?? '-'}   ⭐ ${r.stargazersCount}   Forks: ${r.forksCount}',
                  waitDuration: const Duration(milliseconds: 200),
                  child: InkWell(
                    onTap: () => const RepositoriesRoute().go(context),
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
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MiniLoader extends StatelessWidget {
  const _MiniLoader();
  @override
  Widget build(BuildContext context) =>
      const AppProgressIndicator(strokeWidth: 2, size: 24);
}

class _AuthCta extends StatelessWidget {
  const _AuthCta();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Увійдіть в акаунт, щоб побачити дашборд',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => const LoginRoute().go(context),
              icon: const Icon(Icons.login),
              label: const Text('Sign in'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => const RegisterRoute().go(context),
              child: const Text('Створити акаунт'),
            ),
          ],
        ),
      ),
    );
  }
}
