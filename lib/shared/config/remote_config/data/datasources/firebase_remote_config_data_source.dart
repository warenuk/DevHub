import 'dart:async';

import 'package:devhub_gpt/shared/config/remote_config/data/datasources/remote_config_data_source.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/models/remote_config_metadata_model.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/models/remote_config_value_model.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_settings.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart'
    as firebase_remote_config;

class FirebaseRemoteConfigDataSource implements RemoteConfigDataSource {
  FirebaseRemoteConfigDataSource(
    this._remoteConfig,
  );

  final firebase_remote_config.FirebaseRemoteConfig _remoteConfig;
  RemoteConfigSettings? _settings;
  bool _configured = false;
  Completer<void>? _initializingCompleter;

  @override
  Future<void> ensureInitialized({
    required RemoteConfigSettings settings,
    required Map<String, Object> defaultValues,
  }) async {
    _settings = settings;
    _initializingCompleter ??= Completer<void>();
    if (!_configured) {
      await _remoteConfig.setConfigSettings(
        firebase_remote_config.RemoteConfigSettings(
          fetchTimeout: settings.fetchTimeout,
          minimumFetchInterval: settings.minimumFetchInterval,
        ),
      );
      if (defaultValues.isNotEmpty) {
        await _remoteConfig.setDefaults(defaultValues);
      }
      await _remoteConfig.ensureInitialized();
      _configured = true;
      _initializingCompleter?.complete();
    } else {
      await _remoteConfig.setConfigSettings(
        firebase_remote_config.RemoteConfigSettings(
          fetchTimeout: settings.fetchTimeout,
          minimumFetchInterval: settings.minimumFetchInterval,
        ),
      );
      if (defaultValues.isNotEmpty) {
        await _remoteConfig.setDefaults(defaultValues);
      }
      _initializingCompleter?.complete();
    }
  }

  @override
  Future<bool> fetchAndActivate({bool force = false}) async {
    await _initializingCompleter?.future;
    final RemoteConfigSettings? settings = _settings;
    if (force && settings != null) {
      final firebaseSettings = firebase_remote_config.RemoteConfigSettings(
        fetchTimeout: settings.fetchTimeout,
        minimumFetchInterval: Duration.zero,
      );
      await _remoteConfig.setConfigSettings(firebaseSettings);
      try {
        return await _remoteConfig.fetchAndActivate();
      } finally {
        await _remoteConfig.setConfigSettings(
          firebase_remote_config.RemoteConfigSettings(
            fetchTimeout: settings.fetchTimeout,
            minimumFetchInterval: settings.minimumFetchInterval,
          ),
        );
      }
    }
    return _remoteConfig.fetchAndActivate();
  }

  @override
  RemoteConfigMetadataModel getMetadata() {
    return RemoteConfigMetadataModel.fromFirebase(_remoteConfig);
  }

  @override
  RemoteConfigValueModel<bool> getBool(String key, {required bool fallback}) {
    final firebaseValue = _remoteConfig.getValue(key);
    return RemoteConfigValueModel<bool>.fromFirebase(
      key: key,
      remoteValue: firebaseValue,
      parser: (value) => value.asBool(),
      fallback: fallback,
      lastFetchTime: _remoteConfig.lastFetchTime,
    );
  }

  @override
  RemoteConfigValueModel<double> getDouble(
    String key, {
    required double fallback,
  }) {
    final firebaseValue = _remoteConfig.getValue(key);
    return RemoteConfigValueModel<double>.fromFirebase(
      key: key,
      remoteValue: firebaseValue,
      parser: (value) => value.asDouble(),
      fallback: fallback,
      lastFetchTime: _remoteConfig.lastFetchTime,
    );
  }

  @override
  RemoteConfigValueModel<int> getInt(String key, {required int fallback}) {
    final firebaseValue = _remoteConfig.getValue(key);
    return RemoteConfigValueModel<int>.fromFirebase(
      key: key,
      remoteValue: firebaseValue,
      parser: (value) => value.asInt(),
      fallback: fallback,
      lastFetchTime: _remoteConfig.lastFetchTime,
    );
  }

  @override
  RemoteConfigValueModel<String> getString(
    String key, {
    required String fallback,
  }) {
    final firebaseValue = _remoteConfig.getValue(key);
    return RemoteConfigValueModel<String>.fromFirebase(
      key: key,
      remoteValue: firebaseValue,
      parser: (value) => value.asString(),
      fallback: fallback,
      lastFetchTime: _remoteConfig.lastFetchTime,
    );
  }
}
