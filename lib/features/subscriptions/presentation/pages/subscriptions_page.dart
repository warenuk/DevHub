import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/subscription_controller.dart';
import '../../data/subscription_providers.dart';
import '../../domain/subscription_plans_provider.dart';
import '../widgets/subscription_plan_card.dart';

class SubscriptionsPage extends ConsumerWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(subscriptionCheckoutControllerProvider,
        (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(subscriptionErrorMessage(error)),
            ),
          );
        },
      );
    });

    final plans = ref.watch(subscriptionPlansProvider);
    final checkoutState = ref.watch(subscriptionCheckoutControllerProvider);
    final isLoading = checkoutState.isLoading;
    final stripeConfigured = ref.watch(stripeConfigurationStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Підписки'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Оберіть свій план',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Stripe працює у тестовому режимі. Використовуйте тестові картки для перевірки оплати.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (!stripeConfigured) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer
                      .withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Щоб активувати оплату, додайте STRIPE_PUBLISHABLE_KEY та STRIPE_BACKEND_URL у команду запуску.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (isLoading) const LinearProgressIndicator(),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final itemWidth = maxWidth >= 1200
                      ? maxWidth / 3 - 24
                      : maxWidth >= 800
                          ? maxWidth / 2 - 24
                          : maxWidth;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      for (final plan in plans)
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: itemWidth),
                          child: SubscriptionPlanCard(
                            plan: plan,
                            isProcessing: isLoading,
                            disabled: !stripeConfigured,
                            onSubscribe: () {
                              ref
                                  .read(subscriptionCheckoutControllerProvider
                                      .notifier)
                                  .startCheckout(plan);
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
