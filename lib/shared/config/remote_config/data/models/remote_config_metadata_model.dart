import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_metadata.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart'
    as firebase_remote_config;

class RemoteConfigMetadataModel extends RemoteConfigMetadata {
  const RemoteConfigMetadataModel({
    required super.lastFetchStatus,
    required super.lastFetchTime,
  });

  factory RemoteConfigMetadataModel.fromFirebase(
    firebase_remote_config.FirebaseRemoteConfig remoteConfig,
  ) {
    return RemoteConfigMetadataModel(
      lastFetchStatus: _mapStatus(remoteConfig.lastFetchStatus),
      lastFetchTime: remoteConfig.lastFetchTime,
    );
  }

  static RemoteConfigLastFetchStatus _mapStatus(
    firebase_remote_config.RemoteConfigFetchStatus status,
  ) {
    switch (status) {
      case firebase_remote_config.RemoteConfigFetchStatus.noFetchYet:
        return RemoteConfigLastFetchStatus.noFetchYet;
      case firebase_remote_config.RemoteConfigFetchStatus.success:
        return RemoteConfigLastFetchStatus.success;
      case firebase_remote_config.RemoteConfigFetchStatus.failure:
        return RemoteConfigLastFetchStatus.failure;
      case firebase_remote_config.RemoteConfigFetchStatus.throttle:
        return RemoteConfigLastFetchStatus.throttled;
    }
  }
}
