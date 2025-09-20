import 'package:devhub_gpt/shared/network/token_store.dart';
import 'package:dio/dio.dart';

typedef ShouldAttach = bool Function(Uri uri);

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._store, {required this.shouldAttach});
  final TokenStore _store;
  final ShouldAttach shouldAttach;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (shouldAttach(options.uri)) {
      final token = await _store.read();
      if (token != null && token.isNotEmpty) {
        options.headers.putIfAbsent('Authorization', () => 'Bearer $token');
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    if (is401 && shouldAttach(err.requestOptions.uri)) {
      await _store.clear();
    }
    handler.next(err);
  }
}
