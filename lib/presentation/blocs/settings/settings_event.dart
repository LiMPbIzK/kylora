import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show Locale;

/// Eventos de preferencias de la aplicación.
sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga las preferencias guardadas (locale y tema).
final class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

/// Cambia el idioma de la aplicación (`null` = sistema).
final class SettingsLocaleChanged extends SettingsEvent {
  const SettingsLocaleChanged(this.locale);

  final Locale? locale;

  @override
  List<Object?> get props => <Object?>[locale];
}

/// Cambia el tema de la aplicación por id (`dark`, `light`, ...).
final class SettingsThemeChanged extends SettingsEvent {
  const SettingsThemeChanged(this.themeId);

  final String themeId;

  @override
  List<Object?> get props => <Object?>[themeId];
}

/// Cambia el formato del reloj de la barra superior.
///
/// [clock24h] `true` = 24 horas, `false` = 12 horas (AM/PM).
final class SettingsClockFormatChanged extends SettingsEvent {
  const SettingsClockFormatChanged(this.clock24h);

  final bool clock24h;

  @override
  List<Object?> get props => <Object?>[clock24h];
}
