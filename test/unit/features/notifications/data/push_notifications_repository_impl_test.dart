import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/notifications/data/datasources/push_notifications_remote_data_source.dart';
import 'package:devhub_gpt/features/notifications/data/repositories/push_notifications_repository_impl.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/notification_authorization.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';
import 'package:devhub_gpt/features/notifications/domain/repositories/push_notifications_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteDataSource extends Mock
    implements PushNotificationsRemoteDataSource {}

void main() {
  late PushNotificationsRemoteDataSource remote;
  late PushNotificationsRepository repository;
  const NotificationAuthorization authorization = NotificationAuthorization(
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
  const PushMessage message = PushMessage(
    title: 'Hello',
    body: 'world',
    messageId: '123',
    data: <String, dynamic>{'foo': 'bar'},
  );

  setUp(() {
    remote = _MockRemoteDataSource();
    repository = PushNotificationsRepositoryImpl(remote);
  });

  group('getNotificationSettings', () {
    test('returns Right on success', () async {
      when(
        remote.getNotificationSettings,
      ).thenAnswer((_) async => authorization);

      final Either<Failure, NotificationAuthorization> result = await repository
          .getNotificationSettings();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (NotificationAuthorization value) => expect(value, authorization),
      );
      verify(remote.getNotificationSettings).called(1);
    });

    test('returns Left on error', () async {
      when(
        remote.getNotificationSettings,
      ).thenThrow(PlatformException(code: 'missing'));

      final Either<Failure, NotificationAuthorization> result = await repository
          .getNotificationSettings();

      expect(result.isLeft(), isTrue);
    });
  });

  group('requestPermission', () {
    test('returns authorization when granted', () async {
      when(
        () => remote.requestPermission(
          alert: any(named: 'alert'),
          announcement: any(named: 'announcement'),
          badge: any(named: 'badge'),
          carPlay: any(named: 'carPlay'),
          criticalAlert: any(named: 'criticalAlert'),
          provisional: any(named: 'provisional'),
          sound: any(named: 'sound'),
        ),
      ).thenAnswer((_) async => authorization);

      final Either<Failure, NotificationAuthorization> result = await repository
          .requestPermission();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (NotificationAuthorization value) => expect(value, authorization),
      );
      verify(
        () => remote.requestPermission(
          alert: any(named: 'alert'),
          announcement: any(named: 'announcement'),
          badge: any(named: 'badge'),
          carPlay: any(named: 'carPlay'),
          criticalAlert: any(named: 'criticalAlert'),
          provisional: any(named: 'provisional'),
          sound: any(named: 'sound'),
        ),
      ).called(1);
    });

    test('returns failure when data source throws', () async {
      when(
        () => remote.requestPermission(
          alert: any(named: 'alert'),
          announcement: any(named: 'announcement'),
          badge: any(named: 'badge'),
          carPlay: any(named: 'carPlay'),
          criticalAlert: any(named: 'criticalAlert'),
          provisional: any(named: 'provisional'),
          sound: any(named: 'sound'),
        ),
      ).thenThrow(Exception('boom'));

      final Either<Failure, NotificationAuthorization> result = await repository
          .requestPermission();

      expect(result.isLeft(), isTrue);
    });
  });

  test('getInitialMessage returns mapped result', () async {
    when(remote.getInitialMessage).thenAnswer((_) async => message);

    final Either<Failure, PushMessage?> result = await repository
        .getInitialMessage();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected success'),
      (PushMessage? value) => expect(value, message),
    );
  });

  test('getToken returns value', () async {
    when(
      () => remote.getToken(vapidKey: any(named: 'vapidKey')),
    ).thenAnswer((_) async => 'token-123');

    final Either<Failure, String?> result = await repository.getToken(
      vapidKey: 'abc',
    );

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected success'),
      (String? value) => expect(value, 'token-123'),
    );
  });

  test('deleteToken propagates errors', () async {
    when(
      () => remote.deleteToken(vapidKey: any(named: 'vapidKey')),
    ).thenThrow(Exception('fail'));

    final Either<Failure, void> result = await repository.deleteToken(
      vapidKey: 'abc',
    );

    expect(result.isLeft(), isTrue);
  });

  test('setForegroundPresentationOptions delegates to remote', () async {
    when(
      () => remote.setForegroundPresentationOptions(
        alert: any(named: 'alert'),
        badge: any(named: 'badge'),
        sound: any(named: 'sound'),
      ),
    ).thenAnswer((_) async {});

    final Either<Failure, void> result = await repository
        .setForegroundPresentationOptions();

    expect(result.isRight(), isTrue);
    verify(
      () => remote.setForegroundPresentationOptions(
        alert: any(named: 'alert'),
        badge: any(named: 'badge'),
        sound: any(named: 'sound'),
      ),
    ).called(1);
  });

  test('onForegroundMessages proxies the stream', () async {
    final StreamController<PushMessage> controller =
        StreamController<PushMessage>();
    when(remote.onForegroundMessages).thenAnswer((_) => controller.stream);

    final Stream<PushMessage> stream = repository.onForegroundMessages();
    expect(stream, isA<Stream<PushMessage>>());

    unawaited(expectLater(stream, emitsInOrder(<dynamic>[message, emitsDone])));
    controller.add(message);
    await controller.close();
  });

  test('onNotificationOpened proxies stream', () async {
    final StreamController<PushMessage> controller =
        StreamController<PushMessage>();
    when(remote.onNotificationOpened).thenAnswer((_) => controller.stream);

    final Stream<PushMessage> stream = repository.onNotificationOpened();
    expect(stream, isA<Stream<PushMessage>>());

    unawaited(expectLater(stream, emitsInOrder(<dynamic>[message, emitsDone])));
    controller.add(message);
    await controller.close();
  });

  test('onTokenRefresh proxies stream', () async {
    final StreamController<String> controller = StreamController<String>();
    when(remote.onTokenRefresh).thenAnswer((_) => controller.stream);

    final Stream<String> stream = repository.onTokenRefresh();
    expect(stream, isA<Stream<String>>());

    unawaited(expectLater(stream, emitsInOrder(<dynamic>['token', emitsDone])));
    controller.add('token');
    await controller.close();
  });
}
