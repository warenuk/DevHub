import 'dart:async';

import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/shared/constants/firebase_flags.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'web_notification_helper.dart';

/// Handles Firebase Cloud Messaging bootstrap and commit alerts for the web app.
class CommitNotificationService {
  CommitNotificationService._();

  static final CommitNotificationService instance =
      CommitNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  bool _initialized = false;
  bool _permissionGranted = false;

  /// Initializes Firebase Messaging for web and prepares foreground handlers.
  Future<void> ensureInitialized() async {
    if (_initialized || !kUseFirebase) {
      return;
    }
    _initialized = true;

    if (!kIsWeb) {
      // The current project targets the web, but guard just in case.
      return;
    }

    try {
      await _messaging.setAutoInitEnabled(true);
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      _permissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!_permissionGranted) {
        return;
      }

      _permissionGranted = await ensureWebNotificationPermission();
      if (!_permissionGranted) {
        return;
      }

      await _messaging.getToken(
        vapidKey: kFirebaseWebVapidKey.isEmpty ? null : kFirebaseWebVapidKey,
      );

      _foregroundSub ??= FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
      );
    } catch (error, stackTrace) {
      debugPrint('Firebase Messaging init failed: $error');
      debugPrint(stackTrace.toString());
    }
  }

  /// Display notifications for commits that are newer than [previousLatestSha].
  Future<void> notifyAboutCommits({
    required List<CommitInfo> fetchedCommits,
    required String? previousLatestSha,
  }) async {
    if (!_initialized) {
      await ensureInitialized();
    }
    if (!kUseFirebase || !_permissionGranted || fetchedCommits.isEmpty) {
      return;
    }

    // Якщо це перше завантаження, не сповіщаємо — немає з чим порівнювати.
    if (previousLatestSha == null) {
      return;
    }

    final index = fetchedCommits.indexWhere(
      (commit) => commit.id == previousLatestSha,
    );
    if (index == 0) {
      // Немає новіших записів.
      return;
    }

    final newCommits = index < 0
        ? fetchedCommits
        : fetchedCommits.sublist(0, index);

    if (newCommits.isEmpty) {
      return;
    }

    final latest = newCommits.first;
    final title = newCommits.length == 1
        ? 'Новий коміт від ${latest.author}'
        : 'Нові коміти (${newCommits.length})';

    final body = newCommits.length == 1
        ? latest.message
        : newCommits.take(3).map((commit) => '• ${commit.message}').join('\n');

    try {
      await showWebNotification(
        title,
        body,
        data: <String, dynamic>{
          'route': '/commits',
          'sha': latest.id,
          'count': newCommits.length,
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to show commit notification: $error');
      debugPrint(stackTrace.toString());
    }
  }

  void dispose() {
    _foregroundSub?.cancel();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    try {
      await showWebNotification(
        notification.title ?? 'DevHub',
        notification.body ?? '',
        data: message.data,
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to show FCM foreground notification: $error');
      debugPrint(stackTrace.toString());
    }
  }
}
