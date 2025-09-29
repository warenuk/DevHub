import 'dart:async';

import 'package:devhub_gpt/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:devhub_gpt/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:devhub_gpt/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart' as domain;
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/main.dart';
import 'package:devhub_gpt/shared/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_until_stable.dart';

void main() {
  testWidgets('Unknown route renders ErrorPage (authed user)', (tester) async {
    final user = domain.User(
      id: 'u1',
      email: 'user@devhub.test',
      name: 'Dev Hub',
      createdAt: DateTime(2024, 1, 1),
      isEmailVerified: true,
    );
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) {
            final local = MemoryAuthLocalDataSource();
            final remote = MockAuthRemoteDataSource();
            return AuthRepositoryImpl(remote: remote, local: local);
          }),
          authStateProvider.overrideWith(
            (ref) => Stream<domain.User?>.value(user),
          ),
          currentUserProvider.overrideWith((ref) async => user),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const DevHubApp(),
      ),
    );

    await pumpUntilStable(tester);

    final ctx = tester.element(find.byType(Scaffold).first);
    GoRouter.of(ctx).go('/this/route/does/not/exist');
    await pumpUntilStable(tester);

    expect(find.text('Щось пішло не так'), findsOneWidget);
    expect(find.text('На головну'), findsOneWidget);
  });
}
