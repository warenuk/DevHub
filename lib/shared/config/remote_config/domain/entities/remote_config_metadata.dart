import 'package:equatable/equatable.dart';

enum RemoteConfigLastFetchStatus { noFetchYet, success, failure, throttled }

class RemoteConfigMetadata extends Equatable {
  const RemoteConfigMetadata({
    required this.lastFetchStatus,
    required this.lastFetchTime,
  });

  final RemoteConfigLastFetchStatus lastFetchStatus;
  final DateTime? lastFetchTime;

  bool get hasFetchedSuccessfully =>
      lastFetchStatus == RemoteConfigLastFetchStatus.success;

  @override
  List<Object?> get props => [lastFetchStatus, lastFetchTime];

  RemoteConfigMetadata copyWith({
    RemoteConfigLastFetchStatus? lastFetchStatus,
    DateTime? lastFetchTime,
  }) {
    return RemoteConfigMetadata(
      lastFetchStatus: lastFetchStatus ?? this.lastFetchStatus,
      lastFetchTime: lastFetchTime ?? this.lastFetchTime,
    );
  }
}
