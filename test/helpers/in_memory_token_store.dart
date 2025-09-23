import 'package:devhub_gpt/shared/network/token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InMemoryTokenStore extends TokenStore {
  InMemoryTokenStore() : super(const FlutterSecureStorage());

  TokenPayload? _payload;

  @override
  Future<TokenPayload?> readPayload() async {
    final payload = _payload;
    if (payload == null) return null;
    if (payload.isExpired) {
      _payload = null;
      return null;
    }
    return payload;
  }

  @override
  Future<String?> read() async {
    final payload = await readPayload();
    return payload?.token;
  }

  @override
  Future<void> write(
    String token, {
    required bool rememberMe,
    Duration? ttl,
  }) async {
    final expiresIn = ttl ?? super.defaultTtl(rememberMe: rememberMe);
    _payload = TokenPayload(
      token: token,
      expiresAt: DateTime.now().add(expiresIn),
      rememberMe: rememberMe,
    );
  }

  @override
  Future<void> clear() async {
    _payload = null;
  }
}
