import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  const SubscriptionPlan({
    required this.id,
    required this.priceId,
    required this.name,
    required this.description,
    required this.amount,
    required this.currency,
    required this.interval,
    required this.features,
    this.isRecommended = false,
  });

  final String id;
  final String priceId;
  final String name;
  final String description;
  final int amount;
  final String currency;
  final String interval;
  final List<String> features;
  final bool isRecommended;

  String get formattedPrice {
    final formattedAmount = (amount / 100).toStringAsFixed(2);
    final currencyUpper = currency.toUpperCase();
    final amountLabel = formattedAmount.endsWith('.00')
        ? formattedAmount.substring(0, formattedAmount.length - 3)
        : formattedAmount;
    return '$amountLabel $currencyUpper/$interval';
  }

  @override
  List<Object?> get props => [
        id,
        priceId,
        name,
        description,
        amount,
        currency,
        interval,
        features,
        isRecommended,
      ];
}
