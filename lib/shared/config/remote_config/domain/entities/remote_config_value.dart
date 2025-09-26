import 'package:equatable/equatable.dart';

enum RemoteConfigValueSource { remote, defaultValue, staticValue }

class RemoteConfigValue<T> extends Equatable {
  const RemoteConfigValue({
    required this.key,
    required this.value,
    required this.source,
    this.lastFetchTime,
    this.usedFallback = false,
  });

  final String key;
  final T value;
  final RemoteConfigValueSource source;
  final DateTime? lastFetchTime;
  final bool usedFallback;

  bool get isRemote => source == RemoteConfigValueSource.remote;
  bool get isDefault => source == RemoteConfigValueSource.defaultValue;
  bool get isStatic => source == RemoteConfigValueSource.staticValue;

  @override
  List<Object?> get props => [key, value, source, lastFetchTime, usedFallback];

  RemoteConfigValue<R> mapValue<R>(R newValue, {bool? usedFallbackOverride}) {
    return RemoteConfigValue<R>(
      key: key,
      value: newValue,
      source: source,
      lastFetchTime: lastFetchTime,
      usedFallback: usedFallbackOverride ?? usedFallback,
    );
  }
}
