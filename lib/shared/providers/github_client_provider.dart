import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';

final githubAuthHeaderProvider = FutureProvider<Map<String, String>>((ref) async {
  // Use only env for tests/CI and to avoid platform channels in widget tests
  final envToken = const String.fromEnvironment('GITHUB_TOKEN');
  if (envToken.isEmpty) return <String, String>{};
  return {'Authorization': 'Bearer $envToken'};
});

final githubDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.github.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {
        'Accept': 'application/vnd.github+json',
        // Required by GitHub API
        'X-GitHub-Api-Version': '2022-11-28',
        'User-Agent': 'devhub-gpt-app',
      },
    ),
  );
  if (kDebugMode) {
    // Use already configured PrettyDioLogger via shared dio if desired; keep minimal here.
  }
  return dio;
});
