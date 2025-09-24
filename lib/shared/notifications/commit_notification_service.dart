import 'dart:async';

import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/shared/constants/firebase_flags.dart';
import 'package:devhub_gpt/shared/notifications/web_notification_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Exception thrown when scheduling or displaying push notifications fails.
class PushNotificationException implements Exception {
  const PushNotificationException(this.message);

  final String message;

  @override
  String toString() => 'PushNotificationException: $message';
}

/// Handles Firebase Cloud Messaging bootstrap and commit alerts for the web app.
class CommitNotificationService {
  CommitNotificationService._();

  static final CommitNotificationService instance =
      CommitNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final StreamController<String?> _tokenController =
      StreamController<String?>.broadcast();

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<String>? _tokenRefreshSub;
  Future<void>? _initializationFuture;

  bool _initialized = false;
  bool _permissionGranted = false;
  bool _webNotificationsSupported = false;
  bool _disposed = false;

  String? _currentToken;
  String _notificationPermissionState = 'default';

  /// Emits whenever the FCM registration token changes. `null` represents an
  /// unavailable token (for example, when permissions are denied).
  Stream<String?> get tokenChanges => _tokenController.stream;

  /// Whether notifications are currently allowed by the browser.
  bool get permissionGranted => _permissionGranted;

  /// Whether the runtime supports the Web Notifications API.
  bool get webNotificationsSupported => _webNotificationsSupported;

  /// The last known browser notification permission state
  /// (`default`/`granted`/`denied`).
  String get notificationPermissionState => _notificationPermissionState;

  /// The latest cached FCM token, if available.
  String? get currentToken => _currentToken;

  /// Whether the initialization flow has already run.
  bool get isInitialized => _initialized;

  /// Initializes Firebase Messaging for web and prepares foreground handlers.
  Future<void> ensureInitialized() {
    if (!kUseFirebase) {
      return Future.value();
    }
    if (_initialized) {
      return Future.value();
    }
    return _initializationFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    if (!kIsWeb) {
      _initialized = true;
      _initializationFuture = null;
      return;
    }

    try {
      await _messaging.setAutoInitEnabled(true);

      _webNotificationsSupported = areWebNotificationsSupported();
      _notificationPermissionState = currentWebNotificationPermission();
      if (!_webNotificationsSupported) {
        _permissionGranted = false;
        _setToken(null);
        return;
      }

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final status = settings.authorizationStatus;
      _permissionGranted =
          status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional;

      if (!_permissionGranted && _notificationPermissionState == 'denied') {
        _setToken(null);
        return;
      }

      if (_notificationPermissionState != 'granted') {
        final granted = await ensureWebNotificationPermission();
        _notificationPermissionState = currentWebNotificationPermission();
        _permissionGranted = granted;
        if (!granted) {
          _setToken(null);
          return;
        }
      } else {
        _permissionGranted = true;
      }

      await _refreshToken(force: true);

      _foregroundSub ??= FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
      );

      _tokenRefreshSub ??= FirebaseMessaging.instance.onTokenRefresh.listen(
        _setToken,
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Token refresh error: $error');
          debugPrint(stackTrace.toString());
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Firebase Messaging init failed: $error');
      debugPrint(stackTrace.toString());
      _setToken(null);
    } finally {
      _initialized = true;
      _initializationFuture = null;
    }
  }

  /// Returns the current registration token if available. When [forceRefresh]
  /// is true, the token will be refreshed from Firebase even if a cached value
  /// exists.
  Future<String?> getCurrentToken({bool forceRefresh = false}) async {
    if (!kUseFirebase || !kIsWeb) {
      return null;
    }
    if (!_initialized) {
      await ensureInitialized();
    }
    if (!_permissionGranted) {
      return null;
    }
    if (!forceRefresh && _currentToken != null && _currentToken!.isNotEmpty) {
      return _currentToken;
    }
    await _refreshToken(force: true);
    return _currentToken;
  }

  /// Forces a token refresh.
  Future<void> refreshToken() => _refreshToken(force: true);

  /// Schedules a synthetic test notification that is displayed after [delay].
  Future<void> scheduleTestNotification({
    Duration delay = const Duration(seconds: 10),
  }) async {
    if (!kUseFirebase) {
      throw const PushNotificationException(
        'Firebase вимкнено для цієї збірки.',
      );
    }
    await ensureInitialized();
    if (!_permissionGranted || !_webNotificationsSupported) {
      throw const PushNotificationException(
        'Сповіщення у браузері вимкнено або не підтримуються.',
      );
    }

    final token = await getCurrentToken();
    if (token == null || token.isEmpty) {
      throw const PushNotificationException(
        'FCM токен недоступний. Спробуйте оновити сторінку або перевірити налаштування Firebase.',
      );
    }

    await Future<void>.delayed(delay);
    await showWebNotification(
      'DevHub — тестове сповіщення',
      'Це тестове повідомлення з Firebase Cloud Messaging з затримкою 10 секунд.',
      data: <String, dynamic>{
        'route': '/dashboard',
        'testNotification': 'true',
        'issuedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Display notifications for commits that are newer than [previousLatestSha].
  Future<void> notifyAboutCommits({
    required List<CommitInfo> fetchedCommits,
    required String? previousLatestSha,
  }) async {
    if (!_initialized) {
      await ensureInitialized();
    }
    if (!kUseFirebase ||
        !_permissionGranted ||
        !_webNotificationsSupported ||
        fetchedCommits.isEmpty) {
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
    if (_disposed) {
      return;
    }
    _disposed = true;
    _foregroundSub?.cancel();
    _tokenRefreshSub?.cancel();
    _tokenController.close();
  }

  Future<void> _refreshToken({bool force = false}) async {
    if (!kUseFirebase || !kIsWeb) {
      _setToken(null);
      return;
    }
    if (!_permissionGranted) {
      _setToken(null);
      return;
    }
    if (!force && _currentToken != null && _currentToken!.isNotEmpty) {
      return;
    }

    try {
      final token = await _messaging.getToken(
        vapidKey: kFirebaseWebVapidKey.isEmpty ? null : kFirebaseWebVapidKey,
      );
      _setToken(token);
    } catch (error, stackTrace) {
      debugPrint('Failed to get FCM token: $error');
      debugPrint(stackTrace.toString());
      _setToken(null);
    }
  }

  void _setToken(String? token) {
    final normalized = token == null || token.isEmpty ? null : token;
    if (_currentToken == normalized) {
      return;
    }
    _currentToken = normalized;
    if (!_tokenController.isClosed) {
      _tokenController.add(_currentToken);
    }
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
