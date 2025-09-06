import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/core/utils/validators.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart';
import 'package:devhub_gpt/features/auth/domain/repositories/auth_repository.dart';

class SignUpParams {
  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
  final String email;
  final String password;
  final String name;
}

class SignUpUseCase {
  const SignUpUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, User>> call(SignUpParams params) async {
    if (!Validators.isValidEmail(params.email)) {
      return left(const ValidationFailure('Invalid email'));
    }
    if (params.password.trim().length < 6) {
      return left(const ValidationFailure('Password too short'));
    }
    if (!Validators.isNonEmpty(params.name)) {
      return left(const ValidationFailure('Name is required'));
    }
    return _repository.signUpWithEmail(
      params.email,
      params.password,
      params.name,
    );
  }
}
