import 'dart:developer';

import 'package:devhub_gpt/shared/config/remote_config/application/remote_config_state.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_feature_flags.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_settings.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/repositories/remote_config_repository.dart';
import 'package:devhub_gpt/shared/config/remote_config/remote_config_defaults.dart';
import 'package:devhub_gpt/shared/config/remote_config/remote_config_keys.dart';
import 'package:devhub_gpt/shared/config/remote_config/remote_config_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteConfigController extends AsyncNotifier<RemoteConfigState> {
  bool _initialized = false;

  RemoteConfigRepository get _repository =>
      ref.read(remoteConfigRepositoryProvider);

  Map<String, Object> get _defaults => ref.read(remoteConfigDefaultsProvider);

  RemoteConfigSettings get _settings => const RemoteConfigSettings();

  @override
  Future<RemoteConfigState> build() {
    return _initialize(forceRefresh: false);
  }

  Future<RemoteConfigState> _initialize({required bool forceRefresh}) async {
    final result = await _repository.initialize(
      settings: _settings,
      defaults: _defaults,
      forceRefresh: forceRefresh,
    );
    return result.fold((failure) {
      log('Remote Config initialization failed: ${failure.message}');
      throw failure;
    }, (metadata) {
      _initialized = true;
      return RemoteConfigState(
        metadata: metadata,
        flags: _buildFeatureFlags(),
      );
    });
  }

  Future<void> refresh({bool force = false}) async {
    if (!_initialized) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(
        () => _initialize(forceRefresh: force),
      );
      return;
    }

    state = const AsyncValue.loading();
    final result = await _repository.refresh(force: force);
    state = result.fold((failure) {
      log('Remote Config refresh failed: ${failure.message}');
      return AsyncValue.error(failure, StackTrace.current);
    }, (metadata) {
      return AsyncValue.data(
        RemoteConfigState(
          metadata: metadata,
          flags: _buildFeatureFlags(),
        ),
      );
    });
  }

  RemoteConfigFeatureFlags _buildFeatureFlags() {
    final bool welcomeBannerEnabled = _repository
        .getBool(
          RemoteConfigKeys.welcomeBannerEnabled,
          fallback: RemoteConfigDefaults.welcomeBannerEnabled,
        )
        .value;
    final int markdownMaxLines = _repository
        .getInt(
          RemoteConfigKeys.markdownMaxLines,
          fallback: RemoteConfigDefaults.markdownMaxLines,
        )
        .value;
    final List<String> supportedLocales = _repository
        .getStringList(
          RemoteConfigKeys.supportedLocales,
          fallback: RemoteConfigDefaults.supportedLocalesList,
        )
        .value;
    final String themeModeRaw = _repository
        .getString(
          RemoteConfigKeys.appThemeMode,
          fallback: RemoteConfigDefaults.appThemeMode,
        )
        .value;
    final String welcomeMessage = _repository
        .getString(
          RemoteConfigKeys.welcomeMessage,
          fallback: RemoteConfigDefaults.welcomeMessage,
        )
        .value;

    return RemoteConfigFeatureFlags(
      welcomeBannerEnabled: welcomeBannerEnabled,
      markdownMaxLines: markdownMaxLines,
      supportedLocales: supportedLocales,
      forcedThemeMode: _mapThemeMode(themeModeRaw),
      welcomeMessage: welcomeMessage,
    );
  }

  ThemeMode? _mapThemeMode(String rawValue) {
    switch (rawValue.toLowerCase()) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case '':
      case 'none':
        return null;
      default:
        return null;
    }
  }
}

final remoteConfigControllerProvider =
    AsyncNotifierProvider<RemoteConfigController, RemoteConfigState>(
  RemoteConfigController.new,
);

final remoteConfigFeatureFlagsProvider =
    Provider<RemoteConfigFeatureFlags?>((ref) {
  final AsyncValue<RemoteConfigState> state =
      ref.watch(remoteConfigControllerProvider);
  return state.maybeWhen(
    data: (RemoteConfigState value) => value.flags,
    orElse: () => null,
  );
});
