import 'package:devhub_gpt/shared/ads/ads_service.dart';
import 'package:devhub_gpt/shared/ads/ads_service_stub.dart'
    if (dart.library.html) 'package:devhub_gpt/shared/ads/ads_service_web_gpt.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adsConfigProvider = Provider<AdsConfig>((ref) {
  return AdsConfig.fromEnvironment();
});

final adsServiceProvider = Provider<AdsService>((ref) {
  final config = ref.watch(adsConfigProvider);
  if (config.mode == AdsMode.webGpt && kIsWeb) {
    final service = createAdsService(config);
    ref.onDispose(service.dispose);
    return service;
  }
  return AdsServiceOff(config);
});
