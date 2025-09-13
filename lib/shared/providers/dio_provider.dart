import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devhub_gpt/shared/config/env.dart';
import 'package:devhub_gpt/shared/network/logging_interceptor.dart';
import 'package:devhub_gpt/shared/network/tls_pinning.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    headers: { 'Accept': 'application/json' },
  ));
  dio.interceptors.addAll([LoggingInterceptor()]);
  // Apply TLS pinning for primary backend only (not for GitHub).
  final baseUri = Uri.parse(Env.apiBaseUrl);
  applyTlsPinningIfEnabled(dio, baseUri);
  return dio;
});
