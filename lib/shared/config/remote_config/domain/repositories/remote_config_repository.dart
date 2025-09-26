import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_metadata.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_settings.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_value.dart';

abstract class RemoteConfigRepository {
  bool get isInitialized;
  RemoteConfigMetadata? get lastMetadata;

  Future<Either<Failure, RemoteConfigMetadata>> initialize({
    RemoteConfigSettings? settings,
    Map<String, Object> defaults = const <String, Object>{},
    bool forceRefresh = false,
  });

  Future<Either<Failure, RemoteConfigMetadata>> refresh({
    bool force = false,
  });

  RemoteConfigValue<bool> getBool(
    String key, {
    bool fallback = false,
  });

  RemoteConfigValue<int> getInt(
    String key, {
    int fallback = 0,
  });

  RemoteConfigValue<double> getDouble(
    String key, {
    double fallback = 0.0,
  });

  RemoteConfigValue<String> getString(
    String key, {
    String fallback = '',
  });

  RemoteConfigValue<List<String>> getStringList(
    String key, {
    List<String> fallback = const <String>[],
    String separator = ',',
  });
}
