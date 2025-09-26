import 'dart:developer';

import 'package:devhub_gpt/core/constants/firebase_flags.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/datasources/firebase_remote_config_data_source.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/datasources/in_memory_remote_config_data_source.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/datasources/remote_config_data_source.dart';
import 'package:devhub_gpt/shared/config/remote_config/data/repositories/remote_config_repository_impl.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/repositories/remote_config_repository.dart';
import 'package:devhub_gpt/shared/config/remote_config/remote_config_defaults.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart'
    as firebase_remote_config;

final remoteConfigDefaultsProvider = Provider<Map<String, Object>>((ref) {
  return RemoteConfigDefaults.asMap();
});

final remoteConfigDataSourceProvider = Provider<RemoteConfigDataSource>((ref) {
  if (!kUseFirebaseRemoteConfig || !isFirebaseInitialized) {
    return InMemoryRemoteConfigDataSource();
  }
  try {
    final firebase_remote_config.FirebaseRemoteConfig instance =
        firebase_remote_config.FirebaseRemoteConfig.instance;
    return FirebaseRemoteConfigDataSource(instance);
  } catch (error, stackTrace) {
    log('Falling back to in-memory Remote Config data source: $error');
    log(stackTrace.toString());
    return InMemoryRemoteConfigDataSource();
  }
});

final remoteConfigRepositoryProvider = Provider<RemoteConfigRepository>((ref) {
  final RemoteConfigDataSource dataSource =
      ref.watch(remoteConfigDataSourceProvider);
  return RemoteConfigRepositoryImpl(dataSource);
});
