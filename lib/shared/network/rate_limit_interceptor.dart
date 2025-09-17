import 'dart:math';
import 'package:dio/dio.dart';

/// Simple per-host rate limiting + jitter.
/// Ensures a minimum delay between consecutive requests to the same host.
class RateLimitInterceptor extends Interceptor {
  RateLimitInterceptor({
    this.minDelay = const Duration(milliseconds: 300),
    this.maxJitter = const Duration(milliseconds: 120),
    this.hostPredicate,
  });

  final Duration minDelay;
  final Duration maxJitter;
  final bool Function(Uri uri)? hostPredicate;

  DateTime? _lastEmission;
  final _rnd = Random();

  Duration _jitter() {
    if (maxJitter <= Duration.zero) return Duration.zero;
    final micros = maxJitter.inMicroseconds;
    final pick = _rnd.nextInt(micros + 1);
    return Duration(microseconds: pick);
  }

  Future<void> _respectBackpressure() async {
    final now = DateTime.now();
    final last = _lastEmission;
    if (last == null) {
      _lastEmission = now;
      return;
    }
    final elapsed = now.difference(last);
    final need = minDelay - elapsed;
    final delay = need > Duration.zero ? need + _jitter() : Duration.zero;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    _lastEmission = DateTime.now();
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler,) async {
    try {
      final ok = hostPredicate?.call(options.uri) ?? true;
      if (ok) {
        await _respectBackpressure();
      }
    } catch (_) {}
    handler.next(options);
  }
}
