import 'package:equatable/equatable.dart';

/// Represents the notification permission state returned by Firebase Messaging.
class NotificationAuthorization extends Equatable {
  const NotificationAuthorization({
    required this.status,
    required this.alert,
    required this.announcement,
    required this.badge,
    required this.carPlay,
    required this.criticalAlert,
    required this.lockScreen,
    required this.notificationCenter,
    required this.provisional,
    required this.showPreviews,
    required this.sound,
    required this.timeSensitive,
  });

  final NotificationAuthorizationStatus status;
  final bool alert;
  final bool announcement;
  final bool badge;
  final bool carPlay;
  final bool criticalAlert;
  final bool lockScreen;
  final bool notificationCenter;
  final bool provisional;
  final bool showPreviews;
  final bool sound;
  final bool timeSensitive;

  bool get isGranted =>
      status == NotificationAuthorizationStatus.authorized || provisional;

  NotificationAuthorization copyWith({
    NotificationAuthorizationStatus? status,
    bool? alert,
    bool? announcement,
    bool? badge,
    bool? carPlay,
    bool? criticalAlert,
    bool? lockScreen,
    bool? notificationCenter,
    bool? provisional,
    bool? showPreviews,
    bool? sound,
    bool? timeSensitive,
  }) {
    return NotificationAuthorization(
      status: status ?? this.status,
      alert: alert ?? this.alert,
      announcement: announcement ?? this.announcement,
      badge: badge ?? this.badge,
      carPlay: carPlay ?? this.carPlay,
      criticalAlert: criticalAlert ?? this.criticalAlert,
      lockScreen: lockScreen ?? this.lockScreen,
      notificationCenter: notificationCenter ?? this.notificationCenter,
      provisional: provisional ?? this.provisional,
      showPreviews: showPreviews ?? this.showPreviews,
      sound: sound ?? this.sound,
      timeSensitive: timeSensitive ?? this.timeSensitive,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    alert,
    announcement,
    badge,
    carPlay,
    criticalAlert,
    lockScreen,
    notificationCenter,
    provisional,
    showPreviews,
    sound,
    timeSensitive,
  ];
}

enum NotificationAuthorizationStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
}
