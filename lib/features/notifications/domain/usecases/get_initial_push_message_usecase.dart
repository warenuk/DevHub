import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';
import 'package:devhub_gpt/features/notifications/domain/repositories/push_notifications_repository.dart';

class GetInitialPushMessageUseCase {
  const GetInitialPushMessageUseCase(this._repository);
  final PushNotificationsRepository _repository;

  Future<Either<Failure, PushMessage?>> call() {
    return _repository.getInitialMessage();
  }
}
