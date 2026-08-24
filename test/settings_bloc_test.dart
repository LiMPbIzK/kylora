import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/core/theme/app_theme.dart';
import 'package:kylora/data/datasources/local/settings_store.dart';
import 'package:kylora/presentation/blocs/settings/settings_bloc.dart';
import 'package:kylora/presentation/blocs/settings/settings_event.dart';
import 'package:kylora/presentation/blocs/settings/settings_state.dart';

/// Almacén de preferencias falso con una tabla en memoria.
class _FakeSettingsStore implements AppSettingsStorage {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }
}

void main() {
  test('SettingsBloc carga los valores por defecto sin preferencias', () async {
    final SettingsBloc bloc = SettingsBloc(_FakeSettingsStore())
      ..add(const SettingsStarted());
    await expectLater(
      bloc.stream,
      emitsInOrder(<dynamic>[
        isA<SettingsLoaded>()
            .having((s) => s.locale, 'locale', isNull)
            .having((s) => s.themeId, 'themeId', AppThemes.nocturne),
      ]),
    );
    await bloc.close();
  });

  test('SettingsBloc carga locale y tema persistidos', () async {
    final _FakeSettingsStore store = _FakeSettingsStore()
      ..values[SettingsStore.kLocale] = 'es'
      ..values[SettingsStore.kThemeId] = AppThemes.canvas;
    final SettingsBloc bloc = SettingsBloc(store)..add(const SettingsStarted());
    await expectLater(
      bloc.stream,
      emitsInOrder(<dynamic>[
        isA<SettingsLoaded>()
            .having((s) => s.locale?.languageCode, 'locale', 'es')
            .having((s) => s.themeId, 'themeId', AppThemes.canvas),
      ]),
    );
    await bloc.close();
  });

  test('SettingsLocaleChanged persiste y cambia el idioma en caliente',
      () async {
    final _FakeSettingsStore store = _FakeSettingsStore();
    final SettingsBloc bloc = SettingsBloc(store)..add(const SettingsStarted());
    await bloc.stream.first;

    bloc.add(const SettingsLocaleChanged(Locale('en')));
    await expectLater(
      bloc.stream,
      emitsInOrder(<dynamic>[
        isA<SettingsLoaded>()
            .having((s) => s.locale?.languageCode, 'locale', 'en'),
      ]),
    );
    expect(store.values[SettingsStore.kLocale], 'en');

    bloc.add(const SettingsLocaleChanged(null));
    await expectLater(
      bloc.stream,
      emitsInOrder(<dynamic>[
        isA<SettingsLoaded>().having((s) => s.locale, 'locale', isNull),
      ]),
    );
    expect(store.values.containsKey(SettingsStore.kLocale), isFalse);
    await bloc.close();
  });

  test('SettingsThemeChanged persiste y cambia el tema en caliente', () async {
    final _FakeSettingsStore store = _FakeSettingsStore();
    final SettingsBloc bloc = SettingsBloc(store)..add(const SettingsStarted());
    await bloc.stream.first;

    bloc.add(const SettingsThemeChanged(AppThemes.canvas));
    await expectLater(
      bloc.stream,
      emitsInOrder(<dynamic>[
        isA<SettingsLoaded>()
            .having((s) => s.themeId, 'themeId', AppThemes.canvas),
      ]),
    );
    expect(store.values[SettingsStore.kThemeId], AppThemes.canvas);
    await bloc.close();
  });
}