import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:devhub_gpt/shared/network/auth_interceptor.dart';
import 'package:devhub_gpt/shared/network/etag_interceptor.dart';
import 'package:devhub_gpt/shared/network/etag_store.dart';
import 'package:devhub_gpt/shared/network/logging_interceptor.dart';
import 'package:devhub_gpt/shared/network/queue/queue_interceptor.dart';
import 'package:devhub_gpt/shared/network/retry_interceptor.dart';
import 'package:devhub_gpt/shared/network/token_store.dart';
import 'package:devhub_gpt/shared/providers/database_provider.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:devhub_gpt/shared/providers/sync_queue_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Токен GitHub з безпечного сховища.
final githubTokenProvider = FutureProvider<String?>((ref) async {
  try {
    final storage = ref.read(secureStorageProvider);
    final t = await storage.read(key: 'github_token');
    final s = t?.trim();
    if (s == null || s.isEmpty) return null;
    return s;
  } catch (_) {
    return null;
  }
});

/// Готовий заголовок авторизації або порожня мапа.
final githubAuthHeaderProvider =
    FutureProvider<Map<String, String>>((ref) async {
  final token = await ref.watch(githubTokenProvider.future);
  if (token == null || token.isEmpty) return <String, String>{};
  return {'Authorization': 'Bearer $token'};
});

/// Скоуп токена для ізоляції кешу у локальній БД (хеш SHA-256, не сирий токен).
final githubTokenScopeProvider = FutureProvider<String>((ref) async {
  final token = await ref.watch(githubTokenProvider.future);
  if (token == null || token.isEmpty) return 'anonymous';
  final bytes = utf8.encode(token);
  return crypto.sha256.convert(bytes).toString();
});

/// Налаштований Dio-клієнт до api.github.com з інтерсепторами.
final githubDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.github.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'User-Agent': 'devhub-gpt-app',
      },
    ),
  );

  final storage = ref.read(secureStorageProvider);
  final tokenStore = TokenStore(storage);
  final db = ref.read(databaseProvider);
  final etagStore = EtagStore(db);

  // inject dio into options.extra for queue interceptor
  dio.interceptors.add(InterceptorsWrapper(onRequest: (opts, h) {
    opts.extra['dio_instance'] = dio;
    h.next(opts);
  },),);
  final queue = ref.read(syncQueueProvider);
  dio.interceptors.addAll([
    QueueInterceptor(queue),
    LoggingInterceptor(),
    AuthInterceptor(
      tokenStore,
      shouldAttach: (uri) => uri.host == 'api.github.com',
    ),
    EtagInterceptor(etagStore, tokenStore),
    RetryInterceptor(dio, maxRetries: 3),
  ],);

  return dio;
});
