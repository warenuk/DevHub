import 'package:devhub_gpt/features/commits/data/repositories/github_commits_repository.dart';
import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/features/commits/domain/repositories/commits_repository.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commitsRepositoryProvider = Provider<CommitsRepository>((ref) {
  return ref.watch(githubCommitsRepositoryProvider);
});

final recentCommitsProvider = FutureProvider<List<CommitInfo>>((ref) async {
  // Re-run when session version changes (e.g., token updated)
  ref.watch(githubSessionVersionProvider);
  // Also react to token changes directly so first load after OAuth works.
  await ref.watch(githubTokenProvider.future);

  final repo = ref.watch(commitsRepositoryProvider);
  return repo.listRecent();
});
