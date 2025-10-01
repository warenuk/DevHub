import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/models/repo_model.dart';
import 'package:devhub_gpt/features/github/data/repositories/github_repository_impl.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGithubRemoteDataSource extends Mock
    implements GithubRemoteDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      RepoModel(
        id: 1,
        name: 'fallback',
        fullName: 'owner/fallback',
        stargazersCount: 0,
        forksCount: 0,
      ),
    );
  });

  test('getUserRepos returns Right on success', () async {
    final ds = _MockGithubRemoteDataSource();
    when(() => ds.listUserRepos(
            page: any(named: 'page'), query: any(named: 'query')))
        .thenAnswer((_) async => [
              RepoModel(
                id: 1,
                name: 'a',
                fullName: 'u/a',
                stargazersCount: 1,
                forksCount: 0,
              ),
            ]);
    final repo = GithubRepositoryImpl(ds);
    final res = await repo.getUserRepos();
    expect(res, isA<Right<Failure, List<Repo>>>());
  });

  test('getUserRepos maps 401 to AuthFailure', () async {
    final ds = _MockGithubRemoteDataSource();
    when(() => ds.listUserRepos(
        page: any(named: 'page'), query: any(named: 'query'))).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/user/repos'),
        response: Response(
          requestOptions: RequestOptions(path: '/user/repos'),
          statusCode: 401,
        ),
      ),
    );
    final repo = GithubRepositoryImpl(ds);
    final res = await repo.getUserRepos();
    expect(res.fold((l) => l, (r) => null), isA<AuthFailure>());
  });
}
