import 'dart:async';

import 'package:devhub_gpt/features/notifications/data/datasources/push_notifications_remote_data_source.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/notification_authorization.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePushNotificationsRemoteDataSource
    implements PushNotificationsRemoteDataSource {
  FirebasePushNotificationsRemoteDataSource(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  Future<void> deleteToken({String? vapidKey}) {
    // `deleteToken` no longer accepts a VAPID key in the new SDK. The optional
    // parameter is kept for interface parity and simply ignored here.
    return _messaging.deleteToken();
  }

  @override
  Future<PushMessage?> getInitialMessage() async {
    final RemoteMessage? message = await _messaging.getInitialMessage();
    if (message == null) return null;
    return _mapRemoteMessage(message);
  }

  @override
  Future<String?> getToken({String? vapidKey}) {
    return _messaging.getToken(vapidKey: vapidKey);
  }

  @override
  Future<NotificationAuthorization> getNotificationSettings() async {
    final NotificationSettings settings = await _messaging
        .getNotificationSettings();
    return _mapNotificationSettings(settings);
  }

  @override
  Stream<PushMessage> onForegroundMessages() {
    return FirebaseMessaging.onMessage.map(_mapRemoteMessage);
  }

  @override
  Stream<PushMessage> onNotificationOpened() {
    return FirebaseMessaging.onMessageOpenedApp.map(_mapRemoteMessage);
  }

  @override
  Stream<String> onTokenRefresh() => _messaging.onTokenRefresh;

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
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: alert,
      announcement: announcement,
      badge: badge,
      carPlay: carPlay,
      criticalAlert: criticalAlert,
      provisional: provisional,
      sound: sound,
    );
    return _mapNotificationSettings(settings);
  }

  @override
  Future<void> setForegroundPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) {
    return _messaging.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }

  NotificationAuthorization _mapNotificationSettings(
    NotificationSettings settings,
  ) {
    return NotificationAuthorization(
      status: _mapAuthorizationStatus(settings.authorizationStatus),
      alert: _isAppleSettingEnabled(settings.alert),
      announcement: _isAppleSettingEnabled(settings.announcement),
      badge: _isAppleSettingEnabled(settings.badge),
      carPlay: _isAppleSettingEnabled(settings.carPlay),
      criticalAlert: _isAppleSettingEnabled(settings.criticalAlert),
      lockScreen: _isAppleSettingEnabled(settings.lockScreen),
      notificationCenter: _isAppleSettingEnabled(settings.notificationCenter),
      provisional:
          settings.authorizationStatus == AuthorizationStatus.provisional,
      showPreviews: _isPreviewEnabled(settings.showPreviews),
      sound: _isAppleSettingEnabled(settings.sound),
      timeSensitive: _isAppleSettingEnabled(settings.timeSensitive),
    );
  }

  PushMessage _mapRemoteMessage(RemoteMessage message) {
    final RemoteNotification? notification = message.notification;
    final String? imageUrl =
        notification?.android?.imageUrl ??
        notification?.apple?.imageUrl ??
        notification?.web?.image;
    final String? linkStr =
        notification?.android?.link ??
        notification?.web?.link ??
        message.data['link'] as String?;
    return PushMessage(
      title: notification?.title,
      body: notification?.body,
      imageUrl: imageUrl,
      link: _parseUri(linkStr),
      category: message.category,
      collapseKey: message.collapseKey,
      from: message.from,
      messageId: message.messageId,
      sentTime: message.sentTime,
      data: Map<String, dynamic>.from(message.data),
    );
  }

  NotificationAuthorizationStatus _mapAuthorizationStatus(
    AuthorizationStatus status,
  ) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return NotificationAuthorizationStatus.authorized;
      case AuthorizationStatus.denied:
        return NotificationAuthorizationStatus.denied;
      case AuthorizationStatus.notDetermined:
        return NotificationAuthorizationStatus.notDetermined;
      case AuthorizationStatus.provisional:
        return NotificationAuthorizationStatus.provisional;
    }
  }

  bool _isAppleSettingEnabled(AppleNotificationSetting setting) {
    return setting == AppleNotificationSetting.enabled;
  }

  bool _isPreviewEnabled(AppleShowPreviewSetting setting) {
    return setting == AppleShowPreviewSetting.always ||
        setting == AppleShowPreviewSetting.whenAuthenticated;
  }

  Uri? _parseUri(String? link) {
    if (link == null || link.isEmpty) {
      return null;
    }
    return Uri.tryParse(link);
  }
}
