import 'package:devhub_gpt/core/theme/app_palette.dart';
import 'package:devhub_gpt/core/theme/devhub_theme_extension.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(ColorScheme? _) {
    final base = ColorScheme.fromSeed(
      seedColor: AppPalette.accent,
      brightness: Brightness.light,
    );
    return _themeFrom(base, isDark: false);
  }

  static ThemeData darkTheme(ColorScheme? _) {
    final base = ColorScheme.fromSeed(
      seedColor: AppPalette.accent,
      brightness: Brightness.dark,
    );
    return _themeFrom(base, isDark: true);
  }

  static ThemeData _themeFrom(ColorScheme base, {required bool isDark}) {
    final scheme = base.copyWith(
      surface: AppPalette.surface,
      surfaceContainerHighest: AppPalette.surface2,
    );

    final textTheme = Typography.englishLike2021.apply(
      bodyColor: AppPalette.textPrimary,
      displayColor: AppPalette.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppPalette.background,
      textTheme: textTheme.copyWith(
        headlineSmall: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        titleMedium: const TextStyle(
          color: AppPalette.textSecondary,
          letterSpacing: .2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppPalette.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppPalette.outline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppPalette.outline,
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppPalette.textSecondary,
        textColor: AppPalette.textPrimary,
        dense: true,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppPalette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppPalette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppPalette.accent, width: 1.5),
        ),
        labelStyle: TextStyle(color: AppPalette.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: AppPalette.accent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.textPrimary,
          side: const BorderSide(color: AppPalette.outline),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppPalette.textSecondary),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppPalette.surface,
        indicatorColor: AppPalette.accent.withValues(alpha: 0.15),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppPalette.accent, width: 1),
        ),
        selectedIconTheme: const IconThemeData(color: AppPalette.accent),
        unselectedIconTheme: const IconThemeData(
          color: AppPalette.textSecondary,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: AppPalette.accent,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: AppPalette.textSecondary,
        ),
      ),
      extensions: const [
        DevHubTheme(
          glow: Color(0x3342FF00),
          graphLine: AppPalette.accent,
          graphFill: Color(0x1AA8FF60),
        ),
      ],
    );
  }
}
