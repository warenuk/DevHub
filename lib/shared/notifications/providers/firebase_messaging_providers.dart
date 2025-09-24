import 'package:devhub_gpt/shared/constants/firebase_flags.dart';
import 'package:devhub_gpt/shared/notifications/commit_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commitNotificationServiceProvider = Provider<CommitNotificationService>((
  ref,
) {
  return CommitNotificationService.instance;
});

class PushNotificationStatus {
  const PushNotificationStatus({
    required this.firebaseEnabled,
    required this.permissionGranted,
    required this.webNotificationsSupported,
    required this.permissionState,
    required this.token,
  });

  final bool firebaseEnabled;
  final bool permissionGranted;
  final bool webNotificationsSupported;
  final String permissionState;
  final String? token;

  bool get hasToken => token != null && token!.isNotEmpty;

  bool get isReady =>
      firebaseEnabled &&
      webNotificationsSupported &&
      permissionGranted &&
      hasToken;
}

final pushNotificationStatusProvider = StreamProvider<PushNotificationStatus>((
  ref,
) async* {
  final service = ref.watch(commitNotificationServiceProvider);

  if (!kUseFirebase) {
    yield const PushNotificationStatus(
      firebaseEnabled: false,
      permissionGranted: false,
      webNotificationsSupported: false,
      permissionState: 'disabled',
      token: null,
    );
    return;
  }

  await service.ensureInitialized();

  PushNotificationStatus buildStatus(String? token) {
    return PushNotificationStatus(
      firebaseEnabled: true,
      permissionGranted: service.permissionGranted,
      webNotificationsSupported: service.webNotificationsSupported,
      permissionState: service.notificationPermissionState,
      token: token,
    );
  }

  yield buildStatus(await service.getCurrentToken());

  await for (final token in service.tokenChanges) {
    yield buildStatus(token);
  }
});

class PushTestState {
  const PushTestState.initial()
    : isScheduling = false,
      lastRequestedAt = null,
      lastDeliveredAt = null,
      lastError = null,
      lastSuccess = false;

  const PushTestState({
    required this.isScheduling,
    required this.lastRequestedAt,
    required this.lastDeliveredAt,
    required this.lastError,
    required this.lastSuccess,
  });

  final bool isScheduling;
  final DateTime? lastRequestedAt;
  final DateTime? lastDeliveredAt;
  final String? lastError;
  final bool lastSuccess;
}

class PushTestController extends Notifier<PushTestState> {
  @override
  PushTestState build() => const PushTestState.initial();

  Future<void> sendTestPush() async {
    final service = ref.read(commitNotificationServiceProvider);

    final requestedAt = DateTime.now();
    state = PushTestState(
      isScheduling: true,
      lastRequestedAt: requestedAt,
      lastDeliveredAt: state.lastDeliveredAt,
      lastError: null,
      lastSuccess: false,
    );

    try {
      await service.scheduleTestNotification();
      state = PushTestState(
        isScheduling: false,
        lastRequestedAt: requestedAt,
        lastDeliveredAt: DateTime.now(),
        lastError: null,
        lastSuccess: true,
      );
      ref.invalidate(pushNotificationStatusProvider);
    } on PushNotificationException catch (error) {
      debugPrint('Push notification scheduling failed: ${error.message}');
      state = PushTestState(
        isScheduling: false,
        lastRequestedAt: requestedAt,
        lastDeliveredAt: state.lastDeliveredAt,
        lastError: error.message,
        lastSuccess: false,
      );
    } catch (error, stackTrace) {
      debugPrint('Unexpected push scheduling error: $error');
      debugPrint(stackTrace.toString());
      state = PushTestState(
        isScheduling: false,
        lastRequestedAt: requestedAt,
        lastDeliveredAt: state.lastDeliveredAt,
        lastError: error.toString(),
        lastSuccess: false,
      );
    }
  }
}

final pushTestControllerProvider =
    NotifierProvider<PushTestController, PushTestState>(PushTestController.new);

Future<void> refreshPushNotificationStatus(WidgetRef ref) async {
  final service = ref.read(commitNotificationServiceProvider);
  await service.refreshToken();
  ref.invalidate(pushNotificationStatusProvider);
}
