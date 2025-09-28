import 'dart:async';

import 'package:devhub_gpt/core/router/app_routes.dart';
import 'package:devhub_gpt/features/subscriptions/data/stripe_subscription_api.dart';
import 'package:devhub_gpt/features/subscriptions/domain/active_subscription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/subscription_providers.dart';

class SubscriptionSuccessPage extends ConsumerStatefulWidget {
  const SubscriptionSuccessPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<SubscriptionSuccessPage> createState() => _SubscriptionSuccessPageState();
}

class _SubscriptionSuccessPageState extends ConsumerState<SubscriptionSuccessPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Map<String, dynamic>? _payload;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    scheduleMicrotask(_load);
  }

  Future<void> _load() async {
    try {
      final api = ref.read(stripeSubscriptionApiProvider);
      final data = await api.fetchSession(widget.sessionId);
      setState(() { _payload = data; });
    } catch (e) { setState(() { _error = e; }); } finally { _controller.stop(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Оплата успішна'),
        actions: [
          IconButton(
            tooltip: 'Закрити',
            icon: const Icon(Icons.close),
            onPressed: () => const DashboardRoute().go(context),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Не вдалося підтвердити оплату'),
          const SizedBox(height: 8),
          Text(
            _error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => const DashboardRoute().go(context),
            child: const Text('До дашборду'),
          ),
        ],
      );
    }
    if (_payload == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: _controller,
            child: const Icon(Icons.stars_rounded, size: 64),
          ),
          const SizedBox(height: 12),
          const Text('Підтверджуємо оплату…'),
        ],
      );
    }
    final ActiveSubscription sub = ActiveSubscription(
      productId: _payload!['productId'] as String?,
      priceId: _payload!['priceId'] as String?,
      subscriptionId: _payload!['subscriptionId'] as String?,
      currentPeriodEnd: (_payload!['current_period_end'] as num?)?.toInt(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.celebration, size: 72, color: Colors.green),
        const SizedBox(height: 12),
        const Text('Оплата пройшла успішно!'),
        const SizedBox(height: 8),
        if (sub.isActive) Text('План активовано до ' + DateTime.fromMillisecondsSinceEpoch((sub.currentPeriodEnd ?? 0) * 1000).toLocal().toString()),
        const SizedBox(height: 20),
        FilledButton.icon(
          icon: const Icon(Icons.dashboard_outlined),
          onPressed: () => const DashboardRoute().go(context),
          label: const Text('До дашборду'),
        )
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
