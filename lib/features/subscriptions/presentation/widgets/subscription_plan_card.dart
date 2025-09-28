import 'package:flutter/material.dart';

import '../../domain/subscription_plan.dart';

class SubscriptionPlanCard extends StatelessWidget {
  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.onSubscribe,
    this.isProcessing = false,
    this.disabled = false,
  });

  final SubscriptionPlan plan;
  final VoidCallback onSubscribe;
  final bool isProcessing;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = plan.isRecommended
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surface;
    final textColor = plan.isRecommended
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: plan.isRecommended ? 1.02 : 1,
      child: Card(
        color: cardColor,
        elevation: plan.isRecommended ? 6 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (plan.isRecommended)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Найпопулярніший вибір',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (plan.isRecommended)
                const SizedBox(
                  height: 16,
                ),
              Text(
                plan.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                plan.description,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
              const SizedBox(height: 24),
              Text(
                plan.formattedPrice,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              for (final feature in plan.features)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: disabled || isProcessing ? null : onSubscribe,
                  child: isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Оформити підписку'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
