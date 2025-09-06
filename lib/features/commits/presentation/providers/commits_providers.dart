import 'package:devhub_gpt/features/commits/data/repositories/mock_commits_repository.dart';
import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/features/commits/domain/repositories/commits_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commitsRepositoryProvider = Provider<CommitsRepository>((ref) {
  return MockCommitsRepository();
});

final recentCommitsProvider = FutureProvider<List<CommitInfo>>((ref) async {
  final repo = ref.watch(commitsRepositoryProvider);
  return repo.listRecent();
});
