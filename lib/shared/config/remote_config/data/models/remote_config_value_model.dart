import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_value.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart'
    as firebase_remote_config;

class RemoteConfigValueModel<T> extends RemoteConfigValue<T> {
  const RemoteConfigValueModel({
    required super.key,
    required super.value,
    required super.source,
    super.lastFetchTime,
    super.usedFallback,
  });

  factory RemoteConfigValueModel.fromFirebase({
    required String key,
    required firebase_remote_config.RemoteConfigValue remoteValue,
    required T Function(firebase_remote_config.RemoteConfigValue) parser,
    required T fallback,
    DateTime? lastFetchTime,
  }) {
    final RemoteConfigValueSource source = _mapSource(remoteValue.source);
    var usedFallback = false;
    T parsedValue;
    try {
      parsedValue = parser(remoteValue);
    } catch (_) {
      parsedValue = fallback;
      usedFallback = true;
    }

    if (source == RemoteConfigValueSource.staticValue) {
      parsedValue = fallback;
      usedFallback = true;
    }

    return RemoteConfigValueModel<T>(
      key: key,
      value: parsedValue,
      source: source,
      lastFetchTime: lastFetchTime,
      usedFallback: usedFallback,
    );
  }

  static RemoteConfigValueSource _mapSource(
    firebase_remote_config.ValueSource source,
  ) {
    switch (source) {
      case firebase_remote_config.ValueSource.valueStatic:
        return RemoteConfigValueSource.staticValue;
      case firebase_remote_config.ValueSource.valueDefault:
        return RemoteConfigValueSource.defaultValue;
      case firebase_remote_config.ValueSource.valueRemote:
        return RemoteConfigValueSource.remote;
    }
  }
}
