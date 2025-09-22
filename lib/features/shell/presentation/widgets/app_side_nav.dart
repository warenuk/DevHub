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
        DashboardRoute.path,
        (context) => const DashboardRoute().go(context),
        Icons.space_dashboard_outlined,
        'Dashboard',
      ),
      _NavItem(
        RepositoriesRoute.path,
        (context) => const RepositoriesRoute().go(context),
        Icons.book_outlined,
        'Projects',
      ),
      _NavItem(
        CommitsRoute.path,
        (context) => const CommitsRoute().go(context),
        Icons.commit,
        'Commits',
      ),
      _NavItem(
        NotesRoute.path,
        (context) => const NotesRoute().go(context),
        Icons.note_outlined,
        'Notes',
      ),
      _NavItem(
        SettingsRoute.path,
        (context) => const SettingsRoute().go(context),
        Icons.settings_outlined,
        'Settings',
      ),
    ];
    final int index = items.indexWhere((e) => location.startsWith(e.location));
    final bool extended = MediaQuery.of(context).size.width > 1200;

    return NavigationRail(
      extended: extended,
      selectedIndex: index < 0 ? 0 : index,
      onDestinationSelected: (i) => items[i].go(context),
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
  const _NavItem(this.path, this.go, this.icon, this.label);
  final String path;
  final void Function(BuildContext context) go;
  final IconData icon;
  final String label;
}
