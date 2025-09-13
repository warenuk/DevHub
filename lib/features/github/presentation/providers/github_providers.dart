import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/features/commits/data/models/commit_model.dart';
import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_oauth_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_web_oauth_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/local/github_local_dao.dart';
import 'package:devhub_gpt/features/github/data/models/repo_model.dart';
import 'package:devhub_gpt/features/github/data/repositories/github_auth_repository_impl.dart';
import 'package:devhub_gpt/features/github/data/repositories/github_repository_impl.dart';
import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/domain/entities/github_user.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_auth_repository.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_repository.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_auth_notifier.dart';
import 'package:devhub_gpt/shared/providers/database_provider.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:devhub_gpt/shared/providers/github_oauth_client_provider.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';

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
    .family<List<ActivityEvent>, ({String owner, String name})>((ref, params) async {
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
    .family<List<CommitInfo>, ({String owner, String name})>((ref, params) async {
  // Re-run when session version changes (e.g., token updated)
  ref.watch(githubSessionVersionProvider);
  // Also react to token changes directly.
  await ref.watch(githubTokenProvider.future);

  final ds = ref.watch(githubRemoteDataSourceProvider);
  final list = await ds.listRepoCommits(
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

// =======================
// DB-first cache streams
// =======================
final reposCacheProvider = StreamProvider<List<Repo>>((ref) async* {
  final db = ref.watch(databaseProvider);
  final dao = GithubLocalDao(db);
  final scope = await ref.watch(githubTokenScopeProvider.future);
  yield* dao.watchRepos(scope, query: ref.watch(repoQueryProvider));
});

final recentCommitsCacheProvider = StreamProvider<List<CommitInfo>>((ref) {
  final db = ref.watch(databaseProvider);
  final dao = GithubLocalDao(db);
  final scopeAsync = ref.watch(githubTokenScopeProvider);
  final reposAsync = ref.watch(reposCacheProvider);

  final scope = scopeAsync.value;
  final repos = reposAsync.value;

  if (scope == null || repos == null || repos.isEmpty) {
    return const Stream<List<CommitInfo>>.empty();
  }
  final full = repos.first.fullName;
  return dao.watchCommits(scope, full, limit: 20);
});

// =======================
// Lightweight Sync Service with ETag
// =======================
class GithubSyncService {
  GithubSyncService(this._ref);
  final Ref _ref;

  static const _kEtagRepos = 'etag:/user/repos';
  static String _etagCommits(String fullName) => 'etag:/repos/$fullName/commits';

  Future<void> syncRepos() async {
    try {
      final dio = _ref.read(githubDioProvider);
      final token = await _ref.read(githubTokenProvider.future);
      if (token == null || token.isEmpty) return;
      final storage = _ref.read(secureStorageProvider);
      final etag = await storage.read(key: _kEtagRepos);
      final resp = await dio.get<List<dynamic>>(
      '/user/repos',
      options: Options(headers: { if (etag != null && etag.isNotEmpty) 'If-None-Match': etag }),
      queryParameters: {
      'per_page': 50,
      'sort': 'updated',
      'direction': 'desc',
      'affiliation': 'owner,collaborator,organization_member',
        'visibility': 'all',
      },
      );
      if (resp.statusCode == 304) {
        AppLogger.info('repos not modified', area: 'sync');
        return;
      }
      final list = (resp.data ?? []).cast<Map<String, dynamic>>();
      final models = list.map(RepoModel.fromJson).toList();
      final repos = models.map((m) => m.toDomain()).toList();
      final scope = await _ref.read(githubTokenScopeProvider.future);
      final dao = GithubLocalDao(_ref.read(databaseProvider));
      await dao.upsertRepos(scope, repos);
      final newEtag = resp.headers.value('etag');
      if (newEtag != null && newEtag.isNotEmpty) {
        await storage.write(key: _kEtagRepos, value: newEtag);
      }
    } catch (e, s) {
      AppLogger.error('syncRepos failed', error: e, stackTrace: s, area: 'sync');
    }
  }

  Future<void> syncRecentCommits() async {
    try {
      final db = _ref.read(databaseProvider);
      final dao = GithubLocalDao(db);
      final scope = await _ref.read(githubTokenScopeProvider.future);
      final repos = await dao.listRepos(scope);
      if (repos.isEmpty) return;
      final full = repos.first.fullName;
      final parts = full.split('/');
      if (parts.length != 2) return;
      final dio = _ref.read(githubDioProvider);
      final token = await _ref.read(githubTokenProvider.future);
      if (token == null || token.isEmpty) return;
      final storage = _ref.read(secureStorageProvider);
      final etagKey = _etagCommits(full);
      final etag = await storage.read(key: etagKey);
      final resp = await dio.get<List<dynamic>>(
      '/repos/${parts[0]}/${parts[1]}/commits',
      queryParameters: {'per_page': 20},
      options: Options(headers: { if (etag != null && etag.isNotEmpty) 'If-None-Match': etag }),
      );
      if (resp.statusCode == 304) {
        AppLogger.info('commits not modified', area: 'sync');
        return;
      }
      final list = (resp.data ?? []).cast<Map<String, dynamic>>();
      final models = list.map(CommitModel.fromJson).toList();
      final commits = models.map((m) => m.toDomain()).toList();
      await dao.insertCommits(scope, full, commits);
      final newEtag = resp.headers.value('etag');
      if (newEtag != null && newEtag.isNotEmpty) {
        await storage.write(key: etagKey, value: newEtag);
      }
    } catch (e, s) {
      AppLogger.error('syncRecentCommits failed', error: e, stackTrace: s, area: 'sync');
    }
  }

  Future<void> syncAll() async {
    await syncRepos();
    await syncRecentCommits();
  }
}

final githubSyncServiceProvider = Provider<GithubSyncService>((ref) {
  return GithubSyncService(ref);
});
