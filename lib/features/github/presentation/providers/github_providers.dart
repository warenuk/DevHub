import 'package:devhub_gpt/features/github/data/repositories/github_repository_impl.dart';
import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final githubRepositoryProvider = Provider<GithubRepository>((ref) {
  return GithubRepositoryImpl();
});

final reposProvider = FutureProvider.autoDispose<List<Repo>>((ref) async {
  final repo = ref.watch(githubRepositoryProvider);
  final result = await repo.getUserRepos();
  return result.fold((l) => <Repo>[], (r) => r);
});

final activityProvider = FutureProvider.autoDispose
    .family<List<ActivityEvent>, ({String owner, String name})>(
        (ref, params) async {
  final repo = ref.watch(githubRepositoryProvider);
  final result = await repo.getRepoActivity(params.owner, params.name);
  return result.fold((l) => <ActivityEvent>[], (r) => r);
});
