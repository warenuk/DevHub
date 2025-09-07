import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart';

/// Контракт доменного шару для аутентифікації.
///
/// Повертає результати у вигляді `Either<Failure, T>` без кидання винятків
/// назовні домену. Дані завжди представлені доменною сутністю [User].
abstract class AuthRepository {
  /// Вхід з email/паролем.
  Future<Either<Failure, User>> signInWithEmail(String email, String password);

  /// Реєстрація користувача з email/паролем/іменем.
  Future<Either<Failure, User>> signUpWithEmail(
    String email,
    String password,
    String name,
  );

  /// Вихід користувача та очищення локального кешу.
  Future<Either<Failure, void>> signOut();

  /// Реактивні зміни auth‑стану (null якщо користувач розлогінений).
  Stream<User?> watchAuthState();

  /// Відправка листа для скидання пароля.
  Future<Either<Failure, void>> resetPassword(String email);

  /// Оновлення профілю поточного користувача (ім'я/аватар тощо).
  Future<Either<Failure, User>> updateProfile(Map<String, dynamic> data);

  /// Повертає поточного користувача з локального кешу (або null).
  Future<Either<Failure, User?>> getCurrentUser();
}
