import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/constants/firebase_flags.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/notification_authorization.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/delete_fcm_token_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/get_fcm_token_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/get_initial_push_message_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/get_notification_settings_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/observe_fcm_token_refresh_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/observe_foreground_messages_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/observe_notification_opened_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/request_push_permission_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/set_foreground_presentation_options_usecase.dart';
import 'package:devhub_gpt/features/notifications/presentation/state/push_notifications_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class PushNotificationsController
    extends StateNotifier<PushNotificationsState> {
  PushNotificationsController({
    required GetNotificationSettingsUseCase getSettings,
    required RequestPushPermissionUseCase requestPermission,
    required SetForegroundPresentationOptionsUseCase foregroundOptions,
    required GetInitialPushMessageUseCase getInitialMessage,
    required ObserveForegroundMessagesUseCase observeForegroundMessages,
    required ObserveNotificationOpenedUseCase observeNotificationOpened,
    required GetFcmTokenUseCase getToken,
    required DeleteFcmTokenUseCase deleteToken,
    required ObserveFcmTokenRefreshUseCase observeTokenRefresh,
    this.vapidKey,
    bool messagingEnabled = true,
  }) : _getSettings = getSettings,
       _requestPermission = requestPermission,
       _foregroundOptions = foregroundOptions,
       _getInitialMessage = getInitialMessage,
       _observeForegroundMessages = observeForegroundMessages,
       _observeNotificationOpened = observeNotificationOpened,
       _getToken = getToken,
       _deleteToken = deleteToken,
       _observeTokenRefresh = observeTokenRefresh,
       _messagingEnabled = messagingEnabled,
       super(PushNotificationsState.initial);

  final GetNotificationSettingsUseCase _getSettings;
  final RequestPushPermissionUseCase _requestPermission;
  final SetForegroundPresentationOptionsUseCase _foregroundOptions;
  final GetInitialPushMessageUseCase _getInitialMessage;
  final ObserveForegroundMessagesUseCase _observeForegroundMessages;
  final ObserveNotificationOpenedUseCase _observeNotificationOpened;
  final GetFcmTokenUseCase _getToken;
  final DeleteFcmTokenUseCase _deleteToken;
  final ObserveFcmTokenRefreshUseCase _observeTokenRefresh;
  final bool _messagingEnabled;
  final String? vapidKey;

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  bool _initializing = false;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || _initializing) return;
    _initializing = true;
    if (!_messagingEnabled || !kUseFirebaseMessaging) {
      state = state.copyWith(initialized: true);
      _initialized = true;
      _initializing = false;
      return;
    }

    final Either<Failure, NotificationAuthorization> settingsResult =
        await _getSettings();
    settingsResult.fold(_logFailure, (NotificationAuthorization authorization) {
      state = state.copyWith(authorization: authorization);
    });

    if (!(state.authorization?.isGranted ?? false)) {
      state = state.copyWith(permissionRequestInProgress: true);
      final Either<Failure, NotificationAuthorization> permissionResult =
          await _requestPermission();
      permissionResult.fold(_logFailure, (
        NotificationAuthorization authorization,
      ) {
        state = state.copyWith(authorization: authorization);
      });
      state = state.copyWith(permissionRequestInProgress: false);
    }

    await _foregroundOptions();

    final Either<Failure, PushMessage?> initialMessageResult =
        await _getInitialMessage();
    initialMessageResult.fold(_logFailure, (PushMessage? message) {
      if (message != null) {
        state = state.copyWith(
          initialMessage: message,
          latestMessage: message,
          history: _appendToHistory(message),
        );
      }
    });

    final Either<Failure, String?> tokenResult = await _getToken(
      vapidKey: vapidKey,
    );
    tokenResult.fold(_logFailure, (String? token) {
      if (token != null && token.isNotEmpty) {
        state = state.copyWith(token: token);
        debugPrint('FCM token: ' + token);
      }
    });

    _subscriptions.add(
      _observeForegroundMessages().listen(
        _handleForegroundMessage,
        onError: _logStreamError,
      ),
    );

    _subscriptions.add(
      _observeNotificationOpened().listen(
        _handleOpenedMessage,
        onError: _logStreamError,
      ),
    );

    _subscriptions.add(
      _observeTokenRefresh().listen((String token) {
        state = state.copyWith(token: token);
        debugPrint('FCM token (refreshed): ' + token);
      }, onError: _logStreamError),
    );

    state = state.copyWith(initialized: true);
    _initialized = true;
    _initializing = false;
  }

  Future<void> refreshToken() async {
    if (!_messagingEnabled || !kUseFirebaseMessaging) return;
    final Either<Failure, String?> result = await _getToken(vapidKey: vapidKey);
    result.fold(_logFailure, (String? token) {
      state = state.copyWith(token: token);
      if (token != null && token.isNotEmpty) {
        debugPrint('FCM token (manual refresh): ' + token);
      }
    });
  }

  Future<void> clearToken() async {
    if (!_messagingEnabled || !kUseFirebaseMessaging) return;
    final Either<Failure, void> result = await _deleteToken(vapidKey: vapidKey);
    result.fold(_logFailure, (_) {
      state = state.copyWith(token: null);
    });
  }

  void acknowledgeLatestMessage() {
    state = state.copyWith(clearLatestMessage: true);
  }

  void _handleForegroundMessage(PushMessage message) {
    state = state.copyWith(
      latestMessage: message,
      history: _appendToHistory(message),
    );
  }

  void _handleOpenedMessage(PushMessage message) {
    state = state.copyWith(
      lastOpenedMessage: message,
      history: _appendToHistory(message, prepend: false),
    );
  }

  List<PushMessage> _appendToHistory(
    PushMessage message, {
    bool prepend = true,
  }) {
    const int maxItems = 20;
    final List<PushMessage> updated = <PushMessage>[...state.history];
    if (prepend) {
      updated.insert(0, message);
      if (updated.length > maxItems) {
        updated.removeRange(maxItems, updated.length);
      }
    } else {
      updated.add(message);
      if (updated.length > maxItems) {
        updated.removeRange(0, updated.length - maxItems);
      }
    }
    return List<PushMessage>.unmodifiable(updated);
  }

  void _logFailure(Failure failure) {
    debugPrint('PushNotificationsController failure: $failure');
  }

  void _logStreamError(Object error, StackTrace stackTrace) {
    debugPrint('PushNotificationsController stream error: $error');
    debugPrint(stackTrace.toString());
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
