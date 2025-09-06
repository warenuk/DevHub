import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart' as domain;
import 'package:devhub_gpt/features/auth/domain/repositories/auth_repository.dart';
import 'package:devhub_gpt/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepoOk implements AuthRepository {
  @override
  Future<Either<Failure, void>> resetPassword(String email) async =>
      right(null);

  // Unused in these tests
  @override
  Future<Either<Failure, void>> signOut() async => right(null);
  @override
  Stream<domain.User?> watchAuthState() => const Stream.empty();
  @override
  Future<Either<Failure, domain.User?>> getCurrentUser() async => right(null);
  @override
  Future<Either<Failure, domain.User>> signInWithEmail(
    String email,
    String password,
  ) async =>
      right(
        domain.User(
          id: '1',
          email: email,
          name: 'Tester',
          createdAt: DateTime(2024, 1, 1),
          isEmailVerified: true,
        ),
      );
  @override
  Future<Either<Failure, domain.User>> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async =>
      right(
        domain.User(
          id: '2',
          email: email,
          name: name,
          createdAt: DateTime(2024, 1, 1),
          isEmailVerified: false,
        ),
      );
  @override
  Future<Either<Failure, domain.User>> updateProfile(
    Map<String, dynamic> data,
  ) async =>
      right(
        domain.User(
          id: '1',
          email: 'test@example.com',
          name: data['name'] as String? ?? 'Tester',
          createdAt: DateTime(2024, 1, 1),
          isEmailVerified: true,
        ),
      );
}

void main() {
  test('returns ValidationFailure on invalid email', () async {
    final usecase = ResetPasswordUseCase(_RepoOk());
    final res = await usecase(const ResetPasswordParams('not-an-email'));
    expect(res, isA<Left<Failure, void>>());
  });

  test('returns Right(null) on valid email', () async {
    final usecase = ResetPasswordUseCase(_RepoOk());
    final res = await usecase(const ResetPasswordParams('user@example.com'));
    expect(res.isRight(), true);
  });
}
