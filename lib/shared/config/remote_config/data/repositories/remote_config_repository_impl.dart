import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/datasources/remote_config_data_source.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_metadata.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_settings.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_value.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/repositories/remote_config_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

class RemoteConfigRepositoryImpl implements RemoteConfigRepository {
  RemoteConfigRepositoryImpl(this._remoteDataSource);

  final RemoteConfigDataSource _remoteDataSource;
  RemoteConfigSettings _settings = const RemoteConfigSettings();
  Map<String, Object> _defaults = const <String, Object>{};
  RemoteConfigMetadata? _metadata;
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  RemoteConfigMetadata? get lastMetadata => _metadata;

  @override
  Future<Either<Failure, RemoteConfigMetadata>> initialize({
    RemoteConfigSettings? settings,
    Map<String, Object> defaults = const <String, Object>{},
    bool forceRefresh = false,
  }) async {
    final RemoteConfigSettings appliedSettings =
        settings ?? const RemoteConfigSettings();
    try {
      _settings = appliedSettings;
      _defaults = Map<String, Object>.from(defaults);
      await _remoteDataSource.ensureInitialized(
        settings: appliedSettings,
        defaultValues: _defaults,
      );
      await _remoteDataSource.fetchAndActivate(force: forceRefresh);
      _metadata = _remoteDataSource.getMetadata();
      _initialized = true;
      return Right(_metadata!);
    } catch (error) {
      return Left(_mapError(error));
    }
  }

  @override
  Future<Either<Failure, RemoteConfigMetadata>> refresh({
    bool force = false,
  }) async {
    if (!_initialized) {
      return Left(
        const CacheFailure('Remote Config has not been initialized yet'),
      );
    }
    try {
      await _remoteDataSource.ensureInitialized(
        settings: _settings,
        defaultValues: _defaults,
      );
      await _remoteDataSource.fetchAndActivate(force: force);
      _metadata = _remoteDataSource.getMetadata();
      return Right(_metadata!);
    } catch (error) {
      return Left(_mapError(error));
    }
  }

  @override
  RemoteConfigValue<bool> getBool(
    String key, {
    bool fallback = false,
  }) {
    return _remoteDataSource.getBool(key, fallback: fallback);
  }

  @override
  RemoteConfigValue<double> getDouble(
    String key, {
    double fallback = 0.0,
  }) {
    return _remoteDataSource.getDouble(key, fallback: fallback);
  }

  @override
  RemoteConfigValue<int> getInt(
    String key, {
    int fallback = 0,
  }) {
    return _remoteDataSource.getInt(key, fallback: fallback);
  }

  @override
  RemoteConfigValue<String> getString(
    String key, {
    String fallback = '',
  }) {
    return _remoteDataSource.getString(key, fallback: fallback);
  }

  @override
  RemoteConfigValue<List<String>> getStringList(
    String key, {
    List<String> fallback = const <String>[],
    String separator = ',',
  }) {
    final RemoteConfigValue<String> rawValue = _remoteDataSource.getString(
      key,
      fallback: fallback.join(separator),
    );
    final List<String> parsed = _parseStringList(rawValue.value, separator);
    final bool shouldUseFallback =
        (rawValue.usedFallback || rawValue.isStatic) && fallback.isNotEmpty;
    return RemoteConfigValue<List<String>>(
      key: rawValue.key,
      value: shouldUseFallback ? fallback : parsed,
      source: rawValue.source,
      lastFetchTime: rawValue.lastFetchTime,
      usedFallback: shouldUseFallback,
    );
  }

  List<String> _parseStringList(String raw, String separator) {
    if (raw.trim().isEmpty) return <String>[];
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((dynamic e) => e?.toString() ?? '')
            .where((element) => element.isNotEmpty)
            .toList(growable: false);
      }
    } catch (_) {
      // Ignore JSON parsing errors; fallback to separator parsing.
    }
    return raw
        .split(separator)
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  Failure _mapError(Object error) {
    if (error is Failure) {
      return error;
    }
    if (error is FirebaseException) {
      return ServerFailure(error.message ?? error.code);
    }
    if (error is PlatformException) {
      return ServerFailure(error.message ?? error.code);
    }
    if (error is MissingPluginException) {
      return ServerFailure('Firebase Remote Config plugin missing');
    }
    return ServerFailure(error.toString());
  }
}
