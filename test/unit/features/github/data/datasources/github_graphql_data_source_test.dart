import 'package:devhub_gpt/features/github/data/datasources/github_graphql_data_source.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo_language_stat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mocktail/mocktail.dart';

class _MockGraphQLClient extends Mock implements GraphQLClient {}

void main() {
  late _MockGraphQLClient client;
  late GithubGraphQLDataSource dataSource;

  setUpAll(() {
    registerFallbackValue(
      QueryOptions(document: gql('query Test { viewer { login } }')),
    );
  });

  setUp(() {
    client = _MockGraphQLClient();
    dataSource = GithubGraphQLDataSource(client);
  });

  test('fetchRepoLanguages returns stats when data is available', () async {
    when(() => client.query(any())).thenAnswer((invocation) async {
      final options = invocation.positionalArguments.first as QueryOptions;
      expect(options.variables['owner'], 'owner');
      expect(options.variables['name'], 'repo');
      expect(options.variables['top'], 5);
      return QueryResult(
        options: options,
        data: <String, dynamic>{
          'repository': {
            'languages': {
              'totalSize': 300,
              'edges': [
                {
                  'size': 150,
                  'node': {'name': 'Dart', 'color': '#00B4AB'},
                },
                {
                  'size': 90,
                  'node': {'name': 'TypeScript', 'color': '#3178C6'},
                },
                {
                  'size': 60,
                  'node': {'name': 'Other', 'color': null},
                },
              ],
            },
          },
        },
        source: QueryResultSource.network,
      );
    });

    final stats = await dataSource.fetchRepoLanguages(
      owner: 'owner',
      name: 'repo',
    );

    expect(stats, hasLength(3));
    expect(stats.first, isA<RepoLanguageStat>());
    expect(stats.first.name, 'Dart');
    expect(stats.first.percentageLabel, '50.0%');
  });

  test('fetchRepoLanguages throws auth error for UNAUTHENTICATED', () async {
    when(() => client.query(any())).thenAnswer((invocation) async {
      final options = invocation.positionalArguments.first as QueryOptions;
      return QueryResult(
        options: options,
        source: QueryResultSource.network,
        exception: OperationException(
          graphqlErrors: [
            const GraphQLError(
              message: 'Bad credentials',
              extensions: {'type': 'UNAUTHENTICATED'},
            ),
          ],
        ),
      );
    });

    expect(
      () => dataSource.fetchRepoLanguages(owner: 'o', name: 'r'),
      throwsA(isA<GithubGraphQLException>().having(
        (e) => e.isAuthError,
        'isAuthError',
        isTrue,
      )),
    );
  });
}
