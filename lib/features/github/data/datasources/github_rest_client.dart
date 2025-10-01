import 'package:devhub_gpt/features/commits/data/models/commit_model.dart';
import 'package:devhub_gpt/features/github/data/models/activity_event_model.dart';
import 'package:devhub_gpt/features/github/data/models/github_user_model.dart';
import 'package:devhub_gpt/features/github/data/models/pull_request_model.dart';
import 'package:devhub_gpt/features/github/data/models/repo_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

part 'github_rest_client.g.dart';

@RestApi()
abstract class GithubRestClient {
  factory GithubRestClient(Dio dio, {String baseUrl}) = _GithubRestClient;

  @GET('/user')
  Future<GithubUserModel> getCurrentUser();

  @GET('/user/repos')
  Future<List<RepoModel>> listUserRepos({
    @Query('page') int page = 1,
    @Query('per_page') int perPage = 20,
    @Query('sort') String sort = 'updated',
    @Query('direction') String direction = 'desc',
    @Query('affiliation')
    String affiliation = 'owner,collaborator,organization_member',
    @Query('visibility') String visibility = 'all',
  });

  @GET('/user/repos')
  Future<HttpResponse<List<RepoModel>>> listUserReposWithResponse({
    @Query('page') int page = 1,
    @Query('per_page') int perPage = 20,
    @Query('sort') String sort = 'updated',
    @Query('direction') String direction = 'desc',
    @Query('affiliation')
    String affiliation = 'owner,collaborator,organization_member',
    @Query('visibility') String visibility = 'all',
    @Header('If-None-Match') String? ifNoneMatch,
  });

  @GET('/repos/{owner}/{repo}/events')
  Future<List<ActivityEventModel>> getRepoActivity(
    @Path('owner') String owner,
    @Path('repo') String repo,
  );

  @GET('/repos/{owner}/{repo}/commits')
  Future<List<CommitModel>> listRepoCommits(
    @Path('owner') String owner,
    @Path('repo') String repo, {
    @Query('per_page') int perPage = 20,
  });

  @GET('/repos/{owner}/{repo}/commits')
  Future<HttpResponse<List<CommitModel>>> listRepoCommitsWithResponse(
    @Path('owner') String owner,
    @Path('repo') String repo, {
    @Query('per_page') int perPage = 20,
    @Header('If-None-Match') String? ifNoneMatch,
  });

  @GET('/repos/{owner}/{repo}/pulls')
  Future<List<PullRequestModel>> listPullRequests(
    @Path('owner') String owner,
    @Path('repo') String repo, {
    @Query('state') String state = 'open',
    @Query('per_page') int perPage = 20,
  });
}
