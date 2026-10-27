import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show Locale;

/// Estado de las preferencias de la aplicación.
sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargando preferencias guardadas al arrancar.
final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Preferencias cargadas y activas.
final class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.locale,
    required this.themeId,
    required this.clock24h,
  });

  /// Idioma seleccionado (`null` = seguir el idioma del sistema).
  final Locale? locale;

  /// Id del tema activo (ver `AppThemes`).
  final String themeId;

  /// `true` = reloj en formato 24 h; `false` = 12 h (AM/PM).
  final bool clock24h;

  @override
  List<Object?> get props => <Object?>[locale, themeId, clock24h];
}
