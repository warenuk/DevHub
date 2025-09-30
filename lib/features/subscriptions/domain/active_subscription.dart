class ActiveSubscription {
  ActiveSubscription({
    required this.productId,
    required this.priceId,
    required this.subscriptionId,
    required this.currentPeriodEnd,
  });

  final String? productId;
  final String? priceId;
  final String? subscriptionId;
  /// Unix timestamp (seconds)
  final int? currentPeriodEnd;

  bool get isActive => subscriptionId != null && (currentPeriodEnd ?? 0) * 1000 > DateTime.now().millisecondsSinceEpoch;
}
