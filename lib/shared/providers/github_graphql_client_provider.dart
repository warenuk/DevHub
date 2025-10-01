import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';

final githubGraphQLClientProvider = Provider<GraphQLClient>((ref) {
  final tokenAsync = ref.watch(githubTokenProvider);
  final token =
      tokenAsync.maybeWhen(data: (value) => value, orElse: () => null);
  final headers = <String, String>{
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'devhub-gpt-app',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  final link = HttpLink(
    'https://api.github.com/graphql',
    defaultHeaders: headers,
  );

  return GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: link,
  );
});
