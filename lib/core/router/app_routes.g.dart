// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $splashRoute,
  $authShellRoute,
  $mainShellRoute,
];

RouteBase get $splashRoute =>
    GoRouteData.$route(path: '/splash', factory: $SplashRoute._fromState);

mixin $SplashRoute on GoRouteData {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  @override
  String get location => GoRouteData.$location('/splash');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $authShellRoute => GoRouteData.$route(
  path: '/auth',
  factory: $AuthShellRoute._fromState,
  routes: [
    GoRouteData.$route(path: 'login', factory: $LoginRoute._fromState),
    GoRouteData.$route(path: 'register', factory: $RegisterRoute._fromState),
  ],
);

mixin $AuthShellRoute on GoRouteData {
  static AuthShellRoute _fromState(GoRouterState state) =>
      const AuthShellRoute();

  @override
  String get location => GoRouteData.$location('/auth');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  @override
  String get location => GoRouteData.$location('/auth/login');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RegisterRoute on GoRouteData {
  static RegisterRoute _fromState(GoRouterState state) => const RegisterRoute();

  @override
  String get location => GoRouteData.$location('/auth/register');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mainShellRoute => ShellRouteData.$route(
  factory: $MainShellRouteExtension._fromState,
  routes: [
    GoRouteData.$route(path: '/dashboard', factory: $DashboardRoute._fromState),
    GoRouteData.$route(
      path: '/github/repos',
      factory: $RepositoriesRoute._fromState,
    ),
    GoRouteData.$route(
      path: '/github/activity/:owner/:repo',
      factory: $ActivityRoute._fromState,
    ),
    GoRouteData.$route(path: '/assistant', factory: $AssistantRoute._fromState),
    GoRouteData.$route(path: '/settings', factory: $SettingsRoute._fromState),
    GoRouteData.$route(path: '/notes', factory: $NotesRoute._fromState),
    GoRouteData.$route(path: '/commits', factory: $CommitsRoute._fromState),
  ],
);

extension $MainShellRouteExtension on MainShellRoute {
  static MainShellRoute _fromState(GoRouterState state) =>
      const MainShellRoute();
}

mixin $DashboardRoute on GoRouteData {
  static DashboardRoute _fromState(GoRouterState state) =>
      const DashboardRoute();

  @override
  String get location => GoRouteData.$location('/dashboard');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RepositoriesRoute on GoRouteData {
  static RepositoriesRoute _fromState(GoRouterState state) =>
      const RepositoriesRoute();

  @override
  String get location => GoRouteData.$location('/github/repos');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ActivityRoute on GoRouteData {
  static ActivityRoute _fromState(GoRouterState state) => ActivityRoute(
    owner: state.pathParameters['owner']!,
    repo: state.pathParameters['repo']!,
  );

  ActivityRoute get _self => this as ActivityRoute;

  @override
  String get location => GoRouteData.$location(
    '/github/activity/${Uri.encodeComponent(_self.owner)}/${Uri.encodeComponent(_self.repo)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $AssistantRoute on GoRouteData {
  static AssistantRoute _fromState(GoRouterState state) =>
      const AssistantRoute();

  @override
  String get location => GoRouteData.$location('/assistant');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $NotesRoute on GoRouteData {
  static NotesRoute _fromState(GoRouterState state) => const NotesRoute();

  @override
  String get location => GoRouteData.$location('/notes');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CommitsRoute on GoRouteData {
  static CommitsRoute _fromState(GoRouterState state) => const CommitsRoute();

  @override
  String get location => GoRouteData.$location('/commits');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
