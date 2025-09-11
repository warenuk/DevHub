import 'package:flutter/material.dart';

@immutable
class DevHubTheme extends ThemeExtension<DevHubTheme> {
  final Color glow;
  final Color graphLine;
  final Color graphFill;

  const DevHubTheme({
    required this.glow,
    required this.graphLine,
    required this.graphFill,
  });

  @override
  DevHubTheme copyWith({Color? glow, Color? graphLine, Color? graphFill}) {
    return DevHubTheme(
      glow: glow ?? this.glow,
      graphLine: graphLine ?? this.graphLine,
      graphFill: graphFill ?? this.graphFill,
    );
  }

  @override
  DevHubTheme lerp(ThemeExtension<DevHubTheme>? other, double t) {
    if (other is! DevHubTheme) return this;
    return DevHubTheme(
      glow: Color.lerp(glow, other.glow, t)!,
      graphLine: Color.lerp(graphLine, other.graphLine, t)!,
      graphFill: Color.lerp(graphFill, other.graphFill, t)!,
    );
  }
}