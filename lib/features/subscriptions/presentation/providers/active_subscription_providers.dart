import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/active_subscription.dart';

class ActiveSubscriptionController extends Notifier<ActiveSubscription?> {
  @override
  ActiveSubscription? build() => null;

  void set(ActiveSubscription? value) => state = value;
  void clear() => state = null;
}

final activeSubscriptionProvider =
    NotifierProvider<ActiveSubscriptionController, ActiveSubscription?>(
  ActiveSubscriptionController.new,
);
