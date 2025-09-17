import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore(this._storage);
  final FlutterSecureStorage _storage;
  String? _mem;

  Future<String?> read() async =>
      _mem ??= await _storage.read(key: 'github_token');
  Future<void> write(String token) async {
    _mem = token;
    await _storage.write(key: 'github_token', value: token);
  }

  Future<void> clear() async {
    _mem = null;
    await _storage.delete(key: 'github_token');
  }
}
