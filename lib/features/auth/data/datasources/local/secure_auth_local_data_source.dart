import 'dart:convert';

import 'package:devhub_gpt/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:devhub_gpt/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureAuthLocalDataSource implements AuthLocalDataSource {
  SecureAuthLocalDataSource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'auth_user';
  final FlutterSecureStorage _storage;

  @override
  Future<void> cacheUser(UserModel user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _storage.write(key: _key, value: jsonStr);
  }

  @override
  Future<UserModel?> getLastUser() async {
    final jsonStr = await _storage.read(key: _key);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return UserModel.fromJson(map);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
