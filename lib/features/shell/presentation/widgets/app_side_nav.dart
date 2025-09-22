import 'package:devhub_gpt/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSideNav extends StatelessWidget {
  // Move constructor above methods (sort_constructors_first)
  const AppSideNav({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final items = <_NavItem>[
      _NavItem(
        location: const DashboardRoute().location,
        icon: Icons.space_dashboard_outlined,
        label: 'Dashboard',
        navigate: (context) => const DashboardRoute().go(context),
      ),
      _NavItem(
        location: const GithubReposRoute().location,
        icon: Icons.book_outlined,
        label: 'Projects',
        navigate: (context) => const GithubReposRoute().go(context),
      ),
      _NavItem(
        location: const CommitsRoute().location,
        icon: Icons.commit,
        label: 'Commits',
        navigate: (context) => const CommitsRoute().go(context),
      ),
      _NavItem(
        location: const NotesRoute().location,
        icon: Icons.note_outlined,
        label: 'Notes',
        navigate: (context) => const NotesRoute().go(context),
      ),
      _NavItem(
        location: const SettingsRoute().location,
        icon: Icons.settings_outlined,
        label: 'Settings',
        navigate: (context) => const SettingsRoute().go(context),
      ),
    ];
    final int index = items.indexWhere((e) => location.startsWith(e.location));
    final bool extended = MediaQuery.of(context).size.width > 1200;

    return NavigationRail(
      extended: extended,
      selectedIndex: index < 0 ? 0 : index,
      onDestinationSelected: (i) => items[i].navigate(context),
      destinations: [
        for (final e in items)
          NavigationRailDestination(
            icon: Icon(e.icon),
            selectedIcon: Icon(e.icon),
            label: Text(e.label),
          ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.location,
    required this.icon,
    required this.label,
    required this.navigate,
  });

  final String location;
  final IconData icon;
  final String label;
  final void Function(BuildContext context) navigate;
}