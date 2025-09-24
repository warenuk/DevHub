import 'package:devhub_gpt/features/notifications/domain/entities/notification_authorization.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';
import 'package:equatable/equatable.dart';

class PushNotificationsState extends Equatable {
  const PushNotificationsState({
    this.authorization,
    this.initialMessage,
    this.latestMessage,
    this.lastOpenedMessage,
    this.token,
    this.history = const <PushMessage>[],
    this.initialized = false,
    this.permissionRequestInProgress = false,
  });

  static const Object _undefined = Object();

  final NotificationAuthorization? authorization;
  final PushMessage? initialMessage;
  final PushMessage? latestMessage;
  final PushMessage? lastOpenedMessage;
  final String? token;
  final List<PushMessage> history;
  final bool initialized;
  final bool permissionRequestInProgress;

  PushNotificationsState copyWith({
    Object? authorization = _undefined,
    Object? initialMessage = _undefined,
    Object? latestMessage = _undefined,
    Object? lastOpenedMessage = _undefined,
    Object? token = _undefined,
    List<PushMessage>? history,
    bool? initialized,
    bool? permissionRequestInProgress,
    bool clearLatestMessage = false,
  }) {
    return PushNotificationsState(
      authorization: identical(authorization, _undefined)
          ? this.authorization
          : authorization as NotificationAuthorization?,
      initialMessage: identical(initialMessage, _undefined)
          ? this.initialMessage
          : initialMessage as PushMessage?,
      latestMessage: clearLatestMessage
          ? null
          : identical(latestMessage, _undefined)
              ? this.latestMessage
              : latestMessage as PushMessage?,
      lastOpenedMessage: identical(lastOpenedMessage, _undefined)
          ? this.lastOpenedMessage
          : lastOpenedMessage as PushMessage?,
      token: identical(token, _undefined)
          ? this.token
          : token as String?,
      history: history ?? this.history,
      initialized: initialized ?? this.initialized,
      permissionRequestInProgress:
          permissionRequestInProgress ?? this.permissionRequestInProgress,
    );
  }

  static const PushNotificationsState initial = PushNotificationsState();

  @override
  List<Object?> get props => <Object?>[
    authorization,
    initialMessage,
    latestMessage,
    lastOpenedMessage,
    token,
    history,
    initialized,
    permissionRequestInProgress,
  ];
}
