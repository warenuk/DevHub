import 'dart:math';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = 3, this.baseDelay = const Duration(milliseconds: 300)});
  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;
  static const _idem = {'GET','HEAD','OPTIONS'};

  bool _shouldRetry(DioException e) {
    final sc = e.response?.statusCode;
    if (sc == null) return true;
    if (sc == 408 || sc == 425 || sc == 429) return true;
    if (sc >= 500 && sc < 600) return true;
    return false;
  }

  Duration _retryAfterDelay(Response? r, int attempt) {
    final ra = r?.headers.value('retry-after');
    if (ra != null) {
      final s = int.tryParse(ra);
      if (s != null && s >= 0) return Duration(seconds: s);
    }
    final expoMs = baseDelay.inMilliseconds * pow(2, attempt).toInt();
    final jitterMs = Random().nextInt(120);
    return Duration(milliseconds: expoMs + jitterMs);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler h) async {
    final req = err.requestOptions;
    if (!_idem.contains(req.method.toUpperCase()) || !_shouldRetry(err)) {
      return h.next(err);
    }
    final attempt = (req.extra['retry_attempt'] as int? ?? 0) + 1;
    if (attempt > maxRetries) return h.next(err);

    await Future.delayed(_retryAfterDelay(err.response, attempt));
    try {
      req.extra['retry_attempt'] = attempt;
      final newResp = await _dio.fetch(req);
      return h.resolve(newResp);
    } catch (_) {
      return h.next(err);
    }
  }
}
