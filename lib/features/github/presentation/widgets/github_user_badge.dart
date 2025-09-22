import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/widgets/app_progress_indicator.dart';
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
        return Row(
          key: const ValueKey('githubUserBadge'),
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(u.avatarUrl),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                u.login,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontSize: baseSize + 2),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 32,
        width: 32,
        child: AppProgressIndicator(
          strokeWidth: 2,
          size: 20,
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
