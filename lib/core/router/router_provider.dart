import 'package:devhub_gpt/features/assistant/presentation/pages/assistant_page.dart';
import 'package:devhub_gpt/features/auth/presentation/pages/login_page.dart';
import 'package:devhub_gpt/features/auth/presentation/pages/register_page.dart';
import 'package:devhub_gpt/features/auth/presentation/pages/splash_page.dart';
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/commits/presentation/pages/commits_page.dart';
import 'package:devhub_gpt/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:devhub_gpt/features/github/presentation/pages/activity_page.dart';
import 'package:devhub_gpt/features/github/presentation/pages/repositories_page.dart';
import 'package:devhub_gpt/features/notes/presentation/pages/notes_page.dart';
import 'package:devhub_gpt/features/settings/presentation/pages/settings_page.dart';
import 'package:devhub_gpt/features/shell/presentation/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GoRouterRefresh extends ChangeNotifier {
  GoRouterRefresh(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final refresh = GoRouterRefresh(ref);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: refresh,
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == '/splash' ||
          state.matchedLocation == '/' ||
          state.matchedLocation.isEmpty;

      return authAsync.when(
        data: (user) {
          final isLoggedIn = user != null;
          if (!isLoggedIn) {
            // Все неавторизоване → на логін (окрім самих /auth* маршрутів)
            if (!isAuthRoute) return '/auth/login';
            return null;
          }
          // Авторизований: якщо на splash або на /auth*, перенаправити на дашборд
          if (isAuthRoute || isSplash) return '/dashboard';
          return null;
        },
        loading: () {
          // Під час завантаження тримаємося на splash
          if (!isSplash) return '/splash';
          return null;
        },
        error: (_, __) {
          // У разі помилки поводимось як неавторизовані
          if (!isAuthRoute) return '/auth/login';
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth-shell',
        builder: (context, state) => const SizedBox.shrink(),
        routes: [
          GoRoute(
            path: 'login',
            name: 'login',
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: 'register',
            name: 'register',
            builder: (context, state) => const RegisterPage(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/github/repos',
            name: 'github-repos',
            builder: (context, state) => const RepositoriesPage(),
          ),
          GoRoute(
            path: '/github/activity/:owner/:repo',
            name: 'github-activity',
            builder: (context, state) => ActivityPage(
              owner: state.pathParameters['owner']!,
              repo: state.pathParameters['repo']!,
            ),
          ),
          GoRoute(
            path: '/assistant',
            name: 'assistant',
            builder: (context, state) => const AssistantPage(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/notes',
            name: 'notes',
            builder: (context, state) => const NotesPage(),
          ),
          GoRoute(
            path: '/commits',
            name: 'commits',
            builder: (context, state) => const CommitsPage(),
          ),
        ],
      ),
    ],
  );
});


