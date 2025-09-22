import 'dart:async';

import 'package:devhub_gpt/core/router/app_routes.dart';
import 'package:devhub_gpt/core/router/router_provider.dart';
import 'package:devhub_gpt/features/auth/domain/entities/user.dart' as domain;
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthGuard.redirect', () {
    test('redirects guest users to login for protected routes', () async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream<domain.User?>.value(null),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      final guard = container.read(authGuardProvider);
      expect(
        guard.redirect(const DashboardRoute().location),
        const LoginRoute().location,
      );
    });

    test('keeps guest users on auth routes', () async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream<domain.User?>.value(null),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      final guard = container.read(authGuardProvider);
      expect(guard.redirect(const LoginRoute().location), isNull);
    });

    test('redirects authenticated users away from auth routes and splash',
        () async {
      final user = domain.User(
        id: 'u1',
        email: 'user@test.dev',
        name: 'Test User',
        createdAt: DateTime(2024, 1, 1),
        isEmailVerified: true,
      );

      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream<domain.User?>.value(user),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      final guard = container.read(authGuardProvider);
      expect(
        guard.redirect(const LoginRoute().location),
        const DashboardRoute().location,
      );
      expect(
        guard.redirect(const SplashRoute().location),
        const DashboardRoute().location,
      );
    });

    test('redirects to splash while auth state is loading', () {
      final controller = StreamController<domain.User?>();
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => controller.stream),
        ],
      );
      addTearDown(() {
        controller.close();
        container.dispose();
      });

      final guard = container.read(authGuardProvider);
      expect(
        guard.redirect(const DashboardRoute().location),
        const SplashRoute().location,
      );
    });

    test('falls back to login when auth stream errors', () async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream<domain.User?>.error(Exception('boom')),
          ),
        ],
      );
      addTearDown(container.dispose);

      try {
        await container.read(authStateProvider.future);
      } catch (_) {
        // expected error from the stream
      }

      final guard = container.read(authGuardProvider);
      expect(
        guard.redirect(const DashboardRoute().location),
        const LoginRoute().location,
      );
    });
  });
}
