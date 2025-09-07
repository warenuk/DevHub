import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:devhub_gpt/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:devhub_gpt/features/auth/data/models/user_model.dart';
import 'package:devhub_gpt/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _AlwaysThrowRemote implements AuthRemoteDataSource {
  @override
  Future<UserModel> signInWithEmail(String email, String password) {
    throw Exception('boom');
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String name,
  ) {
    throw Exception('boom');
  }

  @override
  Future<void> signOut() => throw Exception('boom');

  @override
  Future<void> resetPassword(String email) => throw Exception('boom');

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) {
    throw Exception('boom');
  }

  @override
  Stream<UserModel?> watchAuthState() => const Stream.empty();
}

void main() {
  group('AuthRepositoryImpl logging smoke', () {
    late AuthRepositoryImpl repo;
    setUp(() {
      repo = AuthRepositoryImpl(
        remote: _AlwaysThrowRemote(),
        local: MemoryAuthLocalDataSource(),
      );
    });

    test('signInWithEmail returns Left(ServerFailure) on exception', () async {
      final res = await repo.signInWithEmail('a@b.c', 'pwd');
      expect(res.isLeft(), true);
      res.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('expected Left'),
      );
    });

    test('signOut returns Left(ServerFailure) on exception', () async {
      final res = await repo.signOut();
      expect(res.isLeft(), true);
    });
  });
}
