import 'dart:async';

import 'package:devhub_gpt/features/notifications/domain/entities/notification_authorization.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';

abstract class PushNotificationsRemoteDataSource {
  Future<NotificationAuthorization> getNotificationSettings();

  Future<NotificationAuthorization> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
    bool announcement = false,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
  });

  Future<void> setForegroundPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  });

  Future<PushMessage?> getInitialMessage();

  Stream<PushMessage> onForegroundMessages();

  Stream<PushMessage> onNotificationOpened();

  Future<String?> getToken({String? vapidKey});

  Future<void> deleteToken({String? vapidKey});

  Stream<String> onTokenRefresh();
}
