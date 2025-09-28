import 'package:devhub_gpt/core/router/app_routes.dart';
import 'package:flutter/material.dart';

class SubscriptionCancelPage extends StatelessWidget {
  const SubscriptionCancelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Оплату скасовано'),
        actions: [
          IconButton(
            tooltip: 'Закрити',
            icon: const Icon(Icons.close),
            onPressed: () => const DashboardRoute().go(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 64),
              const SizedBox(height: 12),
              const Text('Оплату було скасовано. Ви можете спробувати знову.'),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => const SubscriptionsRoute().go(context),
                icon: const Icon(Icons.workspace_premium_outlined),
                label: const Text('Оформити підписку'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
