import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';
import 'package:devhub_gpt/features/notifications/domain/repositories/push_notifications_repository.dart';

class ObserveForegroundMessagesUseCase {
  const ObserveForegroundMessagesUseCase(this._repository);
  final PushNotificationsRepository _repository;

  Stream<PushMessage> call() => _repository.onForegroundMessages();
}
