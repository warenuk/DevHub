import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/core/utils/validators.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart';
import 'package:devhub_gpt/features/auth/domain/repositories/auth_repository.dart';

class SignInParams {
  const SignInParams({required this.email, required this.password});
  final String email;
  final String password;
}

class SignInUseCase {
  const SignInUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, User>> call(SignInParams params) async {
    if (!Validators.isValidEmail(params.email)) {
      return left(const ValidationFailure('Invalid email'));
    }
    if (params.password.trim().length < 6) {
      return left(const ValidationFailure('Password too short'));
    }
    return _repository.signInWithEmail(params.email, params.password);
  }
}
