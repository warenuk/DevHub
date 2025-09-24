import 'dart:math';

import 'package:dio/dio.dart';

/// Simple per-host rate limiting + jitter with basic heuristics for
/// `Retry-After` and GitHub's rate-limit headers.
class RateLimitInterceptor extends Interceptor {
  RateLimitInterceptor({
    this.minDelay = const Duration(milliseconds: 300),
    this.maxJitter = const Duration(milliseconds: 120),
    this.hostPredicate,
  });

  final Duration minDelay;
  final Duration maxJitter;
  final bool Function(Uri uri)? hostPredicate;

  final Map<String, DateTime> _lastEmission = <String, DateTime>{};
  final Map<String, DateTime> _hostLocks = <String, DateTime>{};
  final _rnd = Random();

  Duration _jitter() {
    if (maxJitter <= Duration.zero) return Duration.zero;
    final micros = maxJitter.inMicroseconds;
    final pick = _rnd.nextInt(micros + 1);
    return Duration(microseconds: pick);
  }

  Future<void> _respectBackpressure(Uri uri) async {
    final host = uri.host;
    final now = DateTime.now();
    final lock = _hostLocks[host];
    if (lock != null && now.isBefore(lock)) {
      await Future<void>.delayed(lock.difference(now));
    }

    final last = _lastEmission[host];
    if (last == null) {
      _lastEmission[host] = DateTime.now();
      return;
    }
    final elapsed = now.difference(last);
    final need = minDelay - elapsed;
    final delay = need > Duration.zero ? need + _jitter() : Duration.zero;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    _lastEmission[host] = DateTime.now();
  }

  void _scheduleLock(String host, Duration delay) {
    if (delay <= Duration.zero) return;
    _hostLocks[host] = DateTime.now().add(delay);
  }

  Duration? _parseRetryAfter(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final secondsInt = int.tryParse(raw);
    if (secondsInt != null) {
      final clamped = secondsInt.clamp(1, 300);
      return Duration(seconds: clamped.toInt());
    }

    final secondsDouble = double.tryParse(raw);
    if (secondsDouble != null) {
      final millis = (secondsDouble * 1000).round();
      if (millis > 0) return Duration(milliseconds: millis);
      return null;
    }

    final date = DateTime.tryParse(raw);
    if (date != null) {
      final diff = date.difference(DateTime.now());
      if (diff > Duration.zero) return diff;
    }
    return null;
  }

  void _handleRateLimitHeaders(Response<dynamic>? response) {
    final resp = response;
    if (resp == null) return;
    final host = resp.requestOptions.uri.host;
    final headers = resp.headers;

    final retryAfter = _parseRetryAfter(headers.value('retry-after'));
    if (retryAfter != null) {
      _scheduleLock(host, retryAfter);
      return;
    }

    final remaining = headers.value('x-ratelimit-remaining');
    if (remaining != null && int.tryParse(remaining) == 0) {
      final reset = headers.value('x-ratelimit-reset');
      Duration? untilReset;
      final rawReset = reset ?? '';
      final resetEpoch = int.tryParse(rawReset) ?? double.tryParse(rawReset);
      if (resetEpoch != null) {
        final micros = (resetEpoch * 1000000).round();
        final resetTime = DateTime.fromMicrosecondsSinceEpoch(
          micros,
          isUtc: true,
        ).toLocal();
        final diff = resetTime.difference(DateTime.now());
        if (diff > Duration.zero) untilReset = diff;
      }
      _scheduleLock(host, untilReset ?? const Duration(seconds: 30));
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final ok = hostPredicate?.call(options.uri) ?? true;
      if (ok) {
        await _respectBackpressure(options.uri);
      }
    } catch (_) {}
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _handleRateLimitHeaders(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _handleRateLimitHeaders(err.response);
    handler.next(err);
  }
}
