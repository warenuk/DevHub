import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/domain/entities/pull_request.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_repository.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepoFake implements GithubRepository {
  @override
  Future<Either<Failure, List<ActivityEvent>>> getRepoActivity(
          String owner, String repo) async =>
      Right(<ActivityEvent>[]);

  @override
  Future<Either<Failure, List<Repo>>> getUserRepos({
    int page = 1,
    String? query,
  }) async {
    final list = <Repo>[
      const Repo(
          id: 1, name: 'one', fullName: 'u/one', stargazersCount: 0, forksCount: 0),
      const Repo(
          id: 2, name: 'two', fullName: 'u/two', stargazersCount: 0, forksCount: 0),
    ];
    return Right(list);
  }

  @override
  Future<Either<Failure, List<PullRequest>>> listPullRequests(
          String owner, String repo,
          {String state = 'open'}) async =>
      Right(<PullRequest>[]);
}

void main() {
  test('reposProvider returns filtered repos by query', () async {
    final container = ProviderContainer(overrides: [
      githubRepositoryProvider.overrideWith((ref) => _RepoFake()),
    ]);
    addTearDown(container.dispose);

    // No query
    final list1 = await container.read(reposProvider.future);
    expect(list1.length, 2);

    // With query
    container.read(repoQueryProvider.notifier).state = 'two';
    final list2 = await container.read(reposProvider.future);
    expect(list2.length, 1);
    expect(list2.first.name, 'two');
  });
}
