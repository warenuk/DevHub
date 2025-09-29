import 'package:flutter/material.dart';

class ActiveSubscriptionPanel extends StatelessWidget {
  const ActiveSubscriptionPanel({
    super.key,
    required this.planName,
    required this.endsAt,
    required this.statusLabel,
  });
  final String planName;
  final DateTime? endsAt;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Статус підписки',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(planName, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(statusLabel, style: theme.textTheme.bodyMedium),
                  if (endsAt != null) ...[
                    const SizedBox(height: 2),
                    Text('Діє до: ' + endsAt!.toLocal().toString()),
                  ],
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.manage_accounts),
              label: const Text('Керувати'),
            ),
          ],
        ),
      ),
    );
  }
}
