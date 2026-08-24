import 'package:flutter/material.dart';

/// Colores centrales de la aplicación.
abstract final class AppColors {
  static const Color primary = Color(0xFF6C5CE7);
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFF3D2E7C);
  static const Color onSurfaceVariant = Color(0xFF9A9EA8);
  static const Color secondary = Color(0xFF00CEC9);
  static const Color background = Color(0xFF0F1117);
  static const Color surface = Color(0xFF1A1D27);
  static const Color onSurface = Colors.white;
  static const Color surfaceVariant = Color(0xFF242837);
  static const Color focusGlow = Color(0xFF74B9FF);
  static const Color error = Color(0xFFFF6B6B);
}

/// Tema oscuro base. Los estilos de foco para TV se ampliaron en M8.
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
      dividerTheme: const DividerThemeData(color: AppColors.surfaceVariant),
      focusColor: AppColors.focusGlow.withValues(alpha: 0.35),
      hoverColor: AppColors.focusGlow.withValues(alpha: 0.15),
      splashColor: AppColors.primary.withValues(alpha: 0.25),
      highlightColor: AppColors.focusGlow.withValues(alpha: 0.12),
    );
  }

  /// Tema claro básico (registrado en `AppThemes`; se pulirá en posteriores
  /// revisiones de diseño).
  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      surface: const Color(0xFFF5F5F8),
      onSurface: const Color(0xFF1A1D27),
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFFBFBFF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F5F8),
        foregroundColor: Color(0xFF1A1D27),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE2E2E8)),
      focusColor: AppColors.focusGlow.withValues(alpha: 0.35),
      hoverColor: AppColors.focusGlow.withValues(alpha: 0.15),
      splashColor: AppColors.primary.withValues(alpha: 0.25),
      highlightColor: AppColors.focusGlow.withValues(alpha: 0.12),
    );
  }
}

/// Registro de temas por id: `dark` (por defecto) y `light`.
/// Los diseños personalizados se añadirán como nuevas entradas.
abstract final class AppThemes {
  static const String dark = 'dark';
  static const String light = 'light';

  static final Map<String, ThemeData> all = <String, ThemeData>{
    dark: AppTheme.dark,
    light: AppTheme.light,
  };

  /// Resuelve el tema por id, con el oscuro como respaldo.
  static ThemeData byId(String? id) => all[id] ?? AppTheme.dark;
}
