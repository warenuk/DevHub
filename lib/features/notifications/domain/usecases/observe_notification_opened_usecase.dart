import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';
import 'package:devhub_gpt/features/notifications/domain/repositories/push_notifications_repository.dart';

class ObserveNotificationOpenedUseCase {
  const ObserveNotificationOpenedUseCase(this._repository);
  final PushNotificationsRepository _repository;

  Stream<PushMessage> call() => _repository.onNotificationOpened();
}
