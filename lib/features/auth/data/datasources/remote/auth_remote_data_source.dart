import 'dart:async';

import 'package:devhub_gpt/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String name);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Stream<UserModel?> watchAuthState();
}

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  final List<UserModel> _users = [];
  UserModel? _current;
  final _controller = StreamController<UserModel?>.broadcast();

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final user = _users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('User not found'),
    );
    _current = user;
    _controller.add(_current);
    return user;
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final exists = _users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (exists) {
      throw Exception('Email already in use');
    }
    final user = UserModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      email: email,
      name: name,
      createdAt: DateTime.now(),
      isEmailVerified: false,
    );
    _users.add(user);
    _current = user;
    _controller.add(_current);
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _current = null;
    _controller.add(_current);
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // noop in mock
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (_current == null) throw Exception('Not authenticated');
    _current = _current!.copyWith(
      name: data['name'] as String? ?? _current!.name,
      avatarUrl: data['avatarUrl'] as String? ?? _current!.avatarUrl,
    );
    _controller.add(_current);
    return _current!;
  }

  @override
  Stream<UserModel?> watchAuthState() {
    return Stream<UserModel?>.multi((controller) {
      controller.add(_current);
      final sub = _controller.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
        cancelOnError: false,
      );
      controller.onCancel = sub.cancel;
    });
  }
}
