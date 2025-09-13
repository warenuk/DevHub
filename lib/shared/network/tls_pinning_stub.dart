import 'package:dio/dio.dart';
import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/shared/config/env.dart';

/// Web & other non-IO platforms: no-op.
void applyTlsPinningIfEnabled(Dio dio, Uri baseUri) {
  if (Env.enableTlsPinning) {
    AppLogger.info('TLS pinning requested but not supported on this platform (web). Host: \${baseUri.host}', area: 'tls');
  }
}
