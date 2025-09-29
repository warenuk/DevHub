import 'package:devhub_gpt/features/auth/domain/entities/user.dart';
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:devhub_gpt/shared/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Dashboard shows Block 3 shortcuts', (tester) async {
    final fakeUser = User(
      id: 'u1',
      email: 'u1@test.com',
      name: 'Test User',
      createdAt: DateTime(2020, 1, 1),
      isEmailVerified: true,
    );
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) async => fakeUser),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Block 3 shortcuts'),
      200,
    );

    expect(find.text('Block 3 shortcuts'), findsOneWidget);
    expect(find.byKey(const ValueKey('btnGithubRepos')), findsOneWidget);
    expect(find.byKey(const ValueKey('btnAssistant')), findsOneWidget);
    expect(find.byKey(const ValueKey('btnSettings')), findsOneWidget);
  });
}
