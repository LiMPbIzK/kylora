import 'package:flutter/material.dart';

/// Colores centrales de la aplicación.
abstract final class AppColors {
  static const Color primary = Color(0xFF6C5CE7);
  static const Color onPrimary = Colors.white;
  static const Color secondary = Color(0xFF00CEC9);
  static const Color background = Color(0xFF0F1117);
  static const Color surface = Color(0xFF1A1D27);
  static const Color onSurface = Colors.white;
  static const Color surfaceVariant = Color(0xFF242837);
  static const Color focusGlow = Color(0xFF74B9FF);
  static const Color error = Color(0xFFFF6B6B);
}

/// Tema oscuro base. Los estilos de foco para TV se ampliarán en M8.
abstract final class AppTheme {
  static ThemeData get dark {
    final ColorScheme scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceVariant,
      ),
      focusColor: AppColors.focusGlow,
    );
  }
}
