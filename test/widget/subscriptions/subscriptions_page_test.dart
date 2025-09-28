import 'package:devhub_gpt/features/subscriptions/application/stripe_checkout_launcher.dart';
import 'package:devhub_gpt/features/subscriptions/application/subscription_controller.dart';
import 'package:devhub_gpt/features/subscriptions/data/subscription_providers.dart';
import 'package:devhub_gpt/features/subscriptions/data/stripe_subscription_api.dart';
import 'package:devhub_gpt/features/subscriptions/domain/subscription_plan.dart';
import 'package:devhub_gpt/features/subscriptions/domain/subscription_plans_provider.dart';
import 'package:devhub_gpt/features/subscriptions/presentation/pages/subscriptions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStripeSubscriptionApi extends Mock implements StripeSubscriptionApi {}

class MockStripeCheckoutLauncher extends Mock
    implements StripeCheckoutLauncher {}

void main() {
  final plans = [
    const SubscriptionPlan(
      id: 'starter',
      priceId: 'price_123',
      name: 'Starter',
      description: 'desc',
      amount: 990,
      currency: 'usd',
      interval: 'month',
      features: ['one', 'two'],
    ),
  ];

  testWidgets('renders plans and triggers checkout on tap', (tester) async {
    final api = MockStripeSubscriptionApi();
    final launcher = MockStripeCheckoutLauncher();

    when(() => api.createCheckoutSession(plans.first)).thenAnswer(
      (_) async => 'sess_123',
    );
    when(() => launcher.redirectToCheckout(sessionId: 'sess_123'))
        .thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionPlansProvider.overrideWithValue(plans),
          stripeConfigurationStatusProvider.overrideWithValue(true),
          stripeSubscriptionApiProvider.overrideWithValue(api),
          stripeCheckoutLauncherProvider.overrideWithValue(launcher),
        ],
        child: const MaterialApp(
          home: SubscriptionsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Starter'), findsOneWidget);
    expect(find.textContaining('Stripe працює'), findsOneWidget);

    await tester.tap(find.text('Оформити підписку'));
    await tester.pump();

    verify(() => api.createCheckoutSession(plans.first)).called(1);
    verify(() => launcher.redirectToCheckout(sessionId: 'sess_123')).called(1);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
