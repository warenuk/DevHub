import 'package:devhub_gpt/core/constants/firebase_flags.dart';
import 'package:devhub_gpt/features/auth/data/datasources/local/secure_auth_local_data_source.dart';
import 'package:devhub_gpt/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:devhub_gpt/features/auth/data/datasources/remote/firebase_auth_data_source.dart';
import 'package:devhub_gpt/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart';
import 'package:devhub_gpt/features/auth/domain/repositories/auth_repository.dart';
import 'package:devhub_gpt/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:devhub_gpt/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:devhub_gpt/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:devhub_gpt/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.read(secureStorageProvider);
  final local = SecureAuthLocalDataSource(storage: storage);
  if (kUseFirebaseAuth && isFirebaseInitialized) {
    try {
      final remote = FirebaseAuthRemoteDataSource(fb.FirebaseAuth.instance);
      return AuthRepositoryImpl(remote: remote, local: local);
    } on fb.FirebaseException catch (e, stackTrace) {
      debugPrint(
        'FirebaseAuth not available (${e.code}). Falling back to mock auth for tests.',
      );
      debugPrint(stackTrace.toString());
    } on Object catch (error, stackTrace) {
      debugPrint(
        'FirebaseAuth bootstrap failed. Using mock auth instead: '
        '${error.toString()}',
      );
      debugPrint(stackTrace.toString());
    }
  }
  if (!isFirebaseInitialized && kUseFirebaseAuth) {
    debugPrint(
      'Firebase has not finished initializing yet. Falling back to mock '
      'auth implementation.',
    );
  }
  final remote = MockAuthRemoteDataSource();
  return AuthRepositoryImpl(remote: remote, local: local);
});

final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.watchAuthState();
});

final currentUserProvider = FutureProvider<User?>((ref) async {
  // 1) Пріоритетно беремо live-авторизацію зі стріму
  final authAsync = ref.watch(authStateProvider);
  final liveUser = authAsync.maybeWhen(data: (u) => u, orElse: () => null);
  if (liveUser != null) return liveUser;

  // 2) Якщо live ще недоступний або null — падаємо у кеш домену
  final repo = ref.watch(authRepositoryProvider);
  final result = await GetCurrentUserUseCase(repo).call();
  return result.fold((l) => null, (r) => r);
});

class AuthController extends StateNotifier<AsyncValue<User?>> {
  AuthController(this._repository) : super(const AsyncValue.data(null));
  final AuthRepository _repository;

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await SignInUseCase(
      _repository,
    ).call(SignInParams(email: email, password: password));
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final result = await SignOutUseCase(_repository).call();
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    final result = await SignUpUseCase(
      _repository,
    ).call(SignUpParams(email: email, password: password, name: name));
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});
