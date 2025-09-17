import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/shared/config/env.dart';
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (Env.verboseHttpLogs) {
      AppLogger.info('[HTTP] --> ${options.method} ${options.uri}', area: 'http');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (Env.verboseHttpLogs) {
      AppLogger.info(
        '[HTTP] <-- ${response.statusCode} ${response.requestOptions.uri}',
        area: 'http',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      '[HTTP] !! ${err.requestOptions.uri} ${err.message}',
      error: err,
      stackTrace: err.stackTrace,
      area: 'http',
    );
    handler.next(err);
  }
}
