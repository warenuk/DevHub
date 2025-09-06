import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/auth/domain/repositories/auth_repository.dart';
import 'package:devhub_gpt/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepoOk implements AuthRepository {
  @override
  Future<Either<Failure, void>> resetPassword(String email) async => right(null);

  // Unused in these tests
  @override
  Future<Either<Failure, void>> signOut() async => right(null);
  @override
  Stream watchAuthState() => const Stream.empty();
  @override
  Future<Either<Failure, dynamic>> getCurrentUser() async => right(null);
  @override
  Future<Either<Failure, dynamic>> signInWithEmail(String email, String password) async => right(null);
  @override
  Future<Either<Failure, dynamic>> signUpWithEmail(String email, String password, String name) async => right(null);
  @override
  Future<Either<Failure, dynamic>> updateProfile(Map<String, dynamic> data) async => right(null);
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

