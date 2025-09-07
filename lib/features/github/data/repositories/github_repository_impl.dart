import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/domain/entities/pull_request.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:devhub_gpt/features/github/data/datasources/github_remote_data_source.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';

class GithubRepositoryImpl implements GithubRepository {
  GithubRepositoryImpl(this._ds, this._authHeaders);

  final GithubRemoteDataSource _ds;
  final Future<Map<String, String>> Function() _authHeaders;

  @override
  Future<Either<Failure, List<Repo>>> getUserRepos({
    int page = 1,
    String? query,
  }) async {
    try {
      final auth = await _authHeaders();
      if (auth.isEmpty) {
        return Left(AuthFailure('GitHub token is missing'));
      }
      final models =
          await _ds.listUserRepos(auth: auth, page: page, query: query);
      return Right(models.map((e) => e.toDomain()).toList());
    } on DioException catch (e, s) {
      final code = e.response?.statusCode ?? 0;
      if (code == 401)
        return Left(const AuthFailure('Unauthorized. Check GitHub token'));
      if (code == 403)
        return Left(const RateLimitFailure('Rate limited by GitHub API'));
      AppLogger.error('getUserRepos dio failed',
          error: e, stackTrace: s, area: 'github');
      return Left(ServerFailure(e.message ?? 'Request failed'));
    } catch (e, s) {
      AppLogger.error('getUserRepos failed',
          error: e, stackTrace: s, area: 'github');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ActivityEvent>>> getRepoActivity(
    String owner,
    String repo,
  ) async {
    try {
      final auth = await _authHeaders();
      if (auth.isEmpty) {
        return Left(AuthFailure('GitHub token is missing'));
      }
      final models =
          await _ds.getRepoActivity(auth: auth, owner: owner, repo: repo);
      return Right(models.map((e) => e.toDomain()).toList());
    } on DioException catch (e, s) {
      final code = e.response?.statusCode ?? 0;
      if (code == 401)
        return Left(const AuthFailure('Unauthorized. Check GitHub token'));
      if (code == 403)
        return Left(const RateLimitFailure('Rate limited by GitHub API'));
      AppLogger.error('getRepoActivity dio failed',
          error: e, stackTrace: s, area: 'github');
      return Left(ServerFailure(e.message ?? 'Request failed'));
    } catch (e, s) {
      AppLogger.error('getRepoActivity failed',
          error: e, stackTrace: s, area: 'github');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PullRequest>>> listPullRequests(
    String owner,
    String repo, {
    String state = 'open',
  }) async {
    try {
      final auth = await _authHeaders();
      if (auth.isEmpty) {
        return Left(const AuthFailure('Unauthorized. Check GitHub token'));
      }
      final models = await _ds.listPullRequests(
        auth: auth,
        owner: owner,
        repo: repo,
        state: state,
      );
      return Right(models.map((m) => m.toDomain()).toList());
    } on DioException catch (e, s) {
      final code = e.response?.statusCode ?? 0;
      if (code == 401)
        return Left(const AuthFailure('Unauthorized. Check GitHub token'));
      if (code == 403)
        return Left(const RateLimitFailure('Rate limited by GitHub API'));
      AppLogger.error('listPullRequests dio failed',
          error: e, stackTrace: s, area: 'github');
      return Left(ServerFailure(e.message ?? 'Request failed'));
    } catch (e, s) {
      AppLogger.error('listPullRequests failed',
          error: e, stackTrace: s, area: 'github');
      return Left(ServerFailure(e.toString()));
    }
  }
}

final githubRepositoryImplProvider = Provider<GithubRepository>((ref) {
  final ds = ref.watch(githubRemoteDataSourceProvider);
  Future<Map<String, String>> headers() async =>
      await ref.read(githubAuthHeaderProvider.future);
  return GithubRepositoryImpl(ds, headers);
});
