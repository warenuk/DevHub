class ActiveSubscription {
  ActiveSubscription({
    required this.productId,
    required this.priceId,
    required this.subscriptionId,
    required this.currentPeriodEnd,
    this.customerId,
    this.status,
    this.cancelAtPeriodEnd,
  });

  final String? productId;
  final String? priceId;
  final String? subscriptionId;

  /// Unix timestamp (seconds)
  final int? currentPeriodEnd;
  final String? customerId;
  final String? status;
  final bool? cancelAtPeriodEnd;

  bool get isActive {
    if (subscriptionId == null || subscriptionId!.isEmpty) {
      return false;
    }
    final normalizedStatus = status?.toLowerCase();
    if (normalizedStatus != null && normalizedStatus.isNotEmpty) {
      const activeStatuses = {'active', 'trialing', 'past_due'};
      if (!activeStatuses.contains(normalizedStatus)) {
        return false;
      }
    }
    if (currentPeriodEnd != null && currentPeriodEnd! > 0) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (currentPeriodEnd! <= now) {
        return false;
      }
    }
    return true;
  }

  bool get isExpired {
    if (subscriptionId == null || subscriptionId!.isEmpty) {
      return false;
    }
    if (currentPeriodEnd == null || currentPeriodEnd! <= 0) {
      return false;
    }
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return currentPeriodEnd! <= now;
  }

  ActiveSubscription copyWith({
    String? productId,
    String? priceId,
    String? subscriptionId,
    int? currentPeriodEnd,
    String? customerId,
    String? status,
    bool? cancelAtPeriodEnd,
  }) {
    return ActiveSubscription(
      productId: productId ?? this.productId,
      priceId: priceId ?? this.priceId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      cancelAtPeriodEnd: cancelAtPeriodEnd ?? this.cancelAtPeriodEnd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'priceId': priceId,
      'subscriptionId': subscriptionId,
      'currentPeriodEnd': currentPeriodEnd,
      'customerId': customerId,
      'status': status,
      'cancelAtPeriodEnd': cancelAtPeriodEnd,
    };
  }

  factory ActiveSubscription.fromJson(Map<String, dynamic> json) {
    return ActiveSubscription(
      productId: json['productId'] as String?,
      priceId: json['priceId'] as String?,
      subscriptionId: json['subscriptionId'] as String?,
      currentPeriodEnd: (json['currentPeriodEnd'] as num?)?.toInt(),
      customerId: json['customerId'] as String?,
      status: json['status'] as String?,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool?,
    );
  }
}
