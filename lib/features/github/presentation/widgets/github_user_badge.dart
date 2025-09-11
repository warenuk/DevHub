import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GithubUserBadge extends ConsumerWidget {
  const GithubUserBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentGithubUserProvider);
    final baseSize = Theme.of(context).textTheme.labelLarge?.fontSize ?? 14;

    return userAsync.when(
      data: (u) {
        if (u == null) return const SizedBox.shrink();
        return Column(
          key: const ValueKey('githubUserBadge'),
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18, // було 14 — зробили трохи більшим
              backgroundImage: NetworkImage(u.avatarUrl),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 6),
            Text(
              u.login, // саме нік (login)
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontSize: baseSize + 2), // трохи більший шрифт
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 32,
        width: 32,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}