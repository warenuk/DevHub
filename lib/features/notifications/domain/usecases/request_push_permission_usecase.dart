import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/notification_authorization.dart';
import 'package:devhub_gpt/features/notifications/domain/repositories/push_notifications_repository.dart';

class RequestPushPermissionUseCase {
  const RequestPushPermissionUseCase(this._repository);
  final PushNotificationsRepository _repository;

  Future<Either<Failure, NotificationAuthorization>> call({
    bool alert = true,
    bool badge = true,
    bool sound = true,
    bool announcement = false,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
  }) {
    return _repository.requestPermission(
      alert: alert,
      badge: badge,
      sound: sound,
      announcement: announcement,
      carPlay: carPlay,
      criticalAlert: criticalAlert,
      provisional: provisional,
    );
  }
}
