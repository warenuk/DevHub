import 'package:devhub_gpt/features/shell/presentation/widgets/app_side_nav.dart';
import 'package:flutter/material.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DevHub')),
      body: Row(
        children: [
          const SizedBox(width: 4),
          const AppSideNav(),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}