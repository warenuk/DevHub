import 'dart:convert';

import 'package:devhub_gpt/shared/config/env.dart';
import 'package:devhub_gpt/shared/network/logging_interceptor.dart';
import 'package:devhub_gpt/shared/providers/dio_provider.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('dioProvider', () {
    test('configures dio base options and core interceptors', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);

      expect(dio.options.baseUrl, Env.apiBaseUrl);
      expect(
        dio.interceptors.whereType<DioCacheInterceptor>().length,
        1,
      );
      expect(
        dio.interceptors.whereType<RetryInterceptor>().length,
        1,
      );
      expect(
        dio.interceptors
            .any((interceptor) => interceptor is LoggingInterceptor),
        isTrue,
      );
    });

    test('serves cached responses when forceCache policy is used', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      final cacheOptions = container.read(dioCacheOptionsProvider);
      final adapter = _RecordingAdapter();
      dio.httpClientAdapter = adapter;

      final response1 = await dio.get(
        '/cache-test',
        options: cacheOptions.toOptions(),
      );
      expect(response1.data, {'hit': 1});
      expect(adapter.requestCount, 1);

      final cacheKey = cacheOptions.keyBuilder(response1.requestOptions);
      final cachedEntry = await cacheOptions.store!.get(cacheKey);
      expect(cachedEntry, isNotNull);

      adapter.shouldFail = true;
      final cachedOptions =
          cacheOptions.copyWith(policy: CachePolicy.forceCache);
      final response2 = await dio.get(
        '/cache-test',
        options: cachedOptions.toOptions(),
      );
      expect(response2.data, {'hit': 1});
      expect(adapter.requestCount, 1,
          reason: 'No extra network calls expected');
    });

    test('retries transient failures once and then succeeds', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      final adapter = _RetryingAdapter();
      dio.httpClientAdapter = adapter;

      final response = await dio.get('/retry-test');

      expect(response.data, 'ok');
      expect(adapter.attempts, 2);
    });
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  int requestCount = 0;
  bool shouldFail = false;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount += 1;
    if (shouldFail) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'offline',
      );
    }
    return ResponseBody.fromString(
      jsonEncode({'hit': requestCount}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _RetryingAdapter implements HttpClientAdapter {
  int attempts = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    attempts += 1;
    if (attempts == 1) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'temporary network issue',
      );
    }
    return ResponseBody.fromString(
      jsonEncode('ok'),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
