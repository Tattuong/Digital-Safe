import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/app_ui.dart';

class AppThemePreset {
  final String id;
  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color darkBackground;
  final Color darkSurface;
  final LinearGradient headerGradient;
  final LinearGradient balanceGradient;

  const AppThemePreset({
    required this.id,
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.darkBackground,
    required this.darkSurface,
    required this.headerGradient,
    required this.balanceGradient,
  });

  ThemeData lightTheme() => _buildTheme(
        brightness: Brightness.light,
        scaffold: background,
        surfaceColor: surface,
        onSurface: AppColors.onSurface,
      );

  ThemeData darkTheme() => _buildTheme(
        brightness: Brightness.dark,
        scaffold: darkBackground,
        surfaceColor: darkSurface,
        onSurface: const Color(0xFFF1F5F9),
      );

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffold,
    required Color surfaceColor,
    required Color onSurface,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryLight,
              secondary: primary,
              tertiary: AppColors.accent,
              surface: surfaceColor,
              onSurface: onSurface,
              onPrimary: AppColors.onPrimary,
            )
          : ColorScheme.light(
              primary: primary,
              secondary: primaryLight,
              tertiary: AppColors.accent,
              surface: surfaceColor,
              onPrimary: AppColors.onPrimary,
              onSurface: onSurface,
            ),
      textTheme: AppTypography.textTheme(brightness),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.titleLarge(color: onSurface),
        iconTheme: IconThemeData(color: onSurface),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? primaryLight : primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurface : AppColors.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? primaryLight : primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: primary.withValues(alpha: 0.15)),
      ),
    );
  }
}

class AppThemePresets {
  AppThemePresets._();

  static const AppThemePreset defaultPreset = AppThemePreset(
    id: 'theme_default',
    primary: AppColors.primaryBlue,
    primaryLight: AppColors.neonBlue,
    background: AppColors.background,
    surface: AppColors.surface,
    darkBackground: AppColors.darkBackground,
    darkSurface: AppColors.darkCard,
    headerGradient: AppColors.headerGradient,
    balanceGradient: AppColors.heroGradient,
  );

  static const AppThemePreset ocean = AppThemePreset(
    id: 'theme_ocean',
    primary: Color(0xFF0EA5E9),
    primaryLight: Color(0xFF7DD3FC),
    background: Color(0xFFF0F9FF),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF0C1929),
    darkSurface: Color(0xFF1E3A5F),
    headerGradient: LinearGradient(colors: [Color(0xFF7DD3FC), Color(0xFF0EA5E9)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF7DD3FC), Color(0xFF0284C7)]),
  );

  static const AppThemePreset emerald = AppThemePreset(
    id: 'theme_emerald',
    primary: Color(0xFF10B981),
    primaryLight: Color(0xFF6EE7B7),
    background: Color(0xFFECFDF5),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF0F2A1A),
    darkSurface: Color(0xFF1A3D28),
    headerGradient: LinearGradient(colors: [Color(0xFF6EE7B7), Color(0xFF10B981)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)]),
  );

  static const AppThemePreset royal = AppThemePreset(
    id: 'theme_royal',
    primary: Color(0xFF6366F1),
    primaryLight: Color(0xFFA5B4FC),
    background: Color(0xFFEEF2FF),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF1E1B4B),
    darkSurface: Color(0xFF312E81),
    headerGradient: LinearGradient(colors: [Color(0xFFA5B4FC), Color(0xFF6366F1)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF818CF8), Color(0xFF4F46E5)]),
  );

  static const AppThemePreset crimson = AppThemePreset(
    id: 'theme_crimson',
    primary: Color(0xFFEF4444),
    primaryLight: Color(0xFFFCA5A5),
    background: Color(0xFFFEF2F2),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF2A0F0F),
    darkSurface: Color(0xFF3D1818),
    headerGradient: LinearGradient(colors: [Color(0xFFFCA5A5), Color(0xFFEF4444)]),
    balanceGradient: LinearGradient(colors: [Color(0xFFF87171), Color(0xFFDC2626)]),
  );

  static const Map<String, AppThemePreset> byId = {
    'theme_default': defaultPreset,
    'theme_ocean': ocean,
    'theme_emerald': emerald,
    'theme_royal': royal,
    'theme_crimson': crimson,
  };

  static AppThemePreset get(String? id) => byId[id] ?? defaultPreset;
}

class AppBackground {
  final String id;
  final LinearGradient gradient;

  const AppBackground({required this.id, required this.gradient});

  static const AppBackground defaultBg = AppBackground(
    id: 'bg_default',
    gradient: AppColors.accentGradient,
  );

  static const AppBackground vault = AppBackground(
    id: 'bg_vault',
    gradient: LinearGradient(colors: [Color(0xFF0A1628), Color(0xFF1E3A5F), Color(0xFF2563EB)]),
  );

  static const AppBackground stars = AppBackground(
    id: 'bg_stars',
    gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF312E81), Color(0xFF6366F1)]),
  );

  static const AppBackground neon = AppBackground(
    id: 'bg_neon',
    gradient: LinearGradient(colors: [Color(0xFF0A1628), Color(0xFF1D4ED8), Color(0xFF38BDF8)]),
  );

  static const AppBackground aurora = AppBackground(
    id: 'bg_aurora',
    gradient: LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6), Color(0xFFEC4899)]),
  );

  static const Map<String, AppBackground> byId = {
    'bg_default': defaultBg,
    'bg_vault': vault,
    'bg_stars': stars,
    'bg_neon': neon,
    'bg_aurora': aurora,
  };

  static AppBackground get(String? id) => byId[id] ?? defaultBg;
}

class CardStyle {
  final String id;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color accentColor;
  final bool glassEffect;

  const CardStyle({
    required this.id,
    this.borderRadius = 20,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.accentColor = AppColors.primary,
    this.glassEffect = false,
  });

  static const CardStyle defaultStyle = CardStyle(id: 'skin_default');

  static const CardStyle soft = CardStyle(
    id: 'skin_soft',
    borderRadius: 28,
    accentColor: AppColors.primaryBlueLight,
  );

  static const CardStyle glass = CardStyle(
    id: 'skin_glass',
    borderRadius: 24,
    glassEffect: true,
    accentColor: AppColors.primaryBlue,
  );

  static const CardStyle bold = CardStyle(
    id: 'skin_bold',
    borderRadius: 16,
    borderWidth: 2,
    borderColor: AppColors.primaryBlue,
    accentColor: AppColors.primaryBlueDark,
  );

  static const Map<String, CardStyle> byId = {
    'skin_default': defaultStyle,
    'skin_soft': soft,
    'skin_glass': glass,
    'skin_bold': bold,
  };

  static CardStyle get(String? id) => byId[id] ?? defaultStyle;
}
