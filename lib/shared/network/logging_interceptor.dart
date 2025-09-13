import 'package:dio/dio.dart';
import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/shared/config/env.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    if (Env.verboseHttpLogs) {
      AppLogger.info('[HTTP] --> ${o.method} ${o.uri}', area: 'http');
    }
    h.next(o);
  }

  @override
  void onResponse(Response r, ResponseInterceptorHandler h) {
    if (Env.verboseHttpLogs) {
      AppLogger.info('[HTTP] <-- ${r.statusCode} ${r.requestOptions.uri}', area: 'http');
    }
    h.next(r);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) {
    AppLogger.error('[HTTP] !! ${e.requestOptions.uri} ${e.message}', error: e, stackTrace: e.stackTrace, area: 'http');
    h.next(e);
  }
}
