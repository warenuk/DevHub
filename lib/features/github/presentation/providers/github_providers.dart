import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_oauth_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_web_oauth_data_source.dart';
import 'package:devhub_gpt/features/github/data/repositories/github_auth_repository_impl.dart';
import 'package:devhub_gpt/features/github/data/repositories/github_repository_impl.dart';
import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_auth_repository.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_repository.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_auth_notifier.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:devhub_gpt/shared/providers/github_oauth_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final githubRepositoryProvider = Provider<GithubRepository>((ref) {
  return ref.watch(githubRepositoryImplProvider);
});

final repoQueryProvider = StateProvider<String>((ref) => '');

final reposProvider = FutureProvider.autoDispose<List<Repo>>((ref) async {
  final repo = ref.watch(githubRepositoryProvider);
  final query = ref.watch(repoQueryProvider);
  final result = await repo.getUserRepos(query: query.isEmpty ? null : query);
  final list = result.fold((l) => <Repo>[], (r) => r);
  if (query.isEmpty) return list;
  final q = query.toLowerCase();
  return list
      .where(
        (e) =>
            e.fullName.toLowerCase().contains(q) ||
            e.name.toLowerCase().contains(q),
      )
      .toList();
});

final activityProvider = FutureProvider.autoDispose
    .family<List<ActivityEvent>, ({String owner, String name})>(
        (ref, params) async {
  final repo = ref.watch(githubRepositoryProvider);
  final result = await repo.getRepoActivity(params.owner, params.name);
  return result.fold((l) => <ActivityEvent>[], (r) => r);
});

// Commits per repo
final repoCommitsProvider = FutureProvider.autoDispose
    .family<List<CommitInfo>, ({String owner, String name})>(
        (ref, params) async {
  final ds = ref.watch(githubRemoteDataSourceProvider);
  final auth = await ref.read(githubAuthHeaderProvider.future);
  if (auth.isEmpty) return <CommitInfo>[];
  final list = await ds.listRepoCommits(
    auth: auth,
    owner: params.owner,
    repo: params.name,
    perPage: 20,
  );
  return list.map((m) => m.toDomain()).toList();
});

// OAuth Device Flow dependencies
final githubOAuthDataSourceProvider =
    Provider<GithubOAuthRemoteDataSource>((ref) {
  final dio = ref.watch(githubOAuthDioProvider);
  return GithubOAuthRemoteDataSource(dio);
});

final githubWebOAuthDataSourceProvider =
    Provider<GithubWebOAuthDataSource>((ref) {
  return const GithubWebOAuthDataSource();
});

final githubAuthRepositoryProvider = Provider<GithubAuthRepository>((ref) {
  final ds = ref.watch(githubOAuthDataSourceProvider);
  final web = ref.watch(githubWebOAuthDataSourceProvider);
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  return GithubAuthRepositoryImpl(ds, storage, web: web);
});

final githubAuthNotifierProvider =
    StateNotifierProvider<GithubAuthNotifier, GithubAuthState>((ref) {
  final repo = ref.watch(githubAuthRepositoryProvider);
  final notifier = GithubAuthNotifier(repo);
  // Initialize from persisted token
  // ignore: discarded_futures
  notifier.loadFromStorage();
  return notifier;
});
