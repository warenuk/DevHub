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
  testWidgets('Dashboard shows user email and sign-out', (tester) async {
    final user = domain.User(
      id: 'u1',
      email: 'user@devhub.test',
      name: 'Dev Hub',
      createdAt: DateTime(2024, 1, 1),
      isEmailVerified: false,
    );

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

    expect(find.text('Account info'), findsOneWidget);
    expect(find.text('user@devhub.test'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });
}
