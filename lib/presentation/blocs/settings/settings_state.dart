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
  const SettingsLoaded({required this.locale, required this.themeId});

  /// Idioma seleccionado (`null` = seguir el idioma del sistema).
  final Locale? locale;

  /// Id del tema activo (ver `AppThemes`).
  final String themeId;

  @override
  List<Object?> get props => <Object?>[locale, themeId];
}