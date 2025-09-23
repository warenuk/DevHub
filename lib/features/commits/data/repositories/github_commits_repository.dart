import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/features/commits/domain/repositories/commits_repository.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/local/github_local_dao.dart';
import 'package:devhub_gpt/shared/providers/database_provider.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GithubCommitsRepository implements CommitsRepository {
  GithubCommitsRepository(
    this._ds,
    this._authHeaders, {
    GithubLocalDao? dao,
    Future<String> Function()? tokenScope,
  }) : _dao = dao,
       _tokenScope = tokenScope;

  final GithubRemoteDataSource _ds;
  final Future<Map<String, String>> Function() _authHeaders;
  final GithubLocalDao? _dao;
  final Future<String> Function()? _tokenScope;

  Future<List<CommitInfo>> _readCache({int limit = 10}) async {
    final dao = _dao;
    final scopeFn = _tokenScope;
    if (dao == null || scopeFn == null) return <CommitInfo>[];
    try {
      final scope = await scopeFn();
      final repos = await dao.listRepos(scope);
      if (repos.isEmpty) return <CommitInfo>[];
      final full = repos.first.fullName;
      return dao.listCommits(scope, full, limit: limit);
    } catch (_) {
      return <CommitInfo>[];
    }
  }

  @override
  Future<List<CommitInfo>> listRecent() async {
    try {
      final auth = await _authHeaders();
      if (auth.isEmpty) {
        // No token: attempt DB-only fallback
        return _readCache();
      }

      // Online: take most recently updated repo and fetch commits
      final repos = await _ds.listUserRepos(page: 1, perPage: 1);
      if (repos.isEmpty) return <CommitInfo>[];
      final ownerRepo = repos.first.fullName.split('/');
      if (ownerRepo.length != 2) return <CommitInfo>[];
      final owner = ownerRepo[0];
      final name = ownerRepo[1];
      final commits = await _ds.listRepoCommits(
        owner: owner,
        repo: name,
        perPage: 10,
      );
      final domain = commits.map((e) => e.toDomain()).toList();
      // Cache
      final dao = _dao;
      final scopeFn = _tokenScope;
      if (dao != null && scopeFn != null) {
        final scope = await scopeFn();
        await dao.insertCommits(scope, repos.first.fullName, domain);
      }
      return domain;
    } catch (_) {
      // Fallback to cache
      return _readCache();
    }
  }
}

final githubCommitsRepositoryProvider = Provider<CommitsRepository>((ref) {
  final ds = ref.watch(githubRemoteDataSourceProvider);
  Future<Map<String, String>> headers() async =>
      await ref.read(githubAuthHeaderProvider.future);
  // Wire local cache (Drift)
  final db = ref.watch(databaseProvider);
  final dao = GithubLocalDao(db);
  Future<String> scope() async =>
      await ref.read(githubTokenScopeProvider.future);
  return GithubCommitsRepository(ds, headers, dao: dao, tokenScope: scope);
});
