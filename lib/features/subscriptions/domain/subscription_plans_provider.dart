import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'subscription_plan.dart';

final subscriptionPlansProvider = Provider<List<SubscriptionPlan>>((ref) {
  return const [
    SubscriptionPlan(
      id: 'starter',
      priceId: 'price_starter',
      name: 'Starter',
      description: 'Ідеально для індивідуальних розробників.',
      amount: 990,
      currency: 'usd',
      interval: 'month',
      features: [
        '1 активний проект',
        'Необмежені нотатки та коментарі',
        'Базова аналітика активності',
      ],
    ),
    SubscriptionPlan(
      id: 'team',
      priceId: 'price_team',
      name: 'Team',
      description: 'Для невеликих команд з розширеними потребами.',
      amount: 2490,
      currency: 'usd',
      interval: 'month',
      features: [
        'До 10 проектів',
        'Спільний доступ до нотаток',
        'Розумні нагадування та автоматизації',
        'Підтримка у робочі години',
      ],
      isRecommended: true,
    ),
    SubscriptionPlan(
      id: 'scale',
      priceId: 'price_scale',
      name: 'Scale',
      description: 'Для компаній, яким потрібна повна гнучкість.',
      amount: 4990,
      currency: 'usd',
      interval: 'month',
      features: [
        'Необмежені проекти та користувачі',
        'Інтеграція з корпоративними SSO',
        'Просунута аналітика і ретроспективи',
        'Пріоритетна підтримка 24/7',
      ],
    ),
  ];
});
