import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/models/activity_event_model.dart';
import 'package:devhub_gpt/features/github/data/models/pull_request_model.dart';
import 'package:devhub_gpt/features/github/data/models/repo_model.dart';
import 'package:devhub_gpt/features/github/data/repositories/github_repository_impl.dart';
import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _DsReposOk extends GithubRemoteDataSource {
  _DsReposOk() : super(Dio());
  @override
  Future<List<RepoModel>> listUserRepos({
    int page = 1,
    int perPage = 20,
    String? query,
  }) async {
    return [
      const RepoModel(
        id: 1,
        name: 'a',
        fullName: 'u/a',
        stargazersCount: 1,
        forksCount: 0,
      ),
    ];
  }
}

class _DsRepos401 extends GithubRemoteDataSource {
  _DsRepos401() : super(Dio());
  @override
  Future<List<RepoModel>> listUserRepos({
    int page = 1,
    int perPage = 20,
    String? query,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/user/repos'),
      response: Response(
        requestOptions: RequestOptions(path: '/user/repos'),
        statusCode: 401,
      ),
    );
  }
}

class _DsActivityOk extends GithubRemoteDataSource {
  _DsActivityOk() : super(Dio());
  @override
  Future<List<ActivityEventModel>> getRepoActivity({
    required String owner,
    required String repo,
  }) async {
    return [
      ActivityEventModel(
        id: '1',
        type: 'PushEvent',
        repoFullName: '$owner/$repo',
        createdAt: DateTime(2024, 5, 12),
        summary: 'push',
      ),
    ];
  }
}

class _DsActivity403 extends GithubRemoteDataSource {
  _DsActivity403() : super(Dio());
  @override
  Future<List<ActivityEventModel>> getRepoActivity({
    required String owner,
    required String repo,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/repos/$owner/$repo/events'),
      response: Response(
        requestOptions: RequestOptions(path: '/repos/$owner/$repo/events'),
        statusCode: 403,
      ),
    );
  }
}

class _DsPr403 extends GithubRemoteDataSource {
  _DsPr403() : super(Dio());
  @override
  Future<List<PullRequestModel>> listPullRequests({
    required String owner,
    required String repo,
    String state = 'open',
    int perPage = 20,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/repos/$owner/$repo/pulls'),
      response: Response(
        requestOptions: RequestOptions(path: '/repos/$owner/$repo/pulls'),
        statusCode: 403,
      ),
    );
  }
}

void main() {
  test('getUserRepos returns Right on success', () async {
    final repo = GithubRepositoryImpl(
      _DsReposOk(),
    );
    final res = await repo.getUserRepos();
    expect(res, isA<Right<Failure, List<Repo>>>());
  });

  test('getUserRepos maps 401 to AuthFailure', () async {
    final repo = GithubRepositoryImpl(
      _DsRepos401(),
    );
    final res = await repo.getUserRepos();
    expect(res.fold((l) => l, (r) => null), isA<AuthFailure>());
  });

  test('getRepoActivity returns activity events on success', () async {
    final repo = GithubRepositoryImpl(_DsActivityOk());
    final res = await repo.getRepoActivity('acme', 'devhub');
    expect(res, isA<Right<Failure, List<ActivityEvent>>>());
  });

  test('getRepoActivity maps 403 to RateLimitFailure', () async {
    final repo = GithubRepositoryImpl(_DsActivity403());
    final res = await repo.getRepoActivity('acme', 'devhub');
    expect(res.fold((l) => l, (r) => null), isA<RateLimitFailure>());
  });

  test('listPullRequests maps 403 to RateLimitFailure', () async {
    final repo = GithubRepositoryImpl(_DsPr403());
    final res = await repo.listPullRequests('acme', 'devhub');
    expect(res.fold((l) => l, (r) => null), isA<RateLimitFailure>());
  });
}
