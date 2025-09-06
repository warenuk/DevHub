import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart';
import 'package:devhub_gpt/features/auth/domain/repositories/auth_repository.dart';
import 'package:devhub_gpt/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepoOk implements AuthRepository {
  @override
  Future<Either<Failure, User>> updateProfile(Map<String, dynamic> data) async {
    return right(
      User(
        id: '1',
        email: 'test@example.com',
        name: data['name'] as String? ?? 'Tester',
        createdAt: DateTime(2024, 1, 1),
        isEmailVerified: true,
      ),
    );
  }

  // Unused in these tests
  @override
  Future<Either<Failure, void>> signOut() async => right(null);
  @override
  Stream<User?> watchAuthState() => const Stream.empty();
  @override
  Future<Either<Failure, User?>> getCurrentUser() async => right(null);
  @override
  Future<Either<Failure, User>> signInWithEmail(
    String email,
    String password,
  ) async =>
      right(
        User(
          id: '1',
          email: email,
          name: 'Tester',
          createdAt: DateTime(2024, 1, 1),
          isEmailVerified: true,
        ),
      );
  @override
  Future<Either<Failure, User>> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async =>
      right(
        User(
          id: '2',
          email: email,
          name: name,
          createdAt: DateTime(2024, 1, 1),
          isEmailVerified: false,
        ),
      );
  @override
  Future<Either<Failure, void>> resetPassword(String email) async =>
      right(null);
}

void main() {
  test('returns updated User from repository', () async {
    final usecase = UpdateProfileUseCase(_RepoOk());
    final res = await usecase(const UpdateProfileParams({'name': 'Alice'}));
    expect(res.isRight(), true);
    expect(res.getOrElse(() => throw '').name, 'Alice');
  });
}
