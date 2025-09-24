import 'dart:async';

import 'package:devhub_gpt/features/notifications/data/datasources/push_notifications_remote_data_source.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/notification_authorization.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';

/// Fallback data source used when Firebase Messaging is unavailable (e.g. tests).
class NoopPushNotificationsRemoteDataSource
    implements PushNotificationsRemoteDataSource {
  const NoopPushNotificationsRemoteDataSource();

  @override
  Future<void> deleteToken({String? vapidKey}) async {}

  @override
  Future<PushMessage?> getInitialMessage() async => null;

  @override
  Future<String?> getToken({String? vapidKey}) async => null;

  @override
  Future<NotificationAuthorization> getNotificationSettings() async {
    return const NotificationAuthorization(
      status: NotificationAuthorizationStatus.notDetermined,
      alert: false,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      lockScreen: false,
      notificationCenter: false,
      provisional: false,
      showPreviews: false,
      sound: false,
      timeSensitive: false,
    );
  }

  @override
  Stream<PushMessage> onForegroundMessages() =>
      const Stream<PushMessage>.empty();

  @override
  Stream<PushMessage> onNotificationOpened() =>
      const Stream<PushMessage>.empty();

  @override
  Stream<String> onTokenRefresh() => const Stream<String>.empty();

  @override
  Future<NotificationAuthorization> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
    bool announcement = false,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
  }) async {
    return const NotificationAuthorization(
      status: NotificationAuthorizationStatus.denied,
      alert: false,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      lockScreen: false,
      notificationCenter: false,
      provisional: false,
      showPreviews: false,
      sound: false,
      timeSensitive: false,
    );
  }

  @override
  Future<void> setForegroundPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {}
}
