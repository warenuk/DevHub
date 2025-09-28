import 'package:devhub_gpt/core/router/app_routes.dart';
import 'package:flutter/material.dart';

class SubscribeCtaCard extends StatelessWidget {
  const SubscribeCtaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_outlined, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Оформіть підписку, щоб активувати преміум-можливості.'),
            ),
            FilledButton(
              onPressed: () => const SubscriptionsRoute().go(context),
              child: const Text('Оформити'),
            ),
          ],
        ),
      ),
    );
  }
}
