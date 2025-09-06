import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart';
import 'package:devhub_gpt/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileParams {
  const UpdateProfileParams(this.data);
  final Map<String, dynamic> data;
}

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, User>> call(UpdateProfileParams params) {
    return _repository.updateProfile(params.data);
  }
}
