import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/features/commits/data/models/commit_model.dart';
import 'package:devhub_gpt/features/github/data/models/activity_event_model.dart';
import 'package:devhub_gpt/features/github/data/models/pull_request_model.dart';
import 'package:devhub_gpt/features/github/data/models/repo_model.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GithubRemoteDataSource {
  GithubRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getCurrentUser() async {
    final res = await _dio.get<Map<String, dynamic>>('/user');
    return res.data as Map<String, dynamic>;
  }

  Future<List<RepoModel>> listUserRepos({
    int page = 1,
    int perPage = 20,
    String? query,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'sort': 'updated',
      'direction': 'desc',
      'affiliation': 'owner,collaborator,organization_member',
      'visibility': 'all',
    };
    final resp = await _dio.get<List<dynamic>>(
      '/user/repos',
      queryParameters: params,
    );
    final list = (resp.data as List).cast<Map<String, dynamic>>();
    final models = list.map(RepoModel.fromJson).toList();
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
    final resp = await _dio.get<List<dynamic>>('/repos/$owner/$repo/events');
    final list = (resp.data as List).cast<Map<String, dynamic>>();
    return list.map(ActivityEventModel.fromGithubJson).toList();
  }

  Future<List<CommitModel>> listRepoCommits({
    required String owner,
    required String repo,
    int perPage = 20,
  }) async {
    final resp = await _dio.get<List<dynamic>>(
      '/repos/$owner/$repo/commits',
      queryParameters: {'per_page': perPage},
    );
    final list = (resp.data as List).cast<Map<String, dynamic>>();
    return list.map(CommitModel.fromJson).toList();
  }

  Future<List<PullRequestModel>> listPullRequests({
    required String owner,
    required String repo,
    String state = 'open',
    int perPage = 20,
  }) async {
    final resp = await _dio.get<List<dynamic>>(
      '/repos/$owner/$repo/pulls',
      queryParameters: {'state': state, 'per_page': perPage},
    );
    final list = (resp.data as List).cast<Map<String, dynamic>>();
    return list.map(PullRequestModel.fromGithubJson).toList();
  }
}

final githubRemoteDataSourceProvider = Provider<GithubRemoteDataSource>((ref) {
  final dio = ref.watch(githubDioProvider);
  AppLogger.info('Init GithubRemoteDataSource', area: 'github');
  return GithubRemoteDataSource(dio);
});
