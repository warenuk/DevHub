import 'package:devhub_gpt/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:devhub_gpt/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:devhub_gpt/features/auth/data/datasources/remote/firebase_auth_data_source.dart';
import 'package:devhub_gpt/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart';
import 'package:devhub_gpt/features/auth/domain/repositories/auth_repository.dart';
import 'package:devhub_gpt/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:devhub_gpt/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:devhub_gpt/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:devhub_gpt/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Використовуємо Firebase за замовчуванням
const kUseFirebase = bool.fromEnvironment('USE_FIREBASE', defaultValue: true);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final local = MemoryAuthLocalDataSource();
  if (kUseFirebase) {
    final remote = FirebaseAuthRemoteDataSource(fb.FirebaseAuth.instance);
    return AuthRepositoryImpl(remote: remote, local: local);
  } else {
    final remote = MockAuthRemoteDataSource();
    return AuthRepositoryImpl(remote: remote, local: local);
  }
});

final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.watchAuthState();
});

final currentUserProvider = FutureProvider<User?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final result = await GetCurrentUserUseCase(repo).call();
  return result.fold((l) => null, (r) => r);
});

class AuthController extends StateNotifier<AsyncValue<User?>> {
  AuthController(this._repository) : super(const AsyncValue.data(null));
  final AuthRepository _repository;

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await SignInUseCase(_repository).call(
      SignInParams(email: email, password: password),
    );
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
    final result = await SignUpUseCase(_repository).call(
      SignUpParams(email: email, password: password, name: name),
    );
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
