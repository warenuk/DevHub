// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:js_util' as js_util;

bool areWebNotificationsSupported() => html.Notification.supported;

String currentWebNotificationPermission() {
  if (!areWebNotificationsSupported()) {
    return 'denied';
  }
  final permission = html.Notification.permission;
  return permission ?? 'default';
}

Future<bool> ensureWebNotificationPermission() async {
  if (!areWebNotificationsSupported()) {
    return false;
  }

  final permission = html.Notification.permission;
  if (permission == 'granted') {
    return true;
  }
  if (permission == 'denied') {
    return false;
  }

  final result = await html.Notification.requestPermission();
  return result == 'granted';
}

Future<void> showWebNotification(
  String title,
  String body, {
  Map<String, dynamic>? data,
}) async {
  if (!await ensureWebNotificationPermission()) {
    return;
  }

  final registration = await html.window.navigator.serviceWorker?.ready;
  final tag = data != null && data['sha'] is String
      ? data['sha'] as String
      : null;

  final options = <String, dynamic>{
    'body': body,
    'icon': 'icons/Icon-192.png',
    'badge': 'icons/Icon-192.png',
    'data': data,
    if (tag != null) 'tag': tag,
    'vibrate': const [100, 50, 100],
  };

  final jsOptions = js_util.jsify(options);

  if (registration != null) {
    await js_util.promiseToFuture<void>(
      js_util.callMethod(registration, 'showNotification', [title, jsOptions]),
    );
    return;
  }

  final Object? constructor = js_util.getProperty<Object?>(
    html.window,
    'Notification',
  );
  if (constructor != null) {
    js_util.callConstructor<Object?>(constructor, [title, jsOptions]);
    return;
  }

  html.Notification(title, body: body, icon: 'icons/Icon-192.png', tag: tag);
}
