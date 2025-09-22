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

@TypedGoRoute<SplashRoute>(
  path: '/splash',
)
class SplashRoute extends GoRouteData {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashPage();
}

@TypedGoRoute<AuthShellRoute>(
  path: '/auth',
  routes: [
    TypedGoRoute<LoginRoute>(path: 'login'),
    TypedGoRoute<RegisterRoute>(path: 'register'),
  ],
)
class AuthShellRoute extends GoRouteData {
  const AuthShellRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SizedBox.shrink();
}

class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginPage();
}

class RegisterRoute extends GoRouteData {
  const RegisterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RegisterPage();
}

@TypedShellRoute<MainShellRoute>(
  routes: [
    TypedGoRoute<DashboardRoute>(path: '/dashboard'),
    TypedGoRoute<GithubReposRoute>(path: '/github/repos'),
    TypedGoRoute<GithubActivityRoute>(path: '/github/activity/:owner/:repo'),
    TypedGoRoute<AssistantRoute>(path: '/assistant'),
    TypedGoRoute<SettingsRoute>(path: '/settings'),
    TypedGoRoute<NotesRoute>(path: '/notes'),
    TypedGoRoute<CommitsRoute>(path: '/commits'),
  ],
)
class MainShellRoute extends ShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) {
    return MainShell(child: navigator);
  }
}

class DashboardRoute extends GoRouteData {
  const DashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DashboardPage();
}

class GithubReposRoute extends GoRouteData {
  const GithubReposRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RepositoriesPage();
}

class GithubActivityRoute extends GoRouteData {
  const GithubActivityRoute({required this.owner, required this.repo});

  final String owner;
  final String repo;

  @override
  Widget build(BuildContext context, GoRouterState state) => ActivityPage(
        owner: owner,
        repo: repo,
      );
}

class AssistantRoute extends GoRouteData {
  const AssistantRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AssistantPage();
}

class SettingsRoute extends GoRouteData {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}

class NotesRoute extends GoRouteData {
  const NotesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const NotesPage();
}

class CommitsRoute extends GoRouteData {
  const CommitsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CommitsPage();
}
