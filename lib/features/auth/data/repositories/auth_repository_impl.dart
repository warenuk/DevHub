import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:devhub_gpt/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:devhub_gpt/features/auth/data/models/user_model.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart' as domain;
import 'package:devhub_gpt/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Either<Failure, domain.User>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final model = await _remote.signInWithEmail(email, password);
      await _local.cacheUser(model);
      return right(
        model.toDomain(),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.User>> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final model = await _remote.signUpWithEmail(email, password, name);
      await _local.cacheUser(model);
      return right(
        model.toDomain(),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      await _local.clear();
      return right(
        null,
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<domain.User?> watchAuthState() {
    return _remote
        .watchAuthState()
        .map((UserModel? model) => model?.toDomain());
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _remote.resetPassword(email);
      return right(
        null,
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.User>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await _remote.updateProfile(data);
      await _local.cacheUser(model);
      return right(model.toDomain());
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.User?>> getCurrentUser() async {
    try {
      final cached = await _local.getLastUser();
      return right(cached?.toDomain());
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }
}
