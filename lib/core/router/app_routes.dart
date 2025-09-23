import 'package:devhub_gpt/features/assistant/presentation/pages/assistant_page.dart';
import 'package:devhub_gpt/features/auth/presentation/pages/login_page.dart';
import 'package:devhub_gpt/features/auth/presentation/pages/register_page.dart';
import 'package:devhub_gpt/features/auth/presentation/pages/splash_page.dart';
import 'package:devhub_gpt/features/commits/presentation/pages/commits_page.dart';
import 'package:devhub_gpt/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:devhub_gpt/features/github/presentation/pages/activity_page.dart';
import 'package:devhub_gpt/features/github/presentation/pages/repositories_page.dart';
import 'package:devhub_gpt/features/notes/presentation/pages/notes_page.dart';
import 'package:devhub_gpt/features/settings/presentation/pages/settings_page.dart';
import 'package:devhub_gpt/features/shell/presentation/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'app_routes.g.dart';

@TypedGoRoute<SplashRoute>(path: SplashRoute.path)
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  static const path = '/splash';

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashPage();
}

@TypedGoRoute<AuthShellRoute>(
  path: AuthShellRoute.path,
  routes: [
    TypedGoRoute<LoginRoute>(path: LoginRoute.path),
    TypedGoRoute<RegisterRoute>(path: RegisterRoute.path),
  ],
)
class AuthShellRoute extends GoRouteData with $AuthShellRoute {
  const AuthShellRoute();
  static const path = '/auth';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SizedBox.shrink();
}

class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();
  static const path = 'login';

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginPage();
}

class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute();
  static const path = 'register';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RegisterPage();
}

@TypedShellRoute<MainShellRoute>(
  routes: [
    TypedGoRoute<DashboardRoute>(path: DashboardRoute.path),
    TypedGoRoute<RepositoriesRoute>(path: RepositoriesRoute.path),
    TypedGoRoute<ActivityRoute>(path: ActivityRoute.path),
    TypedGoRoute<AssistantRoute>(path: AssistantRoute.path),
    TypedGoRoute<SettingsRoute>(path: SettingsRoute.path),
    TypedGoRoute<NotesRoute>(path: NotesRoute.path),
    TypedGoRoute<CommitsRoute>(path: CommitsRoute.path),
  ],
)
class MainShellRoute extends ShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MainShell(child: navigator);
  }
}

class DashboardRoute extends GoRouteData with $DashboardRoute {
  const DashboardRoute();
  static const path = '/dashboard';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DashboardPage();
}

class RepositoriesRoute extends GoRouteData with $RepositoriesRoute {
  const RepositoriesRoute();
  static const path = '/github/repos';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RepositoriesPage();
}

class ActivityRoute extends GoRouteData with $ActivityRoute {
  const ActivityRoute({required this.owner, required this.repo});

  static const path = '/github/activity/:owner/:repo';
  final String owner;
  final String repo;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ActivityPage(owner: owner, repo: repo);
}

class AssistantRoute extends GoRouteData with $AssistantRoute {
  const AssistantRoute();
  static const path = '/assistant';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AssistantPage();
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();
  static const path = '/settings';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}

class NotesRoute extends GoRouteData with $NotesRoute {
  const NotesRoute();
  static const path = '/notes';

  @override
  Widget build(BuildContext context, GoRouterState state) => const NotesPage();
}

class CommitsRoute extends GoRouteData with $CommitsRoute {
  const CommitsRoute();
  static const path = '/commits';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CommitsPage();
}

final List<RouteBase> appRoutes = $appRoutes;
