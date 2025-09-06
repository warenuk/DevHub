import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmail(String email, String password);
  Future<Either<Failure, User>> signUpWithEmail(
    String email,
    String password,
    String name,
  );
  Future<Either<Failure, void>> signOut();
  Stream<User?> watchAuthState();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, User>> updateProfile(Map<String, dynamic> data);
  Future<Either<Failure, User?>> getCurrentUser();
}
