import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/domain/entities/pull_request.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart';

abstract class GithubRepository {
  Future<Either<Failure, List<Repo>>> getUserRepos({
    int page = 1,
    String? query,
  });
  Future<Either<Failure, List<ActivityEvent>>> getRepoActivity(
    String owner,
    String repo,
  );
  Future<Either<Failure, List<PullRequest>>> listPullRequests(
    String owner,
    String repo, {
    String state = 'open',
  });
}
