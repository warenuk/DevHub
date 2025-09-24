import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/notification_authorization.dart';
import 'package:devhub_gpt/features/notifications/domain/repositories/push_notifications_repository.dart';

class GetNotificationSettingsUseCase {
  const GetNotificationSettingsUseCase(this._repository);
  final PushNotificationsRepository _repository;

  Future<Either<Failure, NotificationAuthorization>> call() {
    return _repository.getNotificationSettings();
  }
}
