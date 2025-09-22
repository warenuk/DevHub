import 'dart:math';

import 'package:devhub_gpt/shared/network/retry_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _MockErrorHandler extends Mock implements ErrorInterceptorHandler {}

class _FixedRandom implements Random {
  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      RequestOptions(
        path: '/',
        method: 'GET',
        baseUrl: 'https://example.com',
      ),
    );
    registerFallbackValue(
      Response<dynamic>(
        requestOptions: RequestOptions(
          path: '/',
          method: 'GET',
          baseUrl: 'https://example.com',
        ),
      ),
    );
    registerFallbackValue(
      DioException(
        requestOptions: RequestOptions(
          path: '/',
          method: 'GET',
          baseUrl: 'https://example.com',
        ),
      ),
    );
  });

  test('retries idempotent requests and resolves when the retry succeeds',
      () async {
    final dio = _MockDio();
    final handler = _MockErrorHandler();
    final interceptor = RetryInterceptor(
      dio,
      maxRetries: 2,
      baseDelay: const Duration(milliseconds: 1),
      random: _FixedRandom(),
    );

    final request = RequestOptions(
      path: '/repos',
      method: 'GET',
      baseUrl: 'https://api.github.com',
    );

    final failure = DioException(
      requestOptions: request,
      response: Response<dynamic>(
        requestOptions: request,
        statusCode: 500,
      ),
      type: DioExceptionType.badResponse,
    );

    final success = Response<dynamic>(
      requestOptions: request,
      statusCode: 200,
      data: const <String, dynamic>{'ok': true},
    );

    when(() => dio.fetch<dynamic>(any())).thenAnswer((_) async => success);
    when(() => handler.resolve(any())).thenReturn(null);
    when(() => handler.next(any())).thenReturn(null);

    await interceptor.onError(failure, handler);

    verify(() => dio.fetch<dynamic>(any())).called(1);
    verify(() => handler.resolve(success)).called(1);
    verifyNever(() => handler.next(any()));
  });

  test('skips retry for non-idempotent requests', () async {
    final dio = _MockDio();
    final handler = _MockErrorHandler();
    final interceptor = RetryInterceptor(dio, random: _FixedRandom());

    final request = RequestOptions(
      path: '/repos',
      method: 'POST',
      baseUrl: 'https://api.github.com',
    );

    final failure = DioException(
      requestOptions: request,
      response: Response<dynamic>(
        requestOptions: request,
        statusCode: 502,
      ),
      type: DioExceptionType.badResponse,
    );

    when(() => handler.next(any())).thenReturn(null);

    await interceptor.onError(failure, handler);

    verifyNever(() => dio.fetch<dynamic>(any()));
    verify(() => handler.next(failure)).called(1);
  });

  test('stops retrying when maxRetries is reached', () async {
    final dio = _MockDio();
    final handler = _MockErrorHandler();
    final interceptor = RetryInterceptor(
      dio,
      maxRetries: 2,
      baseDelay: const Duration(milliseconds: 1),
      random: _FixedRandom(),
    );

    final request = RequestOptions(
      path: '/rate_limit',
      method: 'GET',
      baseUrl: 'https://api.github.com',
    );
    request.extra['retry_attempt'] = 2;

    final failure = DioException(
      requestOptions: request,
      response: Response<dynamic>(
        requestOptions: request,
        statusCode: 503,
      ),
      type: DioExceptionType.badResponse,
    );

    when(() => handler.next(any())).thenReturn(null);

    await interceptor.onError(failure, handler);

    verifyNever(() => dio.fetch<dynamic>(any()));
    verify(() => handler.next(failure)).called(1);
  });
}
