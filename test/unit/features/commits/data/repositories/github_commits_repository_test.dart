import 'dart:io';
import 'package:devhub_gpt/core/db/app_database.dart';
import 'package:devhub_gpt/features/commits/data/models/commit_model.dart' as m;
import 'package:devhub_gpt/features/commits/data/repositories/github_commits_repository.dart';
import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/local/github_local_dao.dart';
import 'package:devhub_gpt/features/github/data/models/repo_model.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart' as domain;
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _DsOk extends GithubRemoteDataSource {
  _DsOk() : super(Dio());
  @override
  Future<List<RepoModel>> listUserRepos({
    int page = 1,
    int perPage = 20,
    String? query,
  }) async {
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

  @override
  Future<List<m.CommitModel>> listRepoCommits({
    required String owner,
    required String repo,
    int perPage = 20,
  }) async {
    return [
      m.CommitModel(
        id: 'c1',
        message: 'msg1',
        author: 'a1',
        date: DateTime(2024, 1, 1),
      ),
      m.CommitModel(
        id: 'c2',
        message: 'msg2',
        author: 'a2',
        date: DateTime(2024, 1, 2),
      ),
    ];
  }
}

class _DsFail extends GithubRemoteDataSource {
  _DsFail() : super(Dio());
  @override
  Future<List<RepoModel>> listUserRepos({
    int page = 1,
    int perPage = 20,
    String? query,
  }) async {
    throw DioException(requestOptions: RequestOptions(path: '/user/repos'));
  }
}

void main() {
  test('listRecent caches commits on success', () async {
    if (Platform.isWindows) {
      return; // sqlite3.dll not available in VM unit tests
    }
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final dao = GithubLocalDao(db);
    final repo = GithubCommitsRepository(
      _DsOk(),
      () async => {'Authorization': 'Bearer x'},
      dao: dao,
      tokenScope: () async => 'scope1',
    );

    final res = await repo.listRecent();
    expect(res.length, 2);

    final cached = await dao.listCommits('scope1', 'u/a', limit: 10);
    expect(cached.length, 2);
  });

  test('listRecent falls back to DB when offline', () async {
    if (Platform.isWindows) {
      return; // sqlite3.dll not available in VM unit tests
    }
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final dao = GithubLocalDao(db);
    const scope = 'scope1';
    // Seed a repo and commits in DB
    await dao.upsertRepos(scope, [
      const domain.Repo(
        id: 1,
        name: 'a',
        fullName: 'u/a',
        stargazersCount: 0,
        forksCount: 0,
        description: null,
      ),
    ]);
    await dao.insertCommits(scope, 'u/a', [
      CommitInfo(
        id: 'x1',
        message: 'm1',
        author: 'a',
        date: DateTime(2024, 1, 1),
        repoFullName: 'u/a',
      ),
      CommitInfo(
        id: 'x2',
        message: 'm2',
        author: 'b',
        date: DateTime(2024, 1, 2),
        repoFullName: 'u/a',
      ),
    ]);

    final repo = GithubCommitsRepository(
      _DsFail(),
      () async => {'Authorization': 'Bearer x'},
      dao: dao,
      tokenScope: () async => scope,
    );

    final res = await repo.listRecent();
    expect(res.length, 2);
    expect(res.first.id, anyOf('x1', 'x2'));
  });
}
