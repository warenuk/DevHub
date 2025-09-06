import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/core/utils/validators.dart';
import 'package:devhub_gpt/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordParams {
  const ResetPasswordParams(this.email);
  final String email;
}

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    if (!Validators.isValidEmail(params.email)) {
      return left(const ValidationFailure('Invalid email'));
    }
    return _repository.resetPassword(params.email);
  }
}
