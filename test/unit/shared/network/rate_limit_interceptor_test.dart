import 'dart:async';

import 'package:devhub_gpt/shared/network/rate_limit_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _CompletingRequestHandler extends RequestInterceptorHandler {
  final Completer<void> _completer = Completer<void>();

  Future<void> get completed => _completer.future;

  @override
  void next(RequestOptions requestOptions) {
    _completer.complete();
  }
}

class _CompletingResponseHandler extends ResponseInterceptorHandler {
  final Completer<void> _completer = Completer<void>();

  Future<void> get completed => _completer.future;

  @override
  void next(Response<dynamic> response) {
    _completer.complete();
  }
}

class _CompletingErrorHandler extends ErrorInterceptorHandler {
  final Completer<void> _completer = Completer<void>();

  Future<void> get completed => _completer.future;

  @override
  void next(DioException err) {
    _completer.complete();
  }
}

void main() {
  test('enforces a minimal spacing between requests for the same host',
      () async {
    final interceptor = RateLimitInterceptor(
      minDelay: const Duration(milliseconds: 40),
      maxJitter: Duration.zero,
    );
    final handler = _CompletingRequestHandler();

    final first = RequestOptions(
      path: '/user',
      method: 'GET',
      baseUrl: 'https://api.github.com',
    );
    interceptor.onRequest(first, handler);
    await handler.completed;

    final secondHandler = _CompletingRequestHandler();
    final second = RequestOptions(
      path: '/user/repos',
      method: 'GET',
      baseUrl: 'https://api.github.com',
    );
    final sw = Stopwatch()..start();
    interceptor.onRequest(second, secondHandler);
    await secondHandler.completed;
    sw.stop();

    expect(sw.elapsed.inMilliseconds >= 30, isTrue);
  });

  test('locks a host after receiving retry-after header values', () async {
    final interceptor = RateLimitInterceptor(
      minDelay: Duration.zero,
      maxJitter: Duration.zero,
    );
    final responseOptions = RequestOptions(
      path: '/notifications',
      method: 'GET',
      baseUrl: 'https://api.github.com',
    );
    final future = DateTime.now().add(const Duration(milliseconds: 250));
    final response = Response<void>(
      requestOptions: responseOptions,
      statusCode: 429,
      headers: Headers.fromMap(<String, List<String>>{
        'retry-after': <String>[future.toIso8601String()],
      }),
    );

    final responseHandler = _CompletingResponseHandler();
    interceptor.onResponse(response, responseHandler);
    await responseHandler.completed;

    final followUp = RequestOptions(
      path: '/notifications',
      method: 'GET',
      baseUrl: 'https://api.github.com',
    );
    final handler = _CompletingRequestHandler();
    final sw = Stopwatch()..start();
    interceptor.onRequest(followUp, handler);
    await handler.completed;
    sw.stop();

    expect(sw.elapsed.inMilliseconds >= 180, isTrue);
  });

  test('uses GitHub rate limit reset headers to back off', () async {
    final interceptor = RateLimitInterceptor(
      minDelay: Duration.zero,
      maxJitter: Duration.zero,
    );
    final request = RequestOptions(
      path: '/search/repositories',
      method: 'GET',
      baseUrl: 'https://api.github.com',
    );
    final resetSeconds = (DateTime.now()
                .add(const Duration(milliseconds: 240))
                .toUtc()
                .millisecondsSinceEpoch /
            1000)
        .toStringAsFixed(3);
    final response = Response<void>(
      requestOptions: request,
      statusCode: 403,
      headers: Headers.fromMap(<String, List<String>>{
        'x-ratelimit-remaining': <String>['0'],
        'x-ratelimit-reset': <String>[resetSeconds],
      }),
    );
    final err = DioException(
      requestOptions: request,
      response: response,
      type: DioExceptionType.badResponse,
    );

    final errorHandler = _CompletingErrorHandler();
    interceptor.onError(err, errorHandler);
    await errorHandler.completed;

    final followUp = RequestOptions(
      path: '/search/repositories',
      method: 'GET',
      baseUrl: 'https://api.github.com',
    );
    final handler = _CompletingRequestHandler();
    final sw = Stopwatch()..start();
    interceptor.onRequest(followUp, handler);
    await handler.completed;
    sw.stop();

    expect(sw.elapsed.inMilliseconds >= 180, isTrue);
  });
}
