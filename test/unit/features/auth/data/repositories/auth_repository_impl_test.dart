import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:devhub_gpt/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:devhub_gpt/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockAuthRemoteDataSource remote;
  late MemoryAuthLocalDataSource local;
  late AuthRepositoryImpl repo;

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MemoryAuthLocalDataSource();
    repo = AuthRepositoryImpl(remote: remote, local: local);
  });

  test('signUp caches user and returns Right(user)', () async {
    final result = await repo.signUpWithEmail('a@b.com', 'secret12', 'Alice');
    expect(result.isRight(), true);
    final current = await local.getLastUser();
    expect(current?.email, 'a@b.com');
  });

  test('signIn unknown user returns Left(ServerFailure)', () async {
    final result = await repo.signInWithEmail('x@y.com', 'secret12');
    expect(result, isA<Left<Failure, dynamic>>());
  });

  test('signIn known user caches and returns Right(user)', () async {
    await repo.signUpWithEmail('a@b.com', 'secret12', 'Alice');
    await repo.signOut();
    final result = await repo.signInWithEmail('a@b.com', 'secret12');
    expect(result.isRight(), true);
    final cached = await local.getLastUser();
    expect(cached?.email, 'a@b.com');
  });

  test('getCurrentUser returns Right(null) when no cache', () async {
    final result = await repo.getCurrentUser();
    expect(result.isRight(), true);
    expect(result.getOrElse(() => null), isNull);
  });

  test('signOut clears cache', () async {
    await repo.signUpWithEmail('a@b.com', 'secret12', 'Alice');
    await repo.signOut();
    final current = await local.getLastUser();
    expect(current, isNull);
  });
}
