import 'package:devhub_gpt/core/router/app_routes.dart';
import 'package:devhub_gpt/core/router/auth_guard.dart';
import 'package:devhub_gpt/core/router/error_page.dart';
import 'package:devhub_gpt/core/router/route_telemetry_observer.dart';
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GoRouterRefresh extends ChangeNotifier {
  GoRouterRefresh(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = GoRouterRefresh(ref);
  final guard = ref.watch(authGuardProvider);
  final telemetry = ref.watch(routeTelemetryObserverProvider);

  return GoRouter(
    initialLocation: const SplashRoute().location,
    debugLogDiagnostics: !kReleaseMode,
    refreshListenable: refresh,
    redirect: (context, state) => guard.redirect(state.matchedLocation),
    observers: [telemetry],
    routes: $appRoutes,
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});

final authGuardProvider = Provider<AuthGuard>((ref) {
  return AuthGuard(ref);
});

final routeTelemetryObserverProvider = Provider<RouteTelemetryObserver>((ref) {
  return RouteTelemetryObserver();
});
