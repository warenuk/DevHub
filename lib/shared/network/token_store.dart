import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kPayloadKey = 'github_token_payload';
const _kLegacyTokenKey = 'github_token';
const Duration _kEphemeralTtl = Duration(hours: 12);
const Duration _kRememberedTtl = Duration(days: 30);
const Duration _kLegacyMigrationTtl = Duration(hours: 24);

class TokenPayload {
  const TokenPayload({
    required this.token,
    required this.expiresAt,
    required this.rememberMe,
  });

  factory TokenPayload.fromJson(Map<String, dynamic> json) {
    final expires = json['expiresAt'] as int?;
    return TokenPayload(
      token: json['token'] as String? ?? '',
      expiresAt: expires != null
          ? DateTime.fromMillisecondsSinceEpoch(expires, isUtc: true).toLocal()
          : DateTime.now().subtract(const Duration(days: 1)),
      rememberMe: json['rememberMe'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'token': token,
    'expiresAt': expiresAt.toUtc().millisecondsSinceEpoch,
    'rememberMe': rememberMe,
  };

  final String token;
  final DateTime expiresAt;
  final bool rememberMe;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remaining => expiresAt.difference(DateTime.now());
}

class TokenStore {
  TokenStore(this._storage);
  final FlutterSecureStorage _storage;
  TokenPayload? _cached;

  Future<TokenPayload?> readPayload() async {
    final cached = _cached;
    if (cached != null && !cached.isExpired) {
      return cached;
    }

    final payload = await _loadFromStorage();
    if (payload == null) {
      _cached = null;
      return null;
    }

    if (payload.isExpired) {
      await clear();
      return null;
    }

    _cached = payload;
    return payload;
  }

  Future<String?> read() async {
    final payload = await readPayload();
    return payload?.token;
  }

  Future<void> write(
    String token, {
    required bool rememberMe,
    Duration? ttl,
  }) async {
    final duration = ttl ?? (rememberMe ? _kRememberedTtl : _kEphemeralTtl);
    final expiresAt = DateTime.now().add(duration);
    final payload = TokenPayload(
      token: token,
      expiresAt: expiresAt,
      rememberMe: rememberMe,
    );
    _cached = payload;
    await _storage.write(
      key: _kPayloadKey,
      value: jsonEncode(payload.toJson()),
    );
    try {
      await _storage.delete(key: _kLegacyTokenKey);
    } catch (_) {
      // Ignore missing plugin / platform errors in tests.
    }
  }

  Future<void> clear() async {
    _cached = null;
    try {
      await _storage.delete(key: _kPayloadKey);
    } catch (_) {
      // Ignore storage backend errors in tests.
    }
    try {
      await _storage.delete(key: _kLegacyTokenKey);
    } catch (_) {
      // Ignore storage backend errors in tests.
    }
  }

  Duration defaultTtl({required bool rememberMe}) =>
      rememberMe ? _kRememberedTtl : _kEphemeralTtl;

  Future<TokenPayload?> _loadFromStorage() async {
    final raw = await _storage.read(key: _kPayloadKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final payload = TokenPayload.fromJson(decoded);
        if (payload.token.isEmpty) {
          return null;
        }
        return payload;
      } catch (_) {
        // Corrupted payload, wipe it.
        await _storage.delete(key: _kPayloadKey);
      }
    }

    final legacy = await _storage.read(key: _kLegacyTokenKey);
    if (legacy == null || legacy.isEmpty) {
      return null;
    }

    final migrated = TokenPayload(
      token: legacy,
      expiresAt: DateTime.now().add(_kLegacyMigrationTtl),
      rememberMe: true,
    );
    await _storage.write(
      key: _kPayloadKey,
      value: jsonEncode(migrated.toJson()),
    );
    try {
      await _storage.delete(key: _kLegacyTokenKey);
    } catch (_) {
      // Ignore storage backend errors in tests.
    }
    return migrated;
  }
}
