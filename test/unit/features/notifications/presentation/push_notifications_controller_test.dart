import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/notification_authorization.dart';
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
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements PushNotificationsRepository {}

void main() {
  late _MockRepository repository;
  late PushNotificationsController controller;
  late StreamController<PushMessage> foregroundController;
  late StreamController<PushMessage> openedController;
  late StreamController<String> tokenRefreshController;

  const NotificationAuthorization deniedAuth = NotificationAuthorization(
    status: NotificationAuthorizationStatus.notDetermined,
    alert: false,
    announcement: false,
    badge: false,
    carPlay: false,
    criticalAlert: false,
    lockScreen: false,
    notificationCenter: false,
    provisional: false,
    showPreviews: false,
    sound: false,
    timeSensitive: false,
  );

  const NotificationAuthorization grantedAuth = NotificationAuthorization(
    status: NotificationAuthorizationStatus.authorized,
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    lockScreen: true,
    notificationCenter: true,
    provisional: false,
    showPreviews: true,
    sound: true,
    timeSensitive: true,
  );

  const PushMessage sampleMessage = PushMessage(
    title: 'Sample',
    body: 'Body',
    messageId: '1',
    data: <String, dynamic>{},
  );

  setUp(() {
    repository = _MockRepository();
    foregroundController = StreamController<PushMessage>.broadcast();
    openedController = StreamController<PushMessage>.broadcast();
    tokenRefreshController = StreamController<String>.broadcast();

    when(
      repository.onForegroundMessages,
    ).thenAnswer((_) => foregroundController.stream);
    when(
      repository.onNotificationOpened,
    ).thenAnswer((_) => openedController.stream);
    when(
      repository.onTokenRefresh,
    ).thenAnswer((_) => tokenRefreshController.stream);
    when(repository.getNotificationSettings).thenAnswer(
      (_) async => const Right<Failure, NotificationAuthorization>(deniedAuth),
    );
    when(
      () => repository.requestPermission(
        alert: any(named: 'alert'),
        announcement: any(named: 'announcement'),
        badge: any(named: 'badge'),
        carPlay: any(named: 'carPlay'),
        criticalAlert: any(named: 'criticalAlert'),
        provisional: any(named: 'provisional'),
        sound: any(named: 'sound'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, NotificationAuthorization>(grantedAuth),
    );
    when(
      () => repository.setForegroundPresentationOptions(
        alert: any(named: 'alert'),
        badge: any(named: 'badge'),
        sound: any(named: 'sound'),
      ),
    ).thenAnswer((_) async => const Right<Failure, void>(null));
    when(repository.getInitialMessage).thenAnswer(
      (_) async => const Right<Failure, PushMessage?>(sampleMessage),
    );
    when(
      () => repository.getToken(vapidKey: any(named: 'vapidKey')),
    ).thenAnswer((_) async => const Right<Failure, String?>('initial-token'));
    when(
      () => repository.deleteToken(vapidKey: any(named: 'vapidKey')),
    ).thenAnswer((_) async => const Right<Failure, void>(null));

    controller = PushNotificationsController(
      getSettings: GetNotificationSettingsUseCase(repository),
      requestPermission: RequestPushPermissionUseCase(repository),
      foregroundOptions: SetForegroundPresentationOptionsUseCase(repository),
      getInitialMessage: GetInitialPushMessageUseCase(repository),
      observeForegroundMessages: ObserveForegroundMessagesUseCase(repository),
      observeNotificationOpened: ObserveNotificationOpenedUseCase(repository),
      getToken: GetFcmTokenUseCase(repository),
      deleteToken: DeleteFcmTokenUseCase(repository),
      observeTokenRefresh: ObserveFcmTokenRefreshUseCase(repository),
      messagingEnabled: true,
    );
  });

  tearDown(() async {
    await foregroundController.close();
    await openedController.close();
    await tokenRefreshController.close();
    controller.dispose();
  });

  test('initialize configures permissions, token and listeners', () async {
    await controller.initialize();

    final PushNotificationsState state = controller.state;
    expect(state.initialized, isTrue);
    expect(state.authorization, grantedAuth);
    expect(state.latestMessage, sampleMessage);
    expect(state.history, contains(sampleMessage));
    expect(state.token, 'initial-token');

    final PushMessage foreground = sampleMessage.copyWith(
      messageId: 'foreground',
    );
    final PushMessage opened = sampleMessage.copyWith(messageId: 'opened');
    foregroundController.add(foreground);
    openedController.add(opened);
    tokenRefreshController.add('refreshed');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(controller.state.latestMessage, foreground);
    expect(controller.state.lastOpenedMessage, opened);
    expect(controller.state.history.first, foreground);
    expect(
      controller.state.history,
      containsAll(<PushMessage>[foreground, opened]),
    );
    expect(controller.state.token, 'refreshed');
  });

  test('acknowledgeLatestMessage clears latest notification flag', () async {
    await controller.initialize();
    expect(controller.state.latestMessage, isNotNull);

    controller.acknowledgeLatestMessage();

    expect(controller.state.latestMessage, isNull);
  });

  test('refreshToken updates token even if previous was null', () async {
    when(
      () => repository.getToken(vapidKey: any(named: 'vapidKey')),
    ).thenAnswer((_) async => const Right<Failure, String?>('refetched'));

    await controller.refreshToken();

    expect(controller.state.token, 'refetched');
  });

  test('clearToken removes current token', () async {
    when(
      () => repository.deleteToken(vapidKey: any(named: 'vapidKey')),
    ).thenAnswer((_) async => const Right<Failure, void>(null));
    controller.state = controller.state.copyWith(token: 'existing');

    await controller.clearToken();

    expect(controller.state.token, isNull);
    verify(
      () => repository.deleteToken(vapidKey: any(named: 'vapidKey')),
    ).called(1);
  });

  test('history is capped at 20 items', () async {
    await controller.initialize();
    for (int i = 0; i < 25; i++) {
      foregroundController.add(sampleMessage.copyWith(messageId: 'msg-$i'));
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(controller.state.history.length, lessThanOrEqualTo(20));
  });
}
