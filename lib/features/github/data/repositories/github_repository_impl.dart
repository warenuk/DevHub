import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/local/github_local_dao.dart';
import 'package:devhub_gpt/features/github/data/models/activity_event_model.dart';
import 'package:devhub_gpt/features/github/data/models/github_user_model.dart';
import 'package:devhub_gpt/features/github/data/models/pull_request_model.dart';
import 'package:devhub_gpt/features/github/data/models/repo_model.dart';
import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/domain/entities/github_user.dart';
import 'package:devhub_gpt/features/github/domain/entities/pull_request.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_repository.dart';
import 'package:devhub_gpt/shared/providers/database_provider.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GithubRepositoryImpl implements GithubRepository {
  GithubRepositoryImpl(
    this._ds, {
    GithubLocalDao? dao,
    Future<String> Function()? tokenScope,
  })  : _dao = dao,
        _tokenScope = tokenScope;

  final GithubRemoteDataSource _ds;
  final GithubLocalDao? _dao;
  final Future<String> Function()? _tokenScope;

  @override
  Future<Either<Failure, List<Repo>>> getUserRepos({
    int page = 1,
    String? query,
  }) async {
    try {
      final models = await _ds.listUserRepos(page: page, query: query);
      final list = models.map((e) => e.toDomain()).toList();
      // Upsert into local DB if available
      if (_dao != null && _tokenScope != null) {
        final scope = await _tokenScope();
        await _dao.upsertRepos(scope, list);
      }
      return Right(list);
    } on DioException catch (e, s) {
      final code = e.response?.statusCode ?? 0;
      if (code == 401) {
        return const Left(AuthFailure('Unauthorized. Check GitHub token'));
      }
      if (code == 403) {
        return const Left(RateLimitFailure('Rate limited by GitHub API'));
      }
      AppLogger.error(
        'getUserRepos dio failed',
        error: e,
        stackTrace: s,
        area: 'github',
      );
      // Fallback to cache
      if (_dao != null && _tokenScope != null) {
        final scope = await _tokenScope();
        final cached = await _dao.listRepos(scope, query: query);
        if (cached.isNotEmpty) return Right(cached);
      }
      return Left(ServerFailure(e.message ?? 'Request failed'));
    } catch (e, s) {
      AppLogger.error(
        'getUserRepos failed',
        error: e,
        stackTrace: s,
        area: 'github',
      );
      // Fallback to cache
      if (_dao != null && _tokenScope != null) {
        final scope = await _tokenScope();
        final cached = await _dao.listRepos(scope, query: query);
        if (cached.isNotEmpty) return Right(cached);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ActivityEvent>>> getRepoActivity(
    String owner,
    String repo,
  ) async {
    try {
      final models = await _ds.getRepoActivity(owner: owner, repo: repo);
      final list = models.map((e) => e.toDomain()).toList();
      if (_dao != null && _tokenScope != null) {
        final scope = await _tokenScope();
        final repoFullName = '$owner/$repo';
        await _dao.insertActivity(scope, repoFullName, list);
      }
      return Right(list);
    } on DioException catch (e, s) {
      final code = e.response?.statusCode ?? 0;
      if (code == 401) {
        return const Left(AuthFailure('Unauthorized. Check GitHub token'));
      }
      if (code == 403) {
        return const Left(RateLimitFailure('Rate limited by GitHub API'));
      }
      AppLogger.error(
        'getRepoActivity dio failed',
        error: e,
        stackTrace: s,
        area: 'github',
      );
      if (_dao != null && _tokenScope != null) {
        final scope = await _tokenScope();
        final repoFullName = '$owner/$repo';
        final cached = await _dao.listActivity(scope, repoFullName);
        if (cached.isNotEmpty) return Right(cached);
      }
      return Left(ServerFailure(e.message ?? 'Request failed'));
    } catch (e, s) {
      AppLogger.error(
        'getRepoActivity failed',
        error: e,
        stackTrace: s,
        area: 'github',
      );
      if (_dao != null && _tokenScope != null) {
        final scope = await _tokenScope();
        final repoFullName = '$owner/$repo';
        final cached = await _dao.listActivity(scope, repoFullName);
        if (cached.isNotEmpty) return Right(cached);
      }
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
      final models = await _ds.listPullRequests(
        owner: owner,
        repo: repo,
        state: state,
      );
      return Right(models.map((m) => m.toDomain()).toList());
    } on DioException catch (e, s) {
      final code = e.response?.statusCode ?? 0;
      if (code == 401) {
        return const Left(AuthFailure('Unauthorized. Check GitHub token'));
      }
      if (code == 403) {
        return const Left(RateLimitFailure('Rate limited by GitHub API'));
      }
      AppLogger.error(
        'listPullRequests dio failed',
        error: e,
        stackTrace: s,
        area: 'github',
      );
      return Left(ServerFailure(e.message ?? 'Request failed'));
    } catch (e, s) {
      AppLogger.error(
        'listPullRequests failed',
        error: e,
        stackTrace: s,
        area: 'github',
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GithubUser>> getCurrentUser() async {
    try {
      final json = await _ds.getCurrentUser();
      final user = GithubUserModel.fromJson(json).toDomain();
      return Right(user);
    } on DioException catch (e) {
      AppLogger.error(
        'getCurrentUser DioException: ${e.message}',
        area: 'github',
      );
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      AppLogger.error('getCurrentUser error: $e', area: 'github');
      return Left(ServerFailure(e.toString()));
    }
  }
}

final githubRepositoryImplProvider = Provider<GithubRepository>((ref) {
  final ds = ref.watch(githubRemoteDataSourceProvider);
  final db = ref.watch(databaseProvider);
  final dao = GithubLocalDao(db);
  Future<String> scope() async =>
      await ref.read(githubTokenScopeProvider.future);
  return GithubRepositoryImpl(ds, dao: dao, tokenScope: scope);
});
