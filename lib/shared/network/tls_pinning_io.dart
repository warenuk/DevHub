import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/shared/config/env.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// IO implementation: certificate fingerprint pinning using Base64(SHA-256(cert DER)).
/// Provide pins via --dart-define: TLS_PIN_CERT_SHA256 and optional TLS_PIN_CERT_SHA256_2.
void applyTlsPinningIfEnabled(Dio dio, Uri baseUri) {
  if (!Env.enableTlsPinning) return;
  final host =
      (Env.tlsPinHost.isNotEmpty ? Env.tlsPinHost : baseUri.host).toLowerCase();
  const pin1 = Env.tlsPinCertSha256;
  const pin2 = Env.tlsPinCertSha256Backup;
  if (host.isEmpty || (pin1.isEmpty && pin2.isEmpty)) {
    AppLogger.error(
      'TLS pinning enabled, but no host/pins provided. Skipping.',
      area: 'tls',
    );
    return;
  }
  final adapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String certHost, int port) {
        // Only enforce for the target host (SNI may differ in proxies; use exact match).
        if (certHost.toLowerCase() != host) return true;
        try {
          // Extract DER from PEM: remove header/footer/newlines
          final pem = cert.pem;
          final normalized = pem.replaceAll(
            RegExp(
              r'-----BEGIN CERTIFICATE-----|-----END CERTIFICATE-----|\s+',
            ),
            '',
          );
          final der = base64.decode(normalized);
          final digest = crypto.sha256.convert(der).bytes;
          final b64 = base64.encode(digest);
          final ok = (b64 == pin1) || (pin2.isNotEmpty && b64 == pin2);
          if (!ok) {
            AppLogger.error(
              'TLS pin mismatch for $certHost: got=${b64.substring(0, 8)}..., expected one of pins',
              area: 'tls',
            );
          } else {
            AppLogger.info('TLS pin OK for $certHost', area: 'tls');
          }
          return ok;
        } catch (e, s) {
          AppLogger.error(
            'TLS pin check failed',
            error: e,
            stackTrace: s,
            area: 'tls',
          );
          return false;
        }
      };
      return client;
    },
  );
  dio.httpClientAdapter = adapter;
}
