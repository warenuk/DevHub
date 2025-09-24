import 'dart:html' as html;

Future<bool> ensureWebNotificationPermission() async {
  if (!html.Notification.supported) {
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

  final options = html.NotificationOptions(
    body: body,
    icon: 'icons/Icon-192.png',
    badge: 'icons/Icon-192.png',
    data: data,
    tag: tag,
    vibrate: const [100, 50, 100],
  );

  if (registration != null) {
    await registration.showNotification(title, options);
    return;
  }

  html.Notification(title, options);
}
