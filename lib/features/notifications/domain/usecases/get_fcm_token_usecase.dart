import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/notifications/domain/repositories/push_notifications_repository.dart';

class GetFcmTokenUseCase {
  const GetFcmTokenUseCase(this._repository);
  final PushNotificationsRepository _repository;

  Future<Either<Failure, String?>> call({String? vapidKey}) {
    return _repository.getToken(vapidKey: vapidKey);
  }
}
