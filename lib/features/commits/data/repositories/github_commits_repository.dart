import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/features/commits/domain/repositories/commits_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:devhub_gpt/features/github/data/datasources/github_remote_data_source.dart';
// Mapping is done in data source; no direct model import needed here.
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';

class GithubCommitsRepository implements CommitsRepository {
  GithubCommitsRepository(this._ds, this._authHeaders);

  final GithubRemoteDataSource _ds;
  final Future<Map<String, String>> Function() _authHeaders;

  @override
  Future<List<CommitInfo>> listRecent() async {
    final auth = await _authHeaders();
    if (auth.isEmpty) return <CommitInfo>[];
    // Strategy: take most recently updated repo and return its latest commits
    final repos = await _ds.listUserRepos(auth: auth, page: 1, perPage: 1);
    if (repos.isEmpty) return <CommitInfo>[];
    final ownerRepo = repos.first.fullName.split('/');
    if (ownerRepo.length != 2) return <CommitInfo>[];
    final owner = ownerRepo[0];
    final name = ownerRepo[1];
    final commits = await _ds.listRepoCommits(
        auth: auth, owner: owner, repo: name, perPage: 10);
    return commits.map((e) => e.toDomain()).toList();
  }
}

final githubCommitsRepositoryProvider = Provider<CommitsRepository>((ref) {
  final ds = ref.watch(githubRemoteDataSourceProvider);
  Future<Map<String, String>> headers() async =>
      await ref.read(githubAuthHeaderProvider.future);
  return GithubCommitsRepository(ds, headers);
});
