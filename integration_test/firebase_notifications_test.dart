import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:devhub_gpt/firebase_options.dart';
import 'package:devhub_gpt/shared/notifications/commit_notification_service.dart';
import 'package:devhub_gpt/shared/notifications/web_notification_helper.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:js/js.dart' as js;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Firebase web messaging end-to-end push delivery', (
    tester,
  ) async {
    if (!kIsWeb) {
      return;
    }

    const vapidKey = String.fromEnvironment(
      'FIREBASE_WEB_VAPID_KEY',
      defaultValue: '',
    );
    const serverKey = String.fromEnvironment(
      'FIREBASE_FCM_SERVER_KEY',
      defaultValue: '',
    );

    expect(
      vapidKey.isNotEmpty,
      isTrue,
      reason:
          'FIREBASE_WEB_VAPID_KEY is required. Provide it via dart_defines.local.json, dart_defines.json or environment.',
    );
    expect(
      serverKey.isNotEmpty,
      isTrue,
      reason: 'FIREBASE_FCM_SERVER_KEY is required for push integration tests.',
    );

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    final service = CommitNotificationService.instance;
    await service.ensureInitialized();

    expect(
      service.webNotificationsSupported,
      isTrue,
      reason: 'Web Notifications API is not supported in this browser.',
    );

    if (!service.permissionGranted) {
      final granted = await ensureWebNotificationPermission();
      expect(
        granted,
        isTrue,
        reason:
            'Notification permission was not granted. Allow notifications in the browser.',
      );
    }

    final registration = await html.window.navigator.serviceWorker?.ready;
    expect(
      registration,
      isNotNull,
      reason:
          'Service worker is not ready. Ensure flutter_service_worker.js is registered before running tests.',
    );
    final swRegistration = registration!;

    final capturedNotifications = <Map<String, dynamic>>[];
    final originalShowNotification = js_util.getProperty(
      swRegistration,
      'showNotification',
    );
    js_util.setProperty(
      swRegistration,
      'showNotification',
      js.allowInterop((dynamic title, dynamic options) {
        final parsedOptions = options != null
            ? Map<String, dynamic>.from(js_util.dartify(options) as Map)
            : <String, dynamic>{};
        capturedNotifications.add({
          'title': title as String?,
          'options': parsedOptions,
        });
        return js_util.callMethod(originalShowNotification, 'call', [
          swRegistration,
          title,
          options,
        ]);
      }),
    );

    addTearDown(() {
      js_util.setProperty(
        swRegistration,
        'showNotification',
        originalShowNotification,
      );
    });

    await service.refreshToken();
    final token = await service.getCurrentToken();
    expect(
      token,
      isNotNull,
      reason: 'FCM token should not be null after initialization.',
    );
    expect(
      token!.isNotEmpty,
      isTrue,
      reason:
          'FCM token should not be empty. Verify FIREBASE_WEB_VAPID_KEY is correct.',
    );

    final swMessageCompleter = Completer<Map<String, dynamic>>();
    final onMessageCompleter = Completer<RemoteMessage>();

    final swSubscription = html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is Map && data['type'] == 'devhub:sw:notification-shown') {
        if (!swMessageCompleter.isCompleted) {
          swMessageCompleter.complete(Map<String, dynamic>.from(data));
        }
      }
    });
    addTearDown(swSubscription.cancel);

    final onMessageSubscription = FirebaseMessaging.onMessage.listen((message) {
      if (!onMessageCompleter.isCompleted) {
        onMessageCompleter.complete(message);
      }
    });
    addTearDown(onMessageSubscription.cancel);

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://fcm.googleapis.com',
        headers: <String, dynamic>{
          'Authorization': 'key=$serverKey',
          'Content-Type': 'application/json',
        },
      ),
    );

    final sentAt = DateTime.now();

    final response = await dio.post<Map<String, dynamic>>(
      '/fcm/send',
      data: <String, dynamic>{
        'to': token,
        'priority': 'high',
        'data': <String, dynamic>{
          'title': 'DevHub integration test',
          'body': 'Push from integration test at ${sentAt.toIso8601String()}',
          'route': '/dashboard',
          'source': 'integration-test',
          'timestamp': sentAt.toIso8601String(),
        },
      },
    );

    expect(
      response.statusCode,
      anyOf(200, 204),
      reason:
          'FCM request failed with status ${response.statusCode}. ${response.data ?? ''}',
    );

    final remoteMessage = await onMessageCompleter.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException(
        'Timed out waiting for foreground FCM message.',
      ),
    );

    expect(remoteMessage.data['source'], 'integration-test');
    expect(remoteMessage.data['route'], '/dashboard');

    final swMessage = await swMessageCompleter.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException(
        'Timed out waiting for service worker notification.',
      ),
    );

    expect(swMessage['data'], isA<Map>());
    expect((swMessage['data'] as Map)['source'], 'integration-test');

    expect(
      capturedNotifications,
      isNotEmpty,
      reason:
          'Expected the service worker to display at least one notification.',
    );
    final shown = capturedNotifications.last;
    expect(shown['title'], anyOf('DevHub integration test', 'DevHub'));
  });
}
