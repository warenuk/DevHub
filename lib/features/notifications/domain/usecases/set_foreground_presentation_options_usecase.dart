import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/notifications/domain/repositories/push_notifications_repository.dart';

class SetForegroundPresentationOptionsUseCase {
  const SetForegroundPresentationOptionsUseCase(this._repository);
  final PushNotificationsRepository _repository;

  Future<Either<Failure, void>> call({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) {
    return _repository.setForegroundPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }
}
