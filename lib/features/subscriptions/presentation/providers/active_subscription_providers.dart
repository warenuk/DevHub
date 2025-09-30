import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/subscription_providers.dart';
import '../../domain/active_subscription.dart';

class ActiveSubscriptionController extends AsyncNotifier<ActiveSubscription?> {
@override
Future<ActiveSubscription?> build() async {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return null;
    final backendUrl = ref.read(stripeBackendUrlProvider);
final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10)));
  final base = backendUrl.endsWith('/') ? backendUrl : '$backendUrl/';
    final resp = await dio.get<Map<String, dynamic>>(
      '${base}me/subscription',
      options: Options(headers: {
        'x-user-id': user.id,
        'x-user-email': user.email,
      }),
    );
    if (resp.statusCode != 200 || resp.data == null) return null;
    final m = resp.data!;
    if (m['subscription_id'] == null) return null;
    return ActiveSubscription(
      productId: m['productId'] as String?,
      priceId: m['priceId'] as String?,
      subscriptionId: m['subscription_id'] as String?,
      currentPeriodEnd: (m['current_period_end'] as num?)?.toInt(),
    );
  }

  Future<void> refreshNow() async {
    final prev = state;
    state = const AsyncLoading<ActiveSubscription?>().copyWithPrevious(prev);
    state = await AsyncValue.guard(build);
  }
}

final activeSubscriptionProvider = AsyncNotifierProvider<ActiveSubscriptionController, ActiveSubscription?>(
  ActiveSubscriptionController.new,
);

