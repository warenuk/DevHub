import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/local/github_local_dao.dart';
import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/domain/entities/pull_request.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_repository.dart';
import 'package:devhub_gpt/shared/providers/database_provider.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GithubRepositoryImpl implements GithubRepository {
  GithubRepositoryImpl(
    this._ds,
    this._authHeaders, {
    GithubLocalDao? dao,
    Future<String> Function()? tokenScope,
  })  : _dao = dao,
        _tokenScope = tokenScope;

  final GithubRemoteDataSource _ds;
  final Future<Map<String, String>> Function() _authHeaders;
  final GithubLocalDao? _dao;
  final Future<String> Function()? _tokenScope;

  @override
  Future<Either<Failure, List<Repo>>> getUserRepos({
    int page = 1,
    String? query,
  }) async {
    try {
      final auth = await _authHeaders();
      if (auth.isEmpty) {
        return const Left(AuthFailure('GitHub token is missing'));
      }
      final models =
          await _ds.listUserRepos(auth: auth, page: page, query: query);
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
      final auth = await _authHeaders();
      if (auth.isEmpty) {
        return const Left(AuthFailure('GitHub token is missing'));
      }
      final models =
          await _ds.getRepoActivity(auth: auth, owner: owner, repo: repo);
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
      final auth = await _authHeaders();
      if (auth.isEmpty) {
        return const Left(AuthFailure('Unauthorized. Check GitHub token'));
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
}

final githubRepositoryImplProvider = Provider<GithubRepository>((ref) {
  final ds = ref.watch(githubRemoteDataSourceProvider);
  Future<Map<String, String>> headers() async =>
      await ref.read(githubAuthHeaderProvider.future);
  // Local cache wiring
  final db = ref.watch(databaseProvider);
  final dao = GithubLocalDao(db);
  Future<String> scope() async =>
      await ref.read(githubTokenScopeProvider.future);
  return GithubRepositoryImpl(ds, headers, dao: dao, tokenScope: scope);
});
