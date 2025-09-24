import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/notification_authorization.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';

abstract class PushNotificationsRepository {
  Future<Either<Failure, NotificationAuthorization>> getNotificationSettings();

  Future<Either<Failure, NotificationAuthorization>> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
    bool announcement = false,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
  });

  Future<Either<Failure, void>> setForegroundPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  });

  Future<Either<Failure, PushMessage?>> getInitialMessage();

  Stream<PushMessage> onForegroundMessages();

  Stream<PushMessage> onNotificationOpened();

  Future<Either<Failure, String?>> getToken({String? vapidKey});

  Future<Either<Failure, void>> deleteToken({String? vapidKey});

  Stream<String> onTokenRefresh();
}
