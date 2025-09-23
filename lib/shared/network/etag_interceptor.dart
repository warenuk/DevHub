import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:devhub_gpt/shared/network/etag_store.dart';
import 'package:devhub_gpt/shared/network/token_store.dart';
import 'package:dio/dio.dart';

/// Interceptor that adds `If-None-Match` from local DB and persists `ETag` from responses.
class EtagInterceptor extends Interceptor {
  EtagInterceptor(this._store, this._tokenStore);
  final EtagStore _store;
  final TokenStore _tokenStore;

  Future<String> _scopeHash() async {
    final token = await _tokenStore.read();
    if (token == null || token.isEmpty) return 'anonymous';
    return crypto.sha256.convert(utf8.encode(token)).toString();
  }

  // Compose a stable resource key for caching per-scope and endpoint path.
  Future<String> _resourceKey(RequestOptions options) async {
    final scope = await _scopeHash();
    // Use path without query; include host to be explicit (though we guard host).
    final path = options.uri.path;
    return 'gh:${options.uri.host}:$path:$scope';
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      if (options.method.toUpperCase() == 'GET' &&
          options.uri.host == 'api.github.com') {
        final key = await _resourceKey(options);
        final etag = await _store.get(key);
        if (etag != null && etag.isNotEmpty) {
          options.headers['If-None-Match'] = etag;
        }
      }
    } catch (_) {}
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    try {
      final req = response.requestOptions;
      if (req.method.toUpperCase() == 'GET' &&
          req.uri.host == 'api.github.com') {
        final key = await _resourceKey(req);
        final etag = response.headers['etag']?.first;
        if (etag != null && etag.isNotEmpty) {
          await _store.upsert(key, etag);
        } else {
          await _store.touch(key);
        }
      }
    } catch (_) {}
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Treat 304 as a non-error: just pass through so upper layer can use cached data.
    if (err.response?.statusCode == 304) {
      return handler.resolve(err.response!);
    }
    handler.next(err);
  }
}
