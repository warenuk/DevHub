import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo_language_stat.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:devhub_gpt/shared/providers/github_graphql_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';

class GithubGraphQLException implements Exception {
  GithubGraphQLException(this.message, {this.isAuthError = false});

  final String message;
  final bool isAuthError;

  @override
  String toString() => message;
}

final githubGraphQLDataSourceProvider = Provider<GithubGraphQLDataSource?>(
  (ref) {
    final tokenAsync = ref.watch(githubTokenProvider);
    final token =
        tokenAsync.maybeWhen(data: (value) => value, orElse: () => null);
    if (token == null || token.isEmpty) {
      return null;
    }
    final client = ref.watch(githubGraphQLClientProvider);
    return GithubGraphQLDataSource(client);
  },
);

class GithubGraphQLDataSource {
  GithubGraphQLDataSource(this._client);

  final GraphQLClient _client;

  static const _repoLanguagesQuery = r'''
    query RepoLanguages($owner: String!, $name: String!, $top: Int!) {
      repository(owner: $owner, name: $name) {
        languages(first: $top, orderBy: {field: SIZE, direction: DESC}) {
          totalSize
          edges {
            size
            node {
              name
              color
            }
          }
        }
      }
    }
  ''';

  Future<List<RepoLanguageStat>> fetchRepoLanguages({
    required String owner,
    required String name,
    int top = 5,
  }) async {
    final options = QueryOptions(
      document: gql(_repoLanguagesQuery),
      variables: <String, dynamic>{
        'owner': owner,
        'name': name,
        'top': top,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _client.query(options);
    final exception = result.exception;
    if (exception != null) {
      final isAuth = _isAuthError(exception);
      final message = exception.toString();
      AppLogger.error(
        'GitHub GraphQL query failed',
        error: message,
        area: 'github',
      );
      throw GithubGraphQLException(message, isAuthError: isAuth);
    }

    final repository = result.data?['repository'] as Map<String, dynamic>?;
    if (repository == null) {
      return const <RepoLanguageStat>[];
    }
    final languages = repository['languages'] as Map<String, dynamic>?;
    if (languages == null) {
      return const <RepoLanguageStat>[];
    }
    final totalSize = languages['totalSize'] as int? ?? 0;
    final edges = (languages['edges'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    if (edges.isEmpty || totalSize <= 0) {
      return const <RepoLanguageStat>[];
    }

    final stats = edges.map((edge) {
      final node = edge['node'] as Map<String, dynamic>? ?? const {};
      final size = edge['size'] as int? ?? 0;
      final name = node['name'] as String? ?? 'Unknown';
      final color = node['color'] as String?;
      final ratio = totalSize == 0 ? 0.0 : size / totalSize;
      return RepoLanguageStat(
        name: name,
        size: size,
        ratio: ratio,
        color: color,
      );
    }).toList();

    return stats;
  }

  bool _isAuthError(OperationException exception) {
    if (exception.linkException is ServerException) {
      final server = exception.linkException as ServerException;
      final status = server.statusCode ?? 0;
      if (status == 401 || status == 403) {
        return true;
      }
    }
    if (exception.graphqlErrors.isEmpty) {
      return false;
    }
    return exception.graphqlErrors.any((error) {
      final type = error.extensions?['type'];
      final code = error.extensions?['code'];
      return type == 'UNAUTHENTICATED' || code == 'UNAUTHENTICATED';
    });
  }
}
