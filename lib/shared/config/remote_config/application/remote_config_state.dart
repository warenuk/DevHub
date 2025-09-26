import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_feature_flags.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_metadata.dart';

class RemoteConfigState {
  const RemoteConfigState({
    required this.metadata,
    required this.flags,
  });

  final RemoteConfigMetadata metadata;
  final RemoteConfigFeatureFlags flags;

  RemoteConfigState copyWith({
    RemoteConfigMetadata? metadata,
    RemoteConfigFeatureFlags? flags,
  }) {
    return RemoteConfigState(
      metadata: metadata ?? this.metadata,
      flags: flags ?? this.flags,
    );
  }
}
