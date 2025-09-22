import 'package:devhub_gpt/core/router/app_routes.dart';
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGuard {
  AuthGuard(this._ref);

  final Ref _ref;

  String? redirect(String location) {
    final current = location.isEmpty ? '/' : location;
    final authAsync = _ref.read(authStateProvider);
    final isAuthRoute = current.startsWith(const AuthShellRoute().location);
    final isSplash = current == const SplashRoute().location || current == '/';

    return authAsync.when(
      data: (user) {
        final isLoggedIn = user != null;
        if (!isLoggedIn) {
          if (!isAuthRoute) {
            return const LoginRoute().location;
          }
          return null;
        }
        if (isAuthRoute || isSplash) {
          return const DashboardRoute().location;
        }
        return null;
      },
      loading: () {
        if (!isSplash) {
          return const SplashRoute().location;
        }
        return null;
      },
      error: (_, __) {
        if (!isAuthRoute) {
          return const LoginRoute().location;
        }
        return null;
      },
    );
  }
}
