import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSideNav extends StatelessWidget {
  // Move constructor above methods (sort_constructors_first)
  const AppSideNav({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final items = <_NavItem>[
      const _NavItem('/dashboard', Icons.space_dashboard_outlined, 'Dashboard'),
      const _NavItem('/github/repos', Icons.book_outlined, 'Projects'),
      const _NavItem('/commits', Icons.commit, 'Commits'),
      const _NavItem('/notes', Icons.note_outlined, 'Notes'),
      const _NavItem('/settings', Icons.settings_outlined, 'Settings'),
    ];
    final int index = items.indexWhere((e) => location.startsWith(e.path));
    final bool extended = MediaQuery.of(context).size.width > 1200;

    return NavigationRail(
      extended: extended,
      selectedIndex: index < 0 ? 0 : index,
      onDestinationSelected: (i) => context.go(items[i].path),
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
  const _NavItem(this.path, this.icon, this.label);
  final String path;
  final IconData icon;
  final String label;
}
