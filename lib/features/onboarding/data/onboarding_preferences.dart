import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists onboarding completion status locally.
class OnboardingPreferences {
  OnboardingPreferences(this._storage);

  static const String _key = 'onboarding_completed_v1';
  final FlutterSecureStorage _storage;

  Future<bool> isCompleted() async {
    final value = await _storage.read(key: _key);
    return value == 'true';
  }

  Future<void> markCompleted() async {
    await _storage.write(key: _key, value: 'true');
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
