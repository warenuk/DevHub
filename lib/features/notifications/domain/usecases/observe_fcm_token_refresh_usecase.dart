import 'package:devhub_gpt/features/notifications/domain/repositories/push_notifications_repository.dart';

class ObserveFcmTokenRefreshUseCase {
  const ObserveFcmTokenRefreshUseCase(this._repository);
  final PushNotificationsRepository _repository;

  Stream<String> call() => _repository.onTokenRefresh();
}
