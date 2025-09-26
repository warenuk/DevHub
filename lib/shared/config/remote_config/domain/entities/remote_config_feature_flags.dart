import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RemoteConfigFeatureFlags extends Equatable {
  const RemoteConfigFeatureFlags({
    required this.welcomeBannerEnabled,
    required this.markdownMaxLines,
    required this.supportedLocales,
    required this.forcedThemeMode,
    required this.welcomeMessage,
  });

  final bool welcomeBannerEnabled;
  final int markdownMaxLines;
  final List<String> supportedLocales;
  final ThemeMode? forcedThemeMode;
  final String welcomeMessage;

  @override
  List<Object?> get props => [
        welcomeBannerEnabled,
        markdownMaxLines,
        supportedLocales,
        forcedThemeMode,
        welcomeMessage,
      ];

  RemoteConfigFeatureFlags copyWith({
    bool? welcomeBannerEnabled,
    int? markdownMaxLines,
    List<String>? supportedLocales,
    ThemeMode? forcedThemeMode,
    String? welcomeMessage,
  }) {
    return RemoteConfigFeatureFlags(
      welcomeBannerEnabled: welcomeBannerEnabled ?? this.welcomeBannerEnabled,
      markdownMaxLines: markdownMaxLines ?? this.markdownMaxLines,
      supportedLocales: supportedLocales ?? this.supportedLocales,
      forcedThemeMode: forcedThemeMode ?? this.forcedThemeMode,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
    );
  }
}
