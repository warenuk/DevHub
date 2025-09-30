import 'package:flutter/material.dart';

class ActiveSubscriptionPanel extends StatelessWidget {
  const ActiveSubscriptionPanel({super.key, required this.planName, required this.endsAt, this.onManage});
  final String planName;
  final DateTime? endsAt;
  final VoidCallback? onManage;

  String _formatLeft(Duration d) {
    if (d.inSeconds <= 0) return 'завершено';
    final days = d.inDays;
    final hours = d.inHours % 24;
    final mins = d.inMinutes % 60;
    final parts = <String>[];
    if (days > 0) parts.add('$days д');
    if (hours > 0) parts.add('$hours год');
    if (days == 0 && mins > 0) parts.add('$mins хв');
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final left = endsAt != null ? endsAt!.difference(now) : null;
    final leftLabel = left != null ? _formatLeft(left) : null;

    return Card(
      // Без кислотних контейнерів — стандартний Card під тему додатку
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium, size: 28, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Активна підписка', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(planName, style: theme.textTheme.bodyLarge),
                  if (endsAt != null) ...[
                    const SizedBox(height: 2),
                    Text('Діє до: ' + endsAt!.toLocal().toString(), style: theme.textTheme.bodyMedium),
                  ],
                  if (leftLabel != null && leftLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('Залишилось: ' + leftLabel, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (onManage != null)
              FilledButton.icon(
                onPressed: onManage,
                icon: const Icon(Icons.manage_accounts),
                label: const Text('Керувати'),
              ),
          ],
        ),
      ),
    );
  }
}
