import 'package:devhub_gpt/shared/config/remote_config/data/models/remote_config_metadata_model.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/models/remote_config_value_model.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_settings.dart';

abstract class RemoteConfigDataSource {
  Future<void> ensureInitialized({
    required RemoteConfigSettings settings,
    required Map<String, Object> defaultValues,
  });

  Future<bool> fetchAndActivate({bool force = false});

  RemoteConfigMetadataModel getMetadata();

  RemoteConfigValueModel<bool> getBool(
    String key, {
    required bool fallback,
  });

  RemoteConfigValueModel<int> getInt(
    String key, {
    required int fallback,
  });

  RemoteConfigValueModel<double> getDouble(
    String key, {
    required double fallback,
  });

  RemoteConfigValueModel<String> getString(
    String key, {
    required String fallback,
  });
}
