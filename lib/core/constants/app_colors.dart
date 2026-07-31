import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF60A5FA);
  static const Color neonBlue = Color(0xFF38BDF8);

  static const Color primary = primaryBlue;
  static const Color primaryLight = primaryBlueLight;
  static const Color primaryDark = primaryBlueDark;

  static const Color accent = Color(0xFF818CF8);
  static const Color accentAlt = Color(0xFF6366F1);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const Color background = Color(0xFFF0F4FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE2E8F0);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1E293B);
  static const Color onSurfaceVariant = Color(0xFF64748B);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color coin = Color(0xFFFFD93D);

  static const Color trueBlack = Color(0xFF0A1628);
  static const Color darkBackground = Color(0xFF0A1628);
  static const Color darkSurface = Color(0xFF111D32);
  static const Color darkCard = Color(0xFF1A2942);
  static const Color darkNavBar = Color(0xFF111D32);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A5F), Color(0xFF0A1628)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A1628), Color(0xFF111D32), Color(0xFF1A2942)],
  );

  static const LinearGradient shieldGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  );

  static const List<Color> categoryPalette = [
    Color(0xFF22C55E),
    Color(0xFFF97316),
    Color(0xFFEAB308),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
    Color(0xFFF97316),
    Color(0xFF3B82F6),
    Color(0xFFFBBF24),
  ];
}
