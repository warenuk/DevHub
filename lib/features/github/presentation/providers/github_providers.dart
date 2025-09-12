import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_oauth_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_web_oauth_data_source.dart';
import 'package:devhub_gpt/features/github/data/repositories/github_auth_repository_impl.dart';
import 'package:devhub_gpt/features/github/data/repositories/github_repository_impl.dart';
import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/domain/entities/github_user.dart';
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

// Session version is bumped whenever GitHub account/token changes.
// Watching this makes dependent providers refresh without coupling to
// async secure-storage reads in tests.
final githubSessionVersionProvider = StateProvider<int>((ref) => 0);

final repoQueryProvider = StateProvider<String>((ref) => '');

// Full repositories list for the dedicated page.
// Reacts to token changes by explicitly watching githubTokenProvider.
final reposProvider = FutureProvider.autoDispose<List<Repo>>((ref) async {
  // Re-run when session version changes (e.g., token updated)
  ref.watch(githubSessionVersionProvider);
  // Also react directly to token changes, so first load after OAuth works without manual refresh.
  await ref.watch(githubTokenProvider.future);

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

// Lightweight overview list for the dashboard to avoid keeping the full
// reposProvider alive across routes. This decouples lifecycles so the
// full list refetches when navigating back to it.
final reposOverviewProvider =
    FutureProvider.autoDispose<List<Repo>>((ref) async {
  // Re-run when session version changes (e.g., token updated)
  ref.watch(githubSessionVersionProvider);
  // Also react to token changes directly.
  await ref.watch(githubTokenProvider.future);

  final repo = ref.watch(githubRepositoryProvider);
  final result = await repo.getUserRepos(page: 1);
  return result.fold((l) => <Repo>[], (r) => r);
});

final activityProvider = FutureProvider.autoDispose
    .family<List<ActivityEvent>, ({String owner, String name})>(
        (ref, params) async {
  // Re-run when session version changes (e.g., token updated)
  ref.watch(githubSessionVersionProvider);
  // Also react to token changes directly.
  await ref.watch(githubTokenProvider.future);

  final repo = ref.watch(githubRepositoryProvider);
  final result = await repo.getRepoActivity(params.owner, params.name);
  return result.fold((l) => <ActivityEvent>[], (r) => r);
});

// Commits per repo
final repoCommitsProvider = FutureProvider.autoDispose
    .family<List<CommitInfo>, ({String owner, String name})>(
        (ref, params) async {
  // Re-run when session version changes (e.g., token updated)
  ref.watch(githubSessionVersionProvider);
  // Also react to token changes directly.
  await ref.watch(githubTokenProvider.future);

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
  final notifier = GithubAuthNotifier(repo, ref);
  // Initialize from persisted token
  // ignore: discarded_futures
  notifier.loadFromStorage();
  return notifier;
});

// Поточний GitHub користувач (нік + аватар)
// Повертає null якщо немає токена або помилка.
final currentGithubUserProvider = FutureProvider<GithubUser?>((ref) async {
  // Прив'язуємося до сесії (щоб оновлювалося після логіну/логауту)
  ref.watch(githubSessionVersionProvider);

  // Якщо токену немає — повертаємо null
  final token = await ref.watch(githubTokenProvider.future);
  if (token == null || token.isEmpty) return null;

  final repo = ref.watch(githubRepositoryProvider);
  final either = await repo.getCurrentUser();
  return either.fold((_) => null, (u) => u);
});
