import 'package:devhub_gpt/core/router/app_routes.dart';
import 'package:devhub_gpt/core/router/error_page.dart';
import 'package:devhub_gpt/features/subscriptions/presentation/pages/subscription_success_page.dart';
import 'package:devhub_gpt/features/subscriptions/presentation/pages/subscription_cancel_page.dart';
import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GoRouterRefresh extends ChangeNotifier {
  GoRouterRefresh(Ref ref) {
    ref.listen(authStateProvider, (previous, next) => notifyListeners());
    ref.listen(
      onboardingCompletedProvider,
      (previous, next) => notifyListeners(),
    );
  }
}

class RouteTelemetryObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logTransition('push', route, previousRoute);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logTransition('pop', route, previousRoute);
    super.didPop(route, previousRoute);
  }

  void _logTransition(
    String action,
    Route<dynamic> route,
    Route<dynamic>? previous,
  ) {
    final current = route.settings.name ?? route.settings.arguments;
    final prev = previous?.settings.name ?? previous?.settings.arguments;
    AppLogger.info(
      '[router] $action → ${current ?? route.settings.name ?? route.runtimeType}'
      ' (from ${prev ?? previous?.settings.name ?? previous?.runtimeType})',
      area: 'navigation',
    );
  }
}

const _loginLocation = '${AuthShellRoute.path}/${LoginRoute.path}';

bool _isAuthRoute(String location) => location.startsWith(AuthShellRoute.path);

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final onboardingAsync = ref.watch(onboardingCompletedProvider);
  final refresh = GoRouterRefresh(ref);

  bool _isSubscriptionCallback(String location) {
    return location.startsWith('/subscriptions/success') ||
        location.startsWith('/subscriptions/cancel') ||
        location.startsWith('/subscription/success') ||
        location.startsWith('/subscription/cancel');
  }

  return GoRouter(
    initialLocation: SplashRoute.path,
    debugLogDiagnostics: !kReleaseMode,
    refreshListenable: refresh,
    observers: [RouteTelemetryObserver()],
    redirect: (context, state) {
      final location = state.uri.toString();
      final isAuthRoute = _isAuthRoute(location);
      final isSplash =
          location == SplashRoute.path || location == '/' || location.isEmpty;

      // ⚠️ ВАЖЛИВО: не чіпаємо callback-и Stripe, навіть якщо auth ще вантажиться
      if (_isSubscriptionCallback(location)) return null;

      final onboardingCompleted = onboardingAsync.maybeWhen<bool?>(
        data: (value) => value,
        error: (_, __) => true,
        orElse: () => null,
      );

      return authAsync.when(
        data: (user) {
          final isLoggedIn = user != null;
          if (!isLoggedIn) {
            if (onboardingCompleted == null) {
              if (!isSplash) return SplashRoute.path;
              return null;
            }
            if (onboardingCompleted == false) {
              if (!isSplash) return SplashRoute.path;
              return null;
            }
            if (!isAuthRoute && !isSplash) return _loginLocation;
            if (isSplash) return _loginLocation;
            return null;
          }
          // Авторизований: якщо на splash або на /auth*, перенаправити на дашборд
          if (isAuthRoute || isSplash) return DashboardRoute.path;
          return null;
        },
        loading: () {
          // Під час завантаження тримаємося на splash
          if (!isSplash) return SplashRoute.path;
          return null;
        },
        error: (error, stackTrace) {
          // У разі помилки поводимось як неавторизовані
          if (!isAuthRoute) return _loginLocation;
          return null;
        },
      );
    },
    routes: [
      ...appRoutes,
      // Manual routes (avoid codegen dependency)
      GoRoute(
        path: '/subscriptions/success',
        builder: (context, state) {
          final sid = state.uri.queryParameters['session_id'] ??
              state.uri.queryParameters['sessionId'] ??
              '';
          return SubscriptionSuccessPage(sessionId: sid);
        },
      ),
      GoRoute(
        path: '/subscriptions/cancel',
        builder: (context, state) => const SubscriptionCancelPage(),
      ),
      // Додаткові синоніми шляхів на випадок помилки у success_url
      GoRoute(
        path: '/subscription/success',
        builder: (context, state) {
          final sid = state.uri.queryParameters['session_id'] ??
              state.uri.queryParameters['sessionId'] ??
              '';
          return SubscriptionSuccessPage(sessionId: sid);
        },
      ),
      GoRoute(
        path: '/subscription/cancel',
        builder: (context, state) => const SubscriptionCancelPage(),
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});
