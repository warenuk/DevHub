import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/datasources/remote_config_data_source.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/models/remote_config_metadata_model.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/models/remote_config_value_model.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/repositories/remote_config_repository_impl.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_metadata.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_settings.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_value.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteConfigDataSource extends Mock
    implements RemoteConfigDataSource {}

void main() {
  late RemoteConfigRepositoryImpl repository;
  late RemoteConfigDataSource remoteDataSource;

  setUpAll(() {
    registerFallbackValue(const RemoteConfigSettings());
    registerFallbackValue(const <String, Object>{});
  });

  setUp(() {
    remoteDataSource = _MockRemoteConfigDataSource();
    repository = RemoteConfigRepositoryImpl(remoteDataSource);
  });

  group('initialize', () {
    test('returns metadata and marks repository as initialized on success',
        () async {
      final metadata = RemoteConfigMetadataModel(
        lastFetchStatus: RemoteConfigLastFetchStatus.success,
        lastFetchTime: DateTime(2024, 1, 1),
      );
      when(() => remoteDataSource.ensureInitialized(
            settings: any(named: 'settings'),
            defaultValues: any(named: 'defaultValues'),
          )).thenAnswer((_) async {});
      when(() => remoteDataSource.fetchAndActivate(force: any(named: 'force')))
          .thenAnswer((_) async => true);
      when(() => remoteDataSource.getMetadata()).thenReturn(metadata);

      final result = await repository.initialize(
        defaults: <String, Object>{'welcome_banner_enabled': true},
      );

      expect(result.isRight(), isTrue);
      expect(repository.isInitialized, isTrue);
      expect(repository.lastMetadata, equals(metadata));
      verify(() => remoteDataSource.ensureInitialized(
            settings: any(named: 'settings'),
            defaultValues: any(named: 'defaultValues'),
          )).called(1);
      verify(() =>
              remoteDataSource.fetchAndActivate(force: any(named: 'force')))
          .called(1);
    });

    test('returns failure when data source throws FirebaseException', () async {
      when(() => remoteDataSource.ensureInitialized(
            settings: any(named: 'settings'),
            defaultValues: any(named: 'defaultValues'),
          )).thenThrow(
        FirebaseException(plugin: 'firebase_remote_config', message: 'boom'),
      );

      final result = await repository.initialize();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected failure'),
      );
      expect(repository.isInitialized, isFalse);
    });
  });

  group('refresh', () {
    test('returns failure when repository was not initialized', () async {
      final result = await repository.refresh();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('refreshes metadata when initialized', () async {
      final initialMetadata = RemoteConfigMetadataModel(
        lastFetchStatus: RemoteConfigLastFetchStatus.success,
        lastFetchTime: DateTime(2024, 1, 1),
      );
      when(() => remoteDataSource.ensureInitialized(
            settings: any(named: 'settings'),
            defaultValues: any(named: 'defaultValues'),
          )).thenAnswer((_) async {});
      when(() => remoteDataSource.fetchAndActivate(force: any(named: 'force')))
          .thenAnswer((_) async => true);
      when(() => remoteDataSource.getMetadata()).thenReturn(initialMetadata);

      await repository.initialize();

      final refreshedMetadata = RemoteConfigMetadataModel(
        lastFetchStatus: RemoteConfigLastFetchStatus.success,
        lastFetchTime: DateTime(2024, 2, 2),
      );
      when(() => remoteDataSource.getMetadata()).thenReturn(refreshedMetadata);

      final result = await repository.refresh(force: true);

      expect(result.isRight(), isTrue);
      expect(repository.lastMetadata, equals(refreshedMetadata));
      verify(() => remoteDataSource.fetchAndActivate(force: true)).called(1);
    });
  });

  group('value getters', () {
    test('getBool forwards to data source', () {
      const key = 'welcome_banner_enabled';
      final model = RemoteConfigValueModel<bool>(
        key: key,
        value: true,
        source: RemoteConfigValueSource.remote,
        lastFetchTime: DateTime(2024, 1, 1),
      );
      when(() =>
              remoteDataSource.getBool(key, fallback: any(named: 'fallback')))
          .thenReturn(model);

      final value = repository.getBool(key, fallback: false);

      expect(value.value, isTrue);
      expect(value.isRemote, isTrue);
    });

    test('getStringList parses comma separated values', () {
      const key = 'supported_locales';
      final model = RemoteConfigValueModel<String>(
        key: key,
        value: 'en,uk,pl',
        source: RemoteConfigValueSource.remote,
        lastFetchTime: DateTime(2024, 1, 1),
      );
      when(() =>
              remoteDataSource.getString(key, fallback: any(named: 'fallback')))
          .thenReturn(model);

      final value = repository.getStringList(key, fallback: const ['en', 'uk']);

      expect(value.value, equals(<String>['en', 'uk', 'pl']));
      expect(value.isRemote, isTrue);
    });

    test('getStringList falls back when static value', () {
      const key = 'supported_locales';
      final model = RemoteConfigValueModel<String>(
        key: key,
        value: '',
        source: RemoteConfigValueSource.staticValue,
        lastFetchTime: null,
        usedFallback: true,
      );
      when(() =>
              remoteDataSource.getString(key, fallback: any(named: 'fallback')))
          .thenReturn(model);

      final value = repository.getStringList(key, fallback: const ['en']);

      expect(value.value, equals(<String>['en']));
      expect(value.usedFallback, isTrue);
    });

    test('getStringList parses JSON array strings', () {
      const key = 'supported_locales';
      final model = RemoteConfigValueModel<String>(
        key: key,
        value: '["en","uk"]',
        source: RemoteConfigValueSource.remote,
        lastFetchTime: null,
      );
      when(() =>
              remoteDataSource.getString(key, fallback: any(named: 'fallback')))
          .thenReturn(model);

      final value = repository.getStringList(key, fallback: const ['en']);

      expect(value.value, equals(<String>['en', 'uk']));
    });
  });
}
