import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/notifications/data/datasources/push_notifications_remote_data_source.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/notification_authorization.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';
import 'package:devhub_gpt/features/notifications/domain/repositories/push_notifications_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PushNotificationsRepositoryImpl implements PushNotificationsRepository {
  PushNotificationsRepositoryImpl(this._remote);

  final PushNotificationsRemoteDataSource _remote;

  @override
  Future<Either<Failure, void>> deleteToken({String? vapidKey}) async {
    try {
      await _remote.deleteToken(vapidKey: vapidKey);
      return const Right(null);
    } catch (error) {
      return Left(_mapError(error));
    }
  }

  @override
  Future<Either<Failure, PushMessage?>> getInitialMessage() async {
    try {
      final PushMessage? message = await _remote.getInitialMessage();
      return Right(message);
    } catch (error) {
      return Left(_mapError(error));
    }
  }

  @override
  Future<Either<Failure, String?>> getToken({String? vapidKey}) async {
    try {
      final String? token = await _remote.getToken(vapidKey: vapidKey);
      return Right(token);
    } catch (error) {
      return Left(_mapError(error));
    }
  }

  @override
  Future<Either<Failure, NotificationAuthorization>>
  getNotificationSettings() async {
    try {
      final NotificationAuthorization settings = await _remote
          .getNotificationSettings();
      return Right(settings);
    } catch (error) {
      return Left(_mapError(error));
    }
  }

  @override
  Stream<PushMessage> onForegroundMessages() {
    return _remote.onForegroundMessages();
  }

  @override
  Stream<PushMessage> onNotificationOpened() {
    return _remote.onNotificationOpened();
  }

  @override
  Stream<String> onTokenRefresh() => _remote.onTokenRefresh();

  @override
  Future<Either<Failure, NotificationAuthorization>> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
    bool announcement = false,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
  }) async {
    try {
      final NotificationAuthorization settings = await _remote
          .requestPermission(
            alert: alert,
            badge: badge,
            sound: sound,
            announcement: announcement,
            carPlay: carPlay,
            criticalAlert: criticalAlert,
            provisional: provisional,
          );
      return Right(settings);
    } catch (error) {
      return Left(_mapError(error));
    }
  }

  @override
  Future<Either<Failure, void>> setForegroundPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    try {
      await _remote.setForegroundPresentationOptions(
        alert: alert,
        badge: badge,
        sound: sound,
      );
      return const Right(null);
    } catch (error) {
      return Left(_mapError(error));
    }
  }

  Failure _mapError(Object error) {
    if (error is Failure) return error;
    if (error is FirebaseException) {
      return ServerFailure(error.message ?? error.code);
    }
    if (error is PlatformException) {
      return ServerFailure(error.message ?? error.code);
    }
    if (error is MissingPluginException) {
      return ServerFailure(
        error.message ?? 'Firebase Messaging plugin missing',
      );
    }
    if (error is AssertionError) {
      return ServerFailure(error.message?.toString() ?? 'Assertion error');
    }
    debugPrint('Unhandled push notification error: $error');
    return ServerFailure(error.toString());
  }
}
