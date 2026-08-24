import 'package:flutter/material.dart';

/// Paleta de colores de un tema, disponible vía `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onSurfaceVariant,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.focusGlow,
    required this.error,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onSurfaceVariant;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color focusGlow;
  final Color error;

  /// Tema por defecto (Nocturne): violeta/cian sobre azul profundo, basado en
  /// el prototipo `Kylora_IPTV_Prototype`.
  static const AppColors nocturne = AppColors(
    primary: Color(0xFF6C5CE7),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF3D2E7C),
    onSurfaceVariant: Color(0xFF9A9EA8),
    secondary: Color(0xFF00CEC9),
    background: Color(0xFF0F1117),
    surface: Color(0xFF1A1D27),
    onSurface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFF242837),
    focusGlow: Color(0xFF74B9FF),
    error: Color(0xFFFF6B6B),
  );

  /// Temas "expressive" de Material 3, basado en
  /// `Kylora_IPTV_Prototype_Material3`.
  static const AppColors expressive = AppColors(
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xFF38256B),
    primaryContainer: Color(0xFF4F378B),
    onSurfaceVariant: Color(0xFFC9C0CA),
    secondary: Color(0xFFC8C0D0),
    background: Color(0xFF0E0E13),
    surface: Color(0xFF17171E),
    onSurface: Color(0xFFE8E0EA),
    surfaceVariant: Color(0xFF292832),
    focusGlow: Color(0xFFE7D9FF),
    error: Color(0xFFFFB4AB),
  );

  /// Tema "Pacotis": teal/coral sobre pizarra teal, basado en
  /// `Kylora_Redesign_03_Aurora` (solo paleta; se mantiene la navegación actual).
  static const AppColors pacotis = AppColors(
    primary: Color(0xFF63E6D3),
    onPrimary: Color(0xFF04211F),
    primaryContainer: Color(0xFF18343D),
    onSurfaceVariant: Color(0xFF9EB3B7),
    secondary: Color(0xFFFF9D86),
    background: Color(0xFF071318),
    surface: Color(0xFF0D1D24),
    onSurface: Color(0xFFF3F7F6),
    surfaceVariant: Color(0xFF122831),
    focusGlow: Color(0xFFB1FFF1),
    error: Color(0xFFFF7D6B),
  );

  /// Tema "Canvas": claro editorial sobre papel, basado en
  /// `Kylora_Theme_04_Canvas`.
  static const AppColors canvas = AppColors(
    primary: Color(0xFF3157E8),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCE2FB),
    onSurfaceVariant: Color(0xFF647083),
    secondary: Color(0xFFF47D43),
    background: Color(0xFFF4F0E8),
    surface: Color(0xFFFFFDF8),
    onSurface: Color(0xFF10233F),
    surfaceVariant: Color(0xFFEBE5DA),
    focusGlow: Color(0xFF3157E8),
    error: Color(0xFFD35C4D),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onSurfaceVariant,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? onSurface,
    Color? surfaceVariant,
    Color? focusGlow,
    Color? error,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      focusGlow: focusGlow ?? this.focusGlow,
      error: error ?? this.error,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      focusGlow: Color.lerp(focusGlow, other.focusGlow, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

/// Acceso a la paleta del tema activo.
extension AppColorsX on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.nocturne;
}

/// Temas de Kylora. Cada tema construye su `ThemeData` con su propia
/// paleta (`AppColors`) registrada como `ThemeExtension`.
abstract final class AppTheme {
  static const double _radiusCard = 14;

  static ThemeData _base({
    required AppColors palette,
    required Brightness brightness,
    required double cardRadius,
    required InputDecorationTheme inputDecoration,
  }) {
    final ColorScheme scheme = brightness == Brightness.dark
        ? ColorScheme.dark(
            primary: palette.primary,
            onPrimary: palette.onPrimary,
            primaryContainer: palette.primaryContainer,
            secondary: palette.secondary,
            surface: palette.surface,
            onSurface: palette.onSurface,
            onSurfaceVariant: palette.onSurfaceVariant,
            surfaceContainerHighest: palette.surfaceVariant,
            error: palette.error,
          )
        : ColorScheme.light(
            primary: palette.primary,
            onPrimary: palette.onPrimary,
            primaryContainer: palette.primaryContainer,
            secondary: palette.secondary,
            surface: palette.surface,
            onSurface: palette.onSurface,
            onSurfaceVariant: palette.onSurfaceVariant,
            surfaceContainerHighest: palette.surfaceVariant,
            error: palette.error,
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: palette.onSurface,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      dividerTheme: DividerThemeData(color: palette.surfaceVariant),
      focusColor: palette.focusGlow.withValues(alpha: 0.35),
      hoverColor: palette.focusGlow.withValues(alpha: 0.15),
      splashColor: palette.primary.withValues(alpha: 0.25),
      highlightColor: palette.focusGlow.withValues(alpha: 0.12),
      inputDecorationTheme: inputDecoration,
      extensions: <ThemeExtension<dynamic>>[palette],
    );
  }

  /// Nocturne: oscuro azul profundo, acentos violeta y cian.
  static ThemeData get nocturne {
    return _base(
      palette: AppColors.nocturne,
      brightness: Brightness.dark,
      cardRadius: _radiusCard,
      inputDecoration: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF0B0F18),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
    );
  }

  /// Expressive: Material 3 "expressive" con radios grandes.
  static ThemeData get expressive {
    return _base(
      palette: AppColors.expressive,
      brightness: Brightness.dark,
      cardRadius: 22,
      inputDecoration: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF101016),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(17)),
        ),
      ),
    );
  }

  /// Pacotis: teal/coral sobre pizarra teal.
  static ThemeData get pacotis {
    return _base(
      palette: AppColors.pacotis,
      brightness: Brightness.dark,
      cardRadius: 16,
      inputDecoration: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF08151A),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
    );
  }

  /// Canvas: claro editorial sobre papel.
  static ThemeData get canvas {
    return _base(
      palette: AppColors.canvas,
      brightness: Brightness.light,
      cardRadius: 17,
      inputDecoration: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF4F0E8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}

/// Registro de temas por id. `dark` y `light` son alias de compatibilidad
/// (persistencia previa al Hito 10).
abstract final class AppThemes {
  static const String nocturne = 'nocturne';
  static const String expressive = 'expressive';
  static const String pacotis = 'pacotis';
  static const String canvas = 'canvas';

  static final Map<String, ThemeData> all = <String, ThemeData>{
    nocturne: AppTheme.nocturne,
    expressive: AppTheme.expressive,
    pacotis: AppTheme.pacotis,
    canvas: AppTheme.canvas,
  };

  /// Entradas ordenadas para la UI de Ajustes: `(id, ThemeData)`.
  static List<MapEntry<String, ThemeData>> get entries =>
      all.entries.toList(growable: false);

  /// Resuelve el tema por id. Acepta los alias históricos `dark`, `light` y
  /// `aurora` (nombre previo de Pacotis).
  static ThemeData byId(String? id) {
    return switch (id) {
      nocturne => AppTheme.nocturne,
      expressive => AppTheme.expressive,
      pacotis || 'aurora' => AppTheme.pacotis,
      canvas || 'light' => AppTheme.canvas,
      'dark' => AppTheme.nocturne,
      _ => AppTheme.nocturne,
    };
  }
}