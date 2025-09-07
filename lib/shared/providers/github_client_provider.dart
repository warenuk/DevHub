import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:devhub_gpt/shared/utils/runtime_env_stub.dart'
    if (dart.library.html) 'package:devhub_gpt/shared/utils/runtime_env_web.dart'
    if (dart.library.io) 'package:devhub_gpt/shared/utils/runtime_env_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Resolve token: prefer secure storage (Settings); fallback to env define.
final githubTokenProvider = FutureProvider<String?>((ref) async {
  const envToken = String.fromEnvironment('GITHUB_TOKEN');
  // In flutter test environment, avoid touching secure storage plugins
  if (isFlutterTestEnv()) {
    if (envToken.isNotEmpty) return envToken;
    return null;
  }
  try {
    final storage = ref.read(secureStorageProvider);
    final t = await storage.read(key: 'github_token');
    final s = t?.trim();
    if (s != null && s.isNotEmpty) return s;
  } catch (_) {
    // In tests/platforms without plugin, ignore and rely on env
  }
  if (envToken.isNotEmpty) return envToken;
  return null;
});

final githubAuthHeaderProvider =
    FutureProvider<Map<String, String>>((ref) async {
  final token = await ref.watch(githubTokenProvider.future);
  if (token == null || token.isEmpty) return <String, String>{};
  return {'Authorization': 'Bearer $token'};
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
