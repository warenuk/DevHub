import 'dart:async';

import 'package:devhub_gpt/features/auth/domain/entities/user.dart' as domain;
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/auth/domain/repositories/auth_repository.dart';
import 'package:devhub_gpt/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:devhub_gpt/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:devhub_gpt/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:devhub_gpt/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  domain.User makeUser() => domain.User(
        id: 'u1',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime(2024, 1, 1),
        isEmailVerified: true,
      );

  testWidgets('Authenticated user redirects to /dashboard', (tester) async {
    final user = makeUser();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) {
            final local = MemoryAuthLocalDataSource();
            final remote = MockAuthRemoteDataSource();
            return AuthRepositoryImpl(remote: remote, local: local);
          }),
          authStateProvider
              .overrideWith((ref) => Stream<domain.User?>.value(user)),
          currentUserProvider.overrideWith((ref) async => user),
        ],
        child: const DevHubApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Dashboard content should be present
    expect(find.text('Account info'), findsOneWidget);
    expect(find.text('Quick actions'), findsOneWidget);
  });

  testWidgets('Unauthenticated user redirects to /auth/login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) {
            final local = MemoryAuthLocalDataSource();
            final remote = MockAuthRemoteDataSource();
            return AuthRepositoryImpl(remote: remote, local: local);
          }),
          authStateProvider
              .overrideWith((ref) => Stream<domain.User?>.value(null)),
          currentUserProvider.overrideWith((ref) async => null),
        ],
        child: const DevHubApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Login screen should be visible
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
