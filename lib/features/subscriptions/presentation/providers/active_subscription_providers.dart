import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/active_subscription_repository.dart';
import '../../data/stripe_subscription_api.dart';
import '../../data/subscription_providers.dart';
import '../../domain/active_subscription.dart';
import '../../../../shared/providers/shared_preferences_provider.dart';

final activeSubscriptionRepositoryProvider =
    Provider<ActiveSubscriptionRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ActiveSubscriptionRepository(prefs);
});

class ActiveSubscriptionController extends Notifier<ActiveSubscription?> {
  ActiveSubscriptionRepository get _repository =>
      ref.read(activeSubscriptionRepositoryProvider);
  StripeSubscriptionApi get _api => ref.read(stripeSubscriptionApiProvider);

  bool _initialized = false;

  @override
  ActiveSubscription? build() {
    if (!_initialized) {
      _initialized = true;
      scheduleMicrotask(_loadFromCache);
    }
    return null;
  }

  Future<void> _loadFromCache() async {
    final cached = await _repository.load();
    if (!ref.mounted) {
      return;
    }
    state = cached;
    if (cached?.subscriptionId != null && cached!.subscriptionId!.isNotEmpty) {
      await refresh();
    }
  }

  Future<void> set(ActiveSubscription? value) async {
    if (value == null) {
      await _repository.clear();
      state = null;
      return;
    }
    await _repository.save(value);
    state = value;
  }

  Future<void> refresh() async {
    final id = state?.subscriptionId;
    if (id == null || id.isEmpty) {
      return;
    }
    try {
      final updated = await _api.fetchSubscriptionStatus(id);
      if (!ref.mounted) {
        return;
      }
      if (updated == null || !updated.isActive) {
        await set(null);
        return;
      }
      await set(updated);
    } catch (_) {
      // Ignore refresh errors to avoid breaking the UI when backend is unavailable.
    }
  }

  Future<void> clear() async {
    await set(null);
  }
}

final activeSubscriptionProvider =
    NotifierProvider<ActiveSubscriptionController, ActiveSubscription?>(
  ActiveSubscriptionController.new,
);
