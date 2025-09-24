// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
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

Future<bool> showWebNotification(
  String title,
  String body, {
  Map<String, dynamic>? data,
}) async {
  if (!await ensureWebNotificationPermission()) {
    return false;
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

  try {
    if (registration != null) {
      await js_util.promiseToFuture<void>(
        js_util.callMethod(registration, 'showNotification', [
          title,
          jsOptions,
        ]),
      );
      return true;
    }

    final Object? constructor = js_util.getProperty<Object?>(
      html.window,
      'Notification',
    );
    if (constructor != null) {
      js_util.callConstructor<Object?>(constructor, [title, jsOptions]);
      return true;
    }

    html.Notification(title, body: body, icon: 'icons/Icon-192.png', tag: tag);
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> scheduleNotificationViaServiceWorker({
  required String title,
  required String body,
  Map<String, dynamic>? data,
  required Duration delay,
}) async {
  final serviceWorkerContainer = html.window.navigator.serviceWorker;
  if (serviceWorkerContainer == null) {
    return false;
  }

  final registration = await serviceWorkerContainer.ready;
  final worker =
      registration.active ?? registration.waiting ?? registration.installing;
  if (worker == null) {
    return false;
  }

  final channel = html.MessageChannel();
  final completer = Completer<bool>();
  final timeout = Timer(delay + const Duration(seconds: 10), () {
    if (!completer.isCompleted) {
      completer.complete(false);
    }
  });

  final subscription = channel.port1.onMessage.listen(
    (event) {
      if (completer.isCompleted) {
        return;
      }
      final dynamic payload = event.data;
      if (payload is String) {
        if (payload == 'devhub:test-notification:delivered') {
          completer.complete(true);
          timeout.cancel();
          return;
        }
        if (payload.startsWith('devhub:test-notification:error')) {
          final message = payload.split(':').skip(3).join(':');
          completer.completeError(
            Exception(message.isEmpty ? 'unknown error' : message),
          );
          timeout.cancel();
          return;
        }
      }

      completer.complete(true);
      timeout.cancel();
    },
    onError: (Object error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
      timeout.cancel();
    },
  );

  final message = <String, dynamic>{
    'type': 'devhub:schedule-test-notification',
    'title': title,
    'body': body,
    'delayMs': delay.inMilliseconds,
    'data': data ?? <String, dynamic>{},
  };

  worker.postMessage(js_util.jsify(message), <Object>[channel.port2]);

  return completer.future.whenComplete(() {
    subscription.cancel();
    channel.port1.close();
    channel.port2.close();
  });
}
