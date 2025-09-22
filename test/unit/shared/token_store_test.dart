import 'dart:convert';

import 'package:devhub_gpt/shared/network/token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSecureStorage extends FlutterSecureStorage {
  _FakeSecureStorage() : super();

  final Map<String, String?> _store = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    MacOsOptions? mOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    return _store[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    MacOsOptions? mOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    _store[key] = value;
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    MacOsOptions? mOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    _store.remove(key);
  }
}

void main() {
  test('returns token until TTL expires then clears', () async {
    final storage = _FakeSecureStorage();
    var now = DateTime.utc(2024, 1, 1, 12);
    final store = TokenStore(storage, now: () => now);

    await store.write('abc', ttl: const Duration(hours: 1));
    expect(await store.read(), 'abc');

    now = now.add(const Duration(hours: 2));
    expect(await store.read(), isNull);
    expect(await storage.read(key: 'github_token_payload'), isNull);
  });

  test('migrates legacy key to payload with short TTL', () async {
    final storage = _FakeSecureStorage();
    await storage.write(key: 'github_token', value: 'legacy-token');
    var now = DateTime.utc(2024, 5, 10, 8);
    final store = TokenStore(storage, now: () => now);

    expect(await store.read(), 'legacy-token');
    final raw = await storage.read(key: 'github_token_payload');
    expect(raw, isNotNull);
    final decoded = jsonDecode(raw!) as Map<String, dynamic>;
    expect(decoded['token'], 'legacy-token');
    expect(decoded['expiresAt'], isNotNull);

    now = now.add(const Duration(hours: 2));
    expect(await store.read(), isNull);
  });

  test('writes persistent token when ttl is null', () async {
    final storage = _FakeSecureStorage();
    final store = TokenStore(storage, now: DateTime.now);

    await store.write('permanent');
    final raw = await storage.read(key: 'github_token_payload');
    expect(raw, isNotNull);
    final decoded = jsonDecode(raw!) as Map<String, dynamic>;
    expect(decoded['token'], 'permanent');
    expect(decoded.containsKey('expiresAt'), isFalse);
  });
}
