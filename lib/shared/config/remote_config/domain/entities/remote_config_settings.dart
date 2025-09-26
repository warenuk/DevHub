import 'package:equatable/equatable.dart';

class RemoteConfigSettings extends Equatable {
  const RemoteConfigSettings({
    this.fetchTimeout = const Duration(seconds: 15),
    this.minimumFetchInterval = const Duration(hours: 1),
  });

  final Duration fetchTimeout;
  final Duration minimumFetchInterval;

  RemoteConfigSettings copyWith({
    Duration? fetchTimeout,
    Duration? minimumFetchInterval,
  }) {
    return RemoteConfigSettings(
      fetchTimeout: fetchTimeout ?? this.fetchTimeout,
      minimumFetchInterval: minimumFetchInterval ?? this.minimumFetchInterval,
    );
  }

  @override
  List<Object> get props => [fetchTimeout, minimumFetchInterval];
}
