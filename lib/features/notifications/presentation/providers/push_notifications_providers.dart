import 'package:devhub_gpt/core/constants/firebase_flags.dart';
import 'package:devhub_gpt/features/notifications/data/datasources/firebase_push_notifications_remote_data_source.dart';
import 'package:devhub_gpt/features/notifications/data/datasources/noop_push_notifications_remote_data_source.dart';
import 'package:devhub_gpt/features/notifications/data/datasources/push_notifications_remote_data_source.dart';
import 'package:devhub_gpt/features/notifications/data/repositories/push_notifications_repository_impl.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';
import 'package:devhub_gpt/features/notifications/domain/repositories/push_notifications_repository.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/delete_fcm_token_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/get_fcm_token_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/get_initial_push_message_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/get_notification_settings_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/observe_fcm_token_refresh_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/observe_foreground_messages_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/observe_notification_opened_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/request_push_permission_usecase.dart';
import 'package:devhub_gpt/features/notifications/domain/usecases/set_foreground_presentation_options_usecase.dart';
import 'package:devhub_gpt/features/notifications/presentation/providers/push_notifications_controller.dart';
import 'package:devhub_gpt/features/notifications/presentation/state/push_notifications_state.dart';
import 'package:devhub_gpt/shared/config/firebase_web.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final pushNotificationsRemoteDataSourceProvider =
    Provider<PushNotificationsRemoteDataSource>((ref) {
  if (!kUseFirebaseMessaging || !isFirebaseMessagingSupportedPlatform) {
    return const NoopPushNotificationsRemoteDataSource();
  }
  if (!isFirebaseInitialized) {
    debugPrint(
      'Firebase is not ready yet; deferring push notifications setup.',
    );
    return const NoopPushNotificationsRemoteDataSource();
  }
  try {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    return FirebasePushNotificationsRemoteDataSource(messaging);
  } on MissingPluginException catch (error, stackTrace) {
    debugPrint(
      'FirebaseMessaging plugin missing (${error.message}). Falling back to no-op data source.',
    );
    debugPrint(stackTrace.toString());
    return const NoopPushNotificationsRemoteDataSource();
  } on Object catch (error, stackTrace) {
    debugPrint(
      'Failed to create FirebasePushNotificationsRemoteDataSource: $error',
    );
    debugPrint(stackTrace.toString());
    return const NoopPushNotificationsRemoteDataSource();
  }
});

final pushNotificationsRepositoryProvider =
    Provider<PushNotificationsRepository>((ref) {
  final PushNotificationsRemoteDataSource remote = ref.watch(
    pushNotificationsRemoteDataSourceProvider,
  );
  return PushNotificationsRepositoryImpl(remote);
});

PushNotificationsController _createController(Ref ref) {
  final PushNotificationsRepository repository = ref.watch(
    pushNotificationsRepositoryProvider,
  );
  final bool messagingEnabled =
      kUseFirebaseMessaging && isFirebaseMessagingSupportedPlatform;
  return PushNotificationsController(
    vapidKey: FirebaseWeb.vapidKey,
    getSettings: GetNotificationSettingsUseCase(repository),
    requestPermission: RequestPushPermissionUseCase(repository),
    foregroundOptions: SetForegroundPresentationOptionsUseCase(repository),
    getInitialMessage: GetInitialPushMessageUseCase(repository),
    observeForegroundMessages: ObserveForegroundMessagesUseCase(repository),
    observeNotificationOpened: ObserveNotificationOpenedUseCase(repository),
    getToken: GetFcmTokenUseCase(repository),
    deleteToken: DeleteFcmTokenUseCase(repository),
    observeTokenRefresh: ObserveFcmTokenRefreshUseCase(repository),
    messagingEnabled: messagingEnabled,
  );
}

final pushNotificationsControllerProvider =
    StateNotifierProvider<PushNotificationsController, PushNotificationsState>((
  ref,
) {
  return _createController(ref);
});

final pushNotificationsBootstrapProvider = FutureProvider<void>((ref) async {
  final controller = ref.watch(pushNotificationsControllerProvider.notifier);
  await controller.initialize();
});

final latestPushMessageProvider = Provider<PushMessage?>((ref) {
  final state = ref.watch(pushNotificationsControllerProvider);
  return state.latestMessage;
});

final pushNotificationsHistoryProvider = Provider<List<PushMessage>>((ref) {
  final state = ref.watch(pushNotificationsControllerProvider);
  return state.history;
});

final pushNotificationsTokenProvider = Provider<String?>((ref) {
  final state = ref.watch(pushNotificationsControllerProvider);
  return state.token;
});
