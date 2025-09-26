import 'dart:convert';

import 'package:devhub_gpt/shared/config/remote_config/data/datasources/remote_config_data_source.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/models/remote_config_metadata_model.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/models/remote_config_value_model.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_metadata.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_settings.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_value.dart';

class InMemoryRemoteConfigDataSource implements RemoteConfigDataSource {
  InMemoryRemoteConfigDataSource({
    Map<String, Object?>? remoteOverrides,
  }) : _remoteOverrides = Map<String, Object?>.from(
          remoteOverrides ?? <String, Object?>{},
        );

  final Map<String, Object?> _remoteOverrides;
  Map<String, Object> _defaults = <String, Object>{};
  RemoteConfigMetadataModel _metadata = const RemoteConfigMetadataModel(
    lastFetchStatus: RemoteConfigLastFetchStatus.noFetchYet,
    lastFetchTime: null,
  );
  bool _fetched = false;

  @override
  Future<void> ensureInitialized({
    required RemoteConfigSettings settings,
    required Map<String, Object> defaultValues,
  }) async {
    _defaults = Map<String, Object>.from(defaultValues);
  }

  @override
  Future<bool> fetchAndActivate({bool force = false}) async {
    _fetched = true;
    _metadata = RemoteConfigMetadataModel(
      lastFetchStatus: RemoteConfigLastFetchStatus.success,
      lastFetchTime: DateTime.now(),
    );
    return true;
  }

  void setRemoteValue(String key, Object? value) {
    _remoteOverrides[key] = value;
  }

  @override
  RemoteConfigMetadataModel getMetadata() => _metadata;

  @override
  RemoteConfigValueModel<bool> getBool(String key, {required bool fallback}) {
    final Object? value = _resolveValue(key);
    return RemoteConfigValueModel<bool>(
      key: key,
      value: value is bool ? value : fallback,
      source: _sourceFor(key, value),
      lastFetchTime: _metadata.lastFetchTime,
      usedFallback: value is! bool,
    );
  }

  @override
  RemoteConfigValueModel<double> getDouble(
    String key, {
    required double fallback,
  }) {
    final Object? value = _resolveValue(key);
    double resolved;
    var usedFallback = false;
    if (value is num) {
      resolved = value.toDouble();
    } else if (value is String) {
      resolved = double.tryParse(value) ?? fallback;
      usedFallback = double.tryParse(value) == null;
    } else {
      resolved = fallback;
      usedFallback = true;
    }
    return RemoteConfigValueModel<double>(
      key: key,
      value: resolved,
      source: _sourceFor(key, value),
      lastFetchTime: _metadata.lastFetchTime,
      usedFallback: usedFallback,
    );
  }

  @override
  RemoteConfigValueModel<int> getInt(String key, {required int fallback}) {
    final Object? value = _resolveValue(key);
    int resolved;
    var usedFallback = false;
    if (value is int) {
      resolved = value;
    } else if (value is num) {
      resolved = value.toInt();
    } else if (value is String) {
      resolved = int.tryParse(value) ?? fallback;
      usedFallback = int.tryParse(value) == null;
    } else {
      resolved = fallback;
      usedFallback = true;
    }
    return RemoteConfigValueModel<int>(
      key: key,
      value: resolved,
      source: _sourceFor(key, value),
      lastFetchTime: _metadata.lastFetchTime,
      usedFallback: usedFallback,
    );
  }

  @override
  RemoteConfigValueModel<String> getString(
    String key, {
    required String fallback,
  }) {
    final Object? value = _resolveValue(key);
    if (value is String) {
      return RemoteConfigValueModel<String>(
        key: key,
        value: value,
        source: _sourceFor(key, value),
        lastFetchTime: _metadata.lastFetchTime,
      );
    }
    if (value is List || value is Map) {
      return RemoteConfigValueModel<String>(
        key: key,
        value: jsonEncode(value),
        source: _sourceFor(key, value),
        lastFetchTime: _metadata.lastFetchTime,
      );
    }
    return RemoteConfigValueModel<String>(
      key: key,
      value: fallback,
      source: value == null
          ? RemoteConfigValueSource.staticValue
          : _sourceFor(key, value),
      lastFetchTime: _metadata.lastFetchTime,
      usedFallback: true,
    );
  }

  Object? _resolveValue(String key) {
    if (_fetched && _remoteOverrides.containsKey(key)) {
      return _remoteOverrides[key];
    }
    if (_defaults.containsKey(key)) {
      return _defaults[key];
    }
    return null;
  }

  RemoteConfigValueSource _sourceFor(String key, Object? value) {
    if (_fetched && _remoteOverrides.containsKey(key)) {
      return RemoteConfigValueSource.remote;
    }
    if (_defaults.containsKey(key)) {
      return RemoteConfigValueSource.defaultValue;
    }
    return RemoteConfigValueSource.staticValue;
  }
}
