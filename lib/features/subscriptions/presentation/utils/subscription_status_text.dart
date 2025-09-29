import '../../domain/active_subscription.dart';

String describeSubscriptionStatus(ActiveSubscription subscription) {
  final status = (subscription.status ?? '').toLowerCase();
  if (subscription.cancelAtPeriodEnd == true && subscription.isActive) {
    return 'Активна (буде скасована після поточного періоду)';
  }
  switch (status) {
    case 'trialing':
      return 'Триває пробний період';
    case 'past_due':
      return 'Очікує оплату (past due)';
    case 'unpaid':
      return 'Не оплачена';
    case 'canceled':
      return 'Скасована';
    case 'incomplete':
      return 'Очікує підтвердження оплати';
    case 'incomplete_expired':
      return 'Час на підтвердження вичерпано';
    case 'paused':
      return 'Підписку призупинено';
    default:
      return 'Активна';
  }
}
