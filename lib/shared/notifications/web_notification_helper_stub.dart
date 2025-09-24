bool areWebNotificationsSupported() => false;

String currentWebNotificationPermission() => 'default';

Future<bool> ensureWebNotificationPermission() async => false;

Future<bool> showWebNotification(
  String title,
  String body, {
  Map<String, dynamic>? data,
}) async => false;

Future<bool> scheduleNotificationViaServiceWorker({
  required String title,
  required String body,
  Map<String, dynamic>? data,
  required Duration delay,
}) async => false;
