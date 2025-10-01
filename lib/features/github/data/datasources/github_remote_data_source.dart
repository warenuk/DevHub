import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/features/commits/data/models/commit_model.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_rest_client.dart';
import 'package:devhub_gpt/features/github/data/models/activity_event_model.dart';
import 'package:devhub_gpt/features/github/data/models/github_user_model.dart';
import 'package:devhub_gpt/features/github/data/models/pull_request_model.dart';
import 'package:devhub_gpt/features/github/data/models/repo_model.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GithubRemoteDataSource {
  GithubRemoteDataSource(this._api);

  final GithubRestClient _api;

  Future<GithubUserModel> getCurrentUser() async {
    return _api.getCurrentUser();
  }

  Future<List<RepoModel>> listUserRepos({
    int page = 1,
    int perPage = 20,
    String? query,
  }) async {
    final models = await _api.listUserRepos(
      page: page,
      perPage: perPage,
      sort: 'updated',
      direction: 'desc',
      affiliation: 'owner,collaborator,organization_member',
      visibility: 'all',
    );
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      return models
          .where(
            (e) =>
                e.fullName.toLowerCase().contains(q) ||
                e.name.toLowerCase().contains(q),
          )
          .toList();
    }
    return models;
  }

  Future<List<ActivityEventModel>> getRepoActivity({
    required String owner,
    required String repo,
  }) async {
    return _api.getRepoActivity(owner, repo);
  }

  Future<List<CommitModel>> listRepoCommits({
    required String owner,
    required String repo,
    int perPage = 20,
  }) async {
    return _api.listRepoCommits(
      owner,
      repo,
      perPage: perPage,
    );
  }

  Future<List<PullRequestModel>> listPullRequests({
    required String owner,
    required String repo,
    String state = 'open',
    int perPage = 20,
  }) async {
    return _api.listPullRequests(
      owner,
      repo,
      state: state,
      perPage: perPage,
    );
  }
}

final githubRestClientProvider = Provider<GithubRestClient>((ref) {
  final dio = ref.watch(githubDioProvider);
  return GithubRestClient(dio);
});

final githubRemoteDataSourceProvider = Provider<GithubRemoteDataSource>((ref) {
  final api = ref.watch(githubRestClientProvider);
  AppLogger.info('Init GithubRemoteDataSource', area: 'github');
  return GithubRemoteDataSource(api);
});
