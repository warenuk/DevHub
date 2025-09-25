import 'package:flutter/widgets.dart';

/// Supported advertisement integration modes.
enum AdsMode {
  /// Advertising features are disabled.
  off,

  /// Google Publisher Tag demo inventory for Flutter web.
  webGpt,
}

/// Static configuration of the advertisement integration.
class AdsConfig {
  const AdsConfig({
    required this.mode,
    required this.slotId,
    required this.slotPath,
    required this.slotSize,
  });

  factory AdsConfig.fromEnvironment() {
    const modeStr = String.fromEnvironment('ADS_MODE', defaultValue: 'off');
    final mode = switch (modeStr.toLowerCase()) {
      'web_gpt' => AdsMode.webGpt,
      _ => AdsMode.off,
    };

    const slotId = String.fromEnvironment(
      'ADS_SLOT_ID',
      defaultValue: 'div-gpt-ad-1',
    );
    const slotPath = String.fromEnvironment(
      'ADS_SLOT_PATH',
      defaultValue: '/6355419/Travel/Europe/France/Paris',
    );
    const slotSizeRaw = String.fromEnvironment(
      'ADS_SLOT_SIZE',
      defaultValue: '300x250',
    );

    return AdsConfig(
      mode: mode,
      slotId: slotId.isEmpty ? 'div-gpt-ad-1' : slotId,
      slotPath:
          slotPath.isEmpty ? '/6355419/Travel/Europe/France/Paris' : slotPath,
      slotSize: AdSlotSize.fromString(slotSizeRaw),
    );
  }

  final AdsMode mode;
  final String slotId;
  final String slotPath;
  final AdSlotSize slotSize;

  bool get isEnabled => mode != AdsMode.off;

  AdsConfig copyWith({
    AdsMode? mode,
    String? slotId,
    String? slotPath,
    AdSlotSize? slotSize,
  }) {
    return AdsConfig(
      mode: mode ?? this.mode,
      slotId: slotId ?? this.slotId,
      slotPath: slotPath ?? this.slotPath,
      slotSize: slotSize ?? this.slotSize,
    );
  }
}

/// Banner slot size descriptor.
class AdSlotSize {
  const AdSlotSize({required this.width, required this.height});

  factory AdSlotSize.fromString(String value) {
    final sanitized = value.trim();
    final match = _slotSizePattern.firstMatch(sanitized);
    if (match == null) {
      return const AdSlotSize(width: 300, height: 250);
    }
    final width = int.tryParse(match.group(1) ?? '300') ?? 300;
    final height = int.tryParse(match.group(2) ?? '250') ?? 250;
    return AdSlotSize(width: width, height: height);
  }

  static final RegExp _slotSizePattern = RegExp(r'^(\d+)[xX](\d+)$');

  final int width;
  final int height;

  double get widthPx => width.toDouble();
  double get heightPx => height.toDouble();
}

/// Shared interface for advertisement services.
abstract class AdsService {
  AdsConfig get config;

  bool get isEnabled;

  Widget buildBanner({Key? key});

  void dispose() {}
}

/// Placeholder service used when ads are disabled.
class AdsServiceOff implements AdsService {
  const AdsServiceOff(this.config);

  @override
  final AdsConfig config;

  @override
  bool get isEnabled => false;

  @override
  Widget buildBanner({Key? key}) {
    return SizedBox(
      key: key,
      width: config.slotSize.widthPx,
      height: config.slotSize.heightPx,
    );
  }

  @override
  void dispose() {}
}
