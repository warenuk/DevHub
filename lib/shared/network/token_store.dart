import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore(
    this._storage, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final FlutterSecureStorage _storage;
  final DateTime Function() _now;

  static const _payloadKey = 'github_token_payload';
  static const _legacyKey = 'github_token';

  Map<String, dynamic>? _cached;

  Future<String?> read() async {
    final payload = _cached ??= await _readPayload();
    if (payload == null) return null;

    final expiresAt = payload['expiresAt'] as int?;
    if (expiresAt != null && expiresAt <= _now().millisecondsSinceEpoch) {
      await clear();
      return null;
    }
    final token = payload['token'] as String?;
    if (token == null || token.isEmpty) {
      await clear();
      return null;
    }
    return token;
  }

  Future<void> write(String token, {Duration? ttl}) async {
    final payload = <String, dynamic>{'token': token};
    if (ttl != null && !ttl.isNegative && ttl != Duration.zero) {
      payload['expiresAt'] = _now().add(ttl).millisecondsSinceEpoch;
    }
    _cached = payload;
    await _storage.write(key: _payloadKey, value: jsonEncode(payload));
    await _storage.delete(key: _legacyKey);
  }

  Future<void> clear() async {
    _cached = null;
    await _storage.delete(key: _payloadKey);
    await _storage.delete(key: _legacyKey);
  }

  Future<Map<String, dynamic>?> _readPayload() async {
    final raw = await _storage.read(key: _payloadKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        await _storage.delete(key: _payloadKey);
      }
    }

    final legacy = await _storage.read(key: _legacyKey);
    if (legacy != null && legacy.isNotEmpty) {
      await _storage.delete(key: _legacyKey);
      final payload = {
        'token': legacy,
        'expiresAt':
            _now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
      };
      await _storage.write(key: _payloadKey, value: jsonEncode(payload));
      return payload;
    }
    return null;
  }
}
