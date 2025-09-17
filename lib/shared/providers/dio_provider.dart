import 'package:devhub_gpt/shared/config/env.dart';
import 'package:devhub_gpt/shared/network/logging_interceptor.dart';
import 'package:devhub_gpt/shared/network/queue/queue_interceptor.dart';
import 'package:devhub_gpt/shared/network/tls_pinning.dart';
import 'package:devhub_gpt/shared/providers/sync_queue_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  // Покласти посилання на Dio в extra, щоб QueueInterceptor міг робити fetch
  dio.interceptors.add(InterceptorsWrapper(onRequest: (opts, h) {
    opts.extra['dio_instance'] = dio;
    h.next(opts);
  },),);
  // Queue + logging
  final queue = ref.read(syncQueueProvider);
  dio.interceptors.addAll([
    QueueInterceptor(queue),
    LoggingInterceptor(),
  ],);
  // Apply TLS pinning for primary backend only (not for GitHub).
  final baseUri = Uri.parse(Env.apiBaseUrl);
  applyTlsPinningIfEnabled(dio, baseUri);
  return dio;
});
