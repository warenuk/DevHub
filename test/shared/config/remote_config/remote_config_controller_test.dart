import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/shared/config/remote_config/application/remote_config_controller.dart';
import 'package:devhub_gpt/shared/config/remote_config/application/remote_config_state.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_metadata.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_settings.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_value.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/repositories/remote_config_repository.dart';
import 'package:devhub_gpt/shared/config/remote_config/remote_config_defaults.dart';
import 'package:devhub_gpt/shared/config/remote_config/remote_config_keys.dart';
import 'package:devhub_gpt/shared/config/remote_config/remote_config_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteConfigRepository extends Mock
    implements RemoteConfigRepository {}

void main() {
  late ProviderContainer container;
  late RemoteConfigRepository repository;

  setUpAll(() {
    registerFallbackValue(const RemoteConfigSettings());
    registerFallbackValue(const <String, Object>{});
  });

  setUp(() {
    repository = _MockRemoteConfigRepository();
    container = ProviderContainer(
      overrides: [
        remoteConfigRepositoryProvider.overrideWithValue(repository),
        remoteConfigDefaultsProvider.overrideWithValue(
          RemoteConfigDefaults.asMap(),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  RemoteConfigValue<T> _remoteValue<T>(T value) {
    return RemoteConfigValue<T>(
      key: 'key',
      value: value,
      source: RemoteConfigValueSource.remote,
      lastFetchTime: DateTime(2024, 1, 1),
    );
  }

  Future<void> _pumpController() async {
    await container.read(remoteConfigControllerProvider.future);
  }

  group('initialize', () {
    test('emits data state when initialization succeeds', () async {
      final metadata = RemoteConfigMetadata(
        lastFetchStatus: RemoteConfigLastFetchStatus.success,
        lastFetchTime: DateTime(2024, 1, 1),
      );
      when(() => repository.initialize(
            settings: any(named: 'settings'),
            defaults: any(named: 'defaults'),
            forceRefresh: any(named: 'forceRefresh'),
          )).thenAnswer((_) async => Right(metadata));
      when(() => repository.getBool(any(), fallback: any(named: 'fallback')))
          .thenReturn(_remoteValue<bool>(true));
      when(() => repository.getInt(any(), fallback: any(named: 'fallback')))
          .thenAnswer((invocation) {
        final key = invocation.positionalArguments.first as String;
        if (key == RemoteConfigKeys.markdownMaxLines) {
          return _remoteValue<int>(10);
        }
        if (key == RemoteConfigKeys.onboardingVariant) {
          return _remoteValue<int>(2);
        }
        return _remoteValue<int>(0);
      });
      when(() => repository.getStringList(
            any(),
            fallback: any(named: 'fallback'),
            separator: any(named: 'separator'),
          )).thenReturn(
        RemoteConfigValue<List<String>>(
          key: 'supported_locales',
          value: const <String>['en', 'uk'],
          source: RemoteConfigValueSource.remote,
          lastFetchTime: DateTime(2024, 1, 1),
        ),
      );
      when(() => repository.getString(any(), fallback: any(named: 'fallback')))
          .thenAnswer((invocation) {
        final key = invocation.positionalArguments.first as String;
        if (key == RemoteConfigKeys.appThemeMode) {
          return _remoteValue<String>('dark');
        }
        if (key == RemoteConfigKeys.welcomeMessage) {
          return _remoteValue<String>('Welcome to DevHub');
        }
        return _remoteValue<String>('');
      });

      await _pumpController();

      final state = container.read(remoteConfigControllerProvider).requireValue;
      expect(state.metadata, equals(metadata));
      expect(state.flags.welcomeBannerEnabled, isTrue);
      expect(state.flags.markdownMaxLines, equals(10));
      expect(state.flags.forcedThemeMode, equals(ThemeMode.dark));
      expect(state.flags.onboardingVariant, equals(2));
    });

    test('emits error state when initialization fails', () async {
      final failure = ServerFailure('init failed');
      when(() => repository.initialize(
            settings: any(named: 'settings'),
            defaults: any(named: 'defaults'),
            forceRefresh: any(named: 'forceRefresh'),
          )).thenAnswer((_) async => Left(failure));

      container.read(remoteConfigControllerProvider);
      await pumpEventQueue(times: 5);

      final state = container.read(remoteConfigControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, equals(failure));
    });
  });

  group('refresh', () {
    Future<RemoteConfigState> _prepareInitializedState({
      int markdownMaxLines = 6,
      int onboardingVariant = 1,
    }) async {
      final metadata = RemoteConfigMetadata(
        lastFetchStatus: RemoteConfigLastFetchStatus.success,
        lastFetchTime: DateTime(2024, 1, 1),
      );
      when(() => repository.initialize(
            settings: any(named: 'settings'),
            defaults: any(named: 'defaults'),
            forceRefresh: any(named: 'forceRefresh'),
          )).thenAnswer((_) async => Right(metadata));
      when(() => repository.getBool(any(), fallback: any(named: 'fallback')))
          .thenReturn(_remoteValue<bool>(true));
      when(() => repository.getInt(any(), fallback: any(named: 'fallback')))
          .thenAnswer((invocation) {
        final key = invocation.positionalArguments.first as String;
        if (key == RemoteConfigKeys.markdownMaxLines) {
          return _remoteValue<int>(markdownMaxLines);
        }
        if (key == RemoteConfigKeys.onboardingVariant) {
          return _remoteValue<int>(onboardingVariant);
        }
        return _remoteValue<int>(0);
      });
      when(() => repository.getStringList(
            any(),
            fallback: any(named: 'fallback'),
            separator: any(named: 'separator'),
          )).thenReturn(
        RemoteConfigValue<List<String>>(
          key: 'supported_locales',
          value: const <String>['en', 'uk'],
          source: RemoteConfigValueSource.remote,
          lastFetchTime: DateTime(2024, 1, 1),
        ),
      );
      when(() => repository.getString(any(), fallback: any(named: 'fallback')))
          .thenAnswer((invocation) {
        final key = invocation.positionalArguments.first as String;
        if (key == RemoteConfigKeys.appThemeMode) {
          return _remoteValue<String>('system');
        }
        if (key == RemoteConfigKeys.welcomeMessage) {
          return _remoteValue<String>('');
        }
        return _remoteValue<String>('');
      });
      await _pumpController();
      return container.read(remoteConfigControllerProvider).requireValue;
    }

    test('refresh updates state with latest metadata', () async {
      await _prepareInitializedState();
      final refreshedMetadata = RemoteConfigMetadata(
        lastFetchStatus: RemoteConfigLastFetchStatus.success,
        lastFetchTime: DateTime(2024, 2, 2),
      );
      when(() => repository.refresh(force: any(named: 'force')))
          .thenAnswer((_) async => Right(refreshedMetadata));
      when(() => repository.getBool(any(), fallback: any(named: 'fallback')))
          .thenReturn(_remoteValue<bool>(false));
      when(() => repository.getInt(any(), fallback: any(named: 'fallback')))
          .thenAnswer((invocation) {
        final key = invocation.positionalArguments.first as String;
        if (key == RemoteConfigKeys.markdownMaxLines) {
          return _remoteValue<int>(4);
        }
        if (key == RemoteConfigKeys.onboardingVariant) {
          return _remoteValue<int>(3);
        }
        return _remoteValue<int>(0);
      });
      when(() => repository.getStringList(
            any(),
            fallback: any(named: 'fallback'),
            separator: any(named: 'separator'),
          )).thenReturn(
        RemoteConfigValue<List<String>>(
          key: 'supported_locales',
          value: const <String>['en'],
          source: RemoteConfigValueSource.remote,
          lastFetchTime: DateTime(2024, 2, 2),
        ),
      );
      when(() => repository.getString(any(), fallback: any(named: 'fallback')))
          .thenAnswer((invocation) {
        final key = invocation.positionalArguments.first as String;
        if (key == RemoteConfigKeys.appThemeMode) {
          return _remoteValue<String>('light');
        }
        if (key == RemoteConfigKeys.welcomeMessage) {
          return _remoteValue<String>('Updated!');
        }
        return _remoteValue<String>('');
      });

      await container
          .read(remoteConfigControllerProvider.notifier)
          .refresh(force: true);

      final state = container.read(remoteConfigControllerProvider).requireValue;
      expect(state.metadata, equals(refreshedMetadata));
      expect(state.flags.welcomeBannerEnabled, isFalse);
      expect(state.flags.markdownMaxLines, equals(4));
      expect(state.flags.supportedLocales, equals(const <String>['en']));
      expect(state.flags.forcedThemeMode, equals(ThemeMode.light));
      expect(state.flags.onboardingVariant, equals(3));
    });

    test('refresh emits error when repository returns failure', () async {
      final previousState = await _prepareInitializedState();
      final failure = ServerFailure('refresh failed');
      when(() => repository.refresh(force: any(named: 'force')))
          .thenAnswer((_) async => Left(failure));

      await container.read(remoteConfigControllerProvider.notifier).refresh();

      final state = container.read(remoteConfigControllerProvider);
      expect(state.hasError, isFalse);
      final value = state.requireValue;
      expect(value.metadata, equals(previousState.metadata));
      expect(value.flags, equals(previousState.flags));
    });
  });
}
