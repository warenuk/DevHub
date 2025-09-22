import 'dart:async';

import 'package:devhub_gpt/core/db/app_database.dart';
import 'package:devhub_gpt/shared/network/etag_interceptor.dart';
import 'package:devhub_gpt/shared/network/etag_store.dart';
import 'package:devhub_gpt/shared/network/token_store.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemorySecureStorage extends FlutterSecureStorage {
  _InMemorySecureStorage() : super();

  final Map<String, String?> _store = <String, String?>{};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }
}

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

class _CapturingErrorHandler extends ErrorInterceptorHandler {
  bool resolved = false;
  final Completer<void> _completer = Completer<void>();

  Future<void> get completed => _completer.future;

  @override
  void resolve(Response<dynamic> response) {
    resolved = true;
    _completer.complete();
  }

  @override
  void next(DioException err) {
    _completer.complete();
  }
}

void main() {
  late AppDatabase db;
  late EtagStore etagStore;
  late TokenStore tokenStore;
  late EtagInterceptor interceptor;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    etagStore = EtagStore(db);
    tokenStore = TokenStore(_InMemorySecureStorage());
    interceptor = EtagInterceptor(etagStore, tokenStore);
    await tokenStore.write(
      'token-123',
      rememberMe: true,
      ttl: const Duration(hours: 1),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('persists etag and reuses it on subsequent requests', () async {
    final options = RequestOptions(
      path: '/user',
      method: 'GET',
      baseUrl: 'https://api.github.com',
    );
    final response = Response<Map<String, dynamic>>(
      requestOptions: options,
      statusCode: 200,
      data: const <String, dynamic>{},
      headers: Headers.fromMap(const <String, List<String>>{
        'etag': <String>['W/"abc123"'],
      }),
    );

    final responseHandler = _CompletingResponseHandler();
    interceptor.onResponse(response, responseHandler);
    await responseHandler.completed;

    final nextRequest = RequestOptions(
      path: '/user',
      method: 'GET',
      baseUrl: 'https://api.github.com',
    );
    final requestHandler = _CompletingRequestHandler();
    interceptor.onRequest(nextRequest, requestHandler);
    await requestHandler.completed;

    expect(nextRequest.headers['If-None-Match'], 'W/"abc123"');
  });

  test('converts 304 responses into cache hits', () async {
    final options = RequestOptions(
      path: '/events',
      method: 'GET',
      baseUrl: 'https://api.github.com',
    );
    final handler = _CapturingErrorHandler();
    final response = Response<void>(
      requestOptions: options,
      statusCode: 304,
    );

    final err = DioException(
      requestOptions: options,
      response: response,
      type: DioExceptionType.badResponse,
    );

    interceptor.onError(err, handler);
    await handler.completed;

    expect(handler.resolved, isTrue);
  });
}
