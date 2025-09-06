import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/domain/entities/pull_request.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_repository.dart';

class GithubRepositoryImpl implements GithubRepository {
  GithubRepositoryImpl();

  @override
  Future<Either<Failure, List<Repo>>> getUserRepos({
    int page = 1,
    String? query,
  }) async {
    // Placeholder mock data for MVP scaffolding
    final data = List.generate(
      5,
      (i) => Repo(
        id: i + (page - 1) * 5,
        name: 'repo_$i',
        fullName: 'user/repo_$i',
        language: i.isEven ? 'Dart' : 'TypeScript',
        stargazersCount: 10 * i,
        forksCount: 2 * i,
        description: 'Sample repository #$i',
      ),
    );
    return Right(data);
  }

  @override
  Future<Either<Failure, List<ActivityEvent>>> getRepoActivity(
    String owner,
    String repo,
  ) async {
    final now = DateTime.now();
    final events = [
      ActivityEvent(
        id: '1',
        type: 'PushEvent',
        repoFullName: '$owner/$repo',
        createdAt: now.subtract(const Duration(hours: 2)),
        summary: 'Pushed 3 commits to main',
      ),
      ActivityEvent(
        id: '2',
        type: 'PullRequestEvent',
        repoFullName: '$owner/$repo',
        createdAt: now.subtract(const Duration(days: 1)),
        summary: 'Opened PR #12',
      ),
    ];
    return Right(events);
  }

  @override
  Future<Either<Failure, List<PullRequest>>> listPullRequests(
    String owner,
    String repo, {
    String state = 'open',
  }) async {
    final prs = [
      PullRequest(
        id: 100,
        number: 12,
        title: 'Fix bug',
        state: state,
        author: 'alice',
      ),
      PullRequest(
        id: 101,
        number: 13,
        title: 'Add feature',
        state: state,
        author: 'bob',
      ),
    ];
    return Right(prs);
  }
}
