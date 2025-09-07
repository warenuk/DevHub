import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/models/repo_model.dart';
import 'package:devhub_gpt/features/github/data/repositories/github_repository_impl.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _DsOk extends GithubRemoteDataSource {
  _DsOk() : super(Dio());
  @override
  Future<List<RepoModel>> listUserRepos(
      {required Map<String, String> auth,
      int page = 1,
      int perPage = 20,
      String? query,}) async {
    return [
      RepoModel(
        id: 1,
        name: 'a',
        fullName: 'u/a',
        stargazersCount: 1,
        forksCount: 0,
      ),
    ];
  }
}

class _Ds401 extends GithubRemoteDataSource {
  _Ds401() : super(Dio());
  @override
  Future<List<RepoModel>> listUserRepos(
      {required Map<String, String> auth,
      int page = 1,
      int perPage = 20,
      String? query,}) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/user/repos'),
      response: Response(
        requestOptions: RequestOptions(path: '/user/repos'),
        statusCode: 401,
      ),
    );
  }
}

void main() {
  test('getUserRepos returns Right on success', () async {
    final repo = GithubRepositoryImpl(
      _DsOk(),
      () async => {'Authorization': 'Bearer x'},
    );
    final res = await repo.getUserRepos();
    expect(res, isA<Right<Failure, List<Repo>>>());
  });

  test('getUserRepos returns AuthFailure when no token', () async {
    final repo = GithubRepositoryImpl(
      _DsOk(),
      () async => <String, String>{},
    );
    final res = await repo.getUserRepos();
    expect(res.fold((l) => l, (r) => null), isA<AuthFailure>());
  });

  test('getUserRepos maps 401 to AuthFailure', () async {
    final repo = GithubRepositoryImpl(
      _Ds401(),
      () async => {'Authorization': 'Bearer x'},
    );
    final res = await repo.getUserRepos();
    expect(res.fold((l) => l, (r) => null), isA<AuthFailure>());
  });
}
