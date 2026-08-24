import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/local/settings_store.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// Bloc de preferencias de la aplicación: idioma y tema persistidos.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._store) : super(const SettingsLoading()) {
    on<SettingsStarted>(_onStarted);
    on<SettingsLocaleChanged>(_onLocaleChanged);
    on<SettingsThemeChanged>(_onThemeChanged);
  }

  final AppSettingsStorage _store;

  Future<void> _onStarted(
    SettingsStarted event,
    Emitter<SettingsState> emit,
  ) async {
    final String? localeCode = await _store.read(SettingsStore.kLocale);
    final String? themeId = await _store.read(SettingsStore.kThemeId);
    emit(
      SettingsLoaded(
        locale: localeCode == null ? null : Locale(localeCode),
        themeId: themeId ?? AppThemes.dark,
      ),
    );
  }

  Future<void> _onLocaleChanged(
    SettingsLocaleChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _store.write(
      SettingsStore.kLocale,
      event.locale?.languageCode,
    );
    emit(
      SettingsLoaded(
        locale: event.locale,
        themeId: _currentThemeId(),
      ),
    );
  }

  Future<void> _onThemeChanged(
    SettingsThemeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _store.write(SettingsStore.kThemeId, event.themeId);
    emit(SettingsLoaded(locale: _currentLocale(), themeId: event.themeId));
  }

  Locale? _currentLocale() => switch (state) {
    SettingsLoaded loaded => loaded.locale,
    _ => null,
  };

  String _currentThemeId() => switch (state) {
    SettingsLoaded loaded => loaded.themeId,
    _ => AppThemes.dark,
  };
}