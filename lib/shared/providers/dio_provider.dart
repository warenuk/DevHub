import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/shared/config/env.dart';
import 'package:devhub_gpt/shared/network/logging_interceptor.dart';
import 'package:devhub_gpt/shared/network/tls_pinning.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioCacheOptionsProvider = Provider<CacheOptions>((ref) {
  return CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.refreshForceCache,
    // Allow using cached data when the backend is temporarily failing.
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(hours: 12),
    priority: CachePriority.normal,
    allowPostMethod: false,
  );
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );
  final cacheOptions = ref.read(dioCacheOptionsProvider);
  dio.interceptors.addAll([
    DioCacheInterceptor(options: cacheOptions),
    RetryInterceptor(
      dio: dio,
      retries: 3,
      retryDelays: const [
        Duration(milliseconds: 120),
        Duration(milliseconds: 300),
        Duration(milliseconds: 600),
      ],
      retryEvaluator: _shouldRetry,
      logPrint: (obj) => AppLogger.info('[HTTP][retry] $obj', area: 'http'),
    ),
    LoggingInterceptor(),
  ]);
  // Apply TLS pinning for primary backend only (not for GitHub).
  final baseUri = Uri.parse(Env.apiBaseUrl);
  applyTlsPinningIfEnabled(dio, baseUri);
  return dio;
});

bool _shouldRetry(DioException error, int attempt) {
  if (error.type == DioExceptionType.cancel) {
    return false;
  }
  if (error.type == DioExceptionType.badResponse) {
    final status = error.response?.statusCode ?? 0;
    // Retry only on server errors.
    return status >= 500 && status < 600;
  }
  // Retry for network/timeout errors.
  return error.type != DioExceptionType.badCertificate;
}
