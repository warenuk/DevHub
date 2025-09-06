import 'package:devhub_gpt/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> clear();
}

/// In-memory implementation placeholder. Later can be replaced by Hive.
class MemoryAuthLocalDataSource implements AuthLocalDataSource {
  UserModel? _cached;

  @override
  Future<void> cacheUser(UserModel user) async {
    _cached = user;
  }

  @override
  Future<UserModel?> getLastUser() async => _cached;

  @override
  Future<void> clear() async {
    _cached = null;
  }
}
