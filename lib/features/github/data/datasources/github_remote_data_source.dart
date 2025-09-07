import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:devhub_gpt/core/utils/app_logger.dart';

import 'package:devhub_gpt/features/github/data/models/repo_model.dart';
import 'package:devhub_gpt/features/github/data/models/activity_event_model.dart';
import 'package:devhub_gpt/features/commits/data/models/commit_model.dart';
import 'package:devhub_gpt/features/github/data/models/pull_request_model.dart';

class GithubRemoteDataSource {
  GithubRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getCurrentUser(Map<String, String> auth) async {
    final res = await _dio.get('/user', options: Options(headers: auth));
    return res.data as Map<String, dynamic>;
  }

  Future<List<RepoModel>> listUserRepos({
    required Map<String, String> auth,
    int page = 1,
    int perPage = 20,
    String? query,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'sort': 'updated',
      'direction': 'desc',
    };
    final resp = await _dio.get(
      '/user/repos',
      queryParameters: params,
      options: Options(headers: auth),
    );
    final list = (resp.data as List).cast<Map<String, dynamic>>();
    final models = list.map(RepoModel.fromJson).toList();
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      return models
          .where((e) =>
              e.fullName.toLowerCase().contains(q) ||
              e.name.toLowerCase().contains(q))
          .toList();
    }
    return models;
  }

  Future<List<ActivityEventModel>> getRepoActivity({
    required Map<String, String> auth,
    required String owner,
    required String repo,
  }) async {
    final resp = await _dio.get(
      '/repos/$owner/$repo/events',
      options: Options(headers: auth),
    );
    final list = (resp.data as List).cast<Map<String, dynamic>>();
    return list.map(ActivityEventModel.fromJson).toList();
  }

  Future<List<CommitModel>> listRepoCommits({
    required Map<String, String> auth,
    required String owner,
    required String repo,
    int perPage = 20,
  }) async {
    final resp = await _dio.get(
      '/repos/$owner/$repo/commits',
      queryParameters: {'per_page': perPage},
      options: Options(headers: auth),
    );
    final list = (resp.data as List).cast<Map<String, dynamic>>();
    return list.map(CommitModel.fromJson).toList();
  }

  Future<List<PullRequestModel>> listPullRequests({
    required Map<String, String> auth,
    required String owner,
    required String repo,
    String state = 'open',
    int perPage = 20,
  }) async {
    final resp = await _dio.get(
      '/repos/$owner/$repo/pulls',
      queryParameters: {
        'state': state,
        'per_page': perPage,
      },
      options: Options(headers: auth),
    );
    final list = (resp.data as List).cast<Map<String, dynamic>>();
    return list.map(PullRequestModel.fromJson).toList();
  }
}

final githubRemoteDataSourceProvider = Provider<GithubRemoteDataSource>((ref) {
  final dio = ref.watch(githubDioProvider);
  AppLogger.info('Init GithubRemoteDataSource', area: 'github');
  return GithubRemoteDataSource(dio);
});
