import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/notifications/domain/repositories/push_notifications_repository.dart';

class DeleteFcmTokenUseCase {
  const DeleteFcmTokenUseCase(this._repository);
  final PushNotificationsRepository _repository;

  Future<Either<Failure, void>> call({String? vapidKey}) {
    return _repository.deleteToken(vapidKey: vapidKey);
  }
}
