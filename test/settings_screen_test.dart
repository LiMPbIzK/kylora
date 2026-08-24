import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/app.dart';
import 'package:kylora/core/media/playback_controller.dart';
import 'package:kylora/data/datasources/local/settings_store.dart';
import 'package:kylora/domain/entities/category.dart';
import 'package:kylora/domain/entities/channel.dart';
import 'package:kylora/domain/entities/content_type.dart' as domain;
import 'package:kylora/domain/entities/epg.dart';
import 'package:kylora/domain/entities/episode.dart';
import 'package:kylora/domain/entities/favorite_item.dart';
import 'package:kylora/domain/entities/history_item.dart';
import 'package:kylora/domain/entities/iptv_auth_config.dart';
import 'package:kylora/domain/entities/iptv_source_type.dart';
import 'package:kylora/domain/entities/movie.dart';
import 'package:kylora/domain/entities/series.dart';
import 'package:kylora/domain/entities/series_info.dart';
import 'package:kylora/domain/entities/user_account.dart';
import 'package:kylora/domain/repositories/iptv_repository.dart';
import 'package:kylora/presentation/blocs/auth/auth_bloc.dart';
import 'package:kylora/presentation/blocs/auth/auth_event.dart';
import 'package:kylora/presentation/blocs/epg/epg_bloc.dart';
import 'package:kylora/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:kylora/presentation/blocs/history/history_bloc.dart';
import 'package:kylora/presentation/blocs/live/live_bloc.dart';
import 'package:kylora/presentation/blocs/series/series_bloc.dart';
import 'package:kylora/presentation/blocs/settings/settings_bloc.dart';
import 'package:kylora/presentation/blocs/settings/settings_event.dart';
import 'package:kylora/presentation/blocs/vod/vod_bloc.dart';
import 'package:kylora/presentation/screens/auth/login_screen.dart';
import 'package:kylora/presentation/screens/settings/settings_screen.dart';

class _MemSettingsStore implements AppSettingsStorage {
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

class _FakeRepo implements IptvRepository {
  _FakeRepo({this.storedAccount});

  UserAccount? storedAccount;
  int refreshCount = 0;
  int clearCacheCount = 0;
  bool failRefresh = false;

  @override
  Future<UserAccount> login(IptvAuthConfig config) async =>
      throw UnimplementedError();

  @override
  Future<UserAccount?> restoreSession() async => storedAccount;

  @override
  Future<void> logout() async {
    storedAccount = null;
  }

  @override
  Future<List<Category>> fetchLiveCategories() async => const <Category>[];

  @override
  Future<List<Channel>> fetchLiveChannels({int? categoryId}) async =>
      const <Channel>[];

  @override
  Future<String> buildStreamUrl(Channel channel) async => '';

  @override
  Future<List<Category>> fetchVodCategories() async => const <Category>[];

  @override
  Future<List<Movie>> fetchVodStreams({int? categoryId}) async =>
      const <Movie>[];

  @override
  Future<String> buildVodStreamUrl(Movie movie) async => '';

  @override
  Future<List<Category>> fetchSeriesCategories() async => const <Category>[];

  @override
  Future<List<Series>> fetchSeries({int? categoryId}) async =>
      const <Series>[];

  @override
  Future<SeriesInfo> fetchSeriesInfo(int seriesId) async =>
      throw UnimplementedError();

  @override
  Future<String> buildEpisodeStreamUrl(Episode episode) async => '';

  @override
  Future<List<EpgEntry>> fetchShortEpg(int streamId) async => <EpgEntry>[];

  @override
  Future<List<EpgEntry>> fetchFullEpg(int streamId) async => <EpgEntry>[];

  @override
  Future<void> addToFavorite(FavoriteItem item) async {}

  @override
  Future<void> removeFromFavorite(int contentId, domain.ContentType type) async {}

  @override
  Future<bool> isFavorite(int contentId, domain.ContentType type) async =>
      false;

  @override
  Future<List<FavoriteItem>> getFavorites() async => const <FavoriteItem>[];

  @override
  Future<void> addToHistory(HistoryItem item) async {}

  @override
  Future<List<HistoryItem>> getHistory() async => const <HistoryItem>[];

  @override
  Future<void> clearHistory() async {}

  @override
  Future<void> refreshCatalog() async {
    if (failRefresh) {
      throw Exception('network');
    }
    refreshCount++;
  }

  @override
  Future<void> clearCatalogCache() async {
    clearCacheCount++;
  }
}

void main() {
  Future<_FakeRepo> pumpSettings(
    WidgetTester tester, {
    required UserAccount account,
    _MemSettingsStore? store,
  }) async {
    final _FakeRepo repo = _FakeRepo(storedAccount: account);
    final AuthBloc authBloc = AuthBloc(repo)..add(const AuthStarted());
    final _MemSettingsStore settingsStore = store ?? _MemSettingsStore();
    final SettingsBloc settingsBloc = SettingsBloc(settingsStore)
      ..add(const SettingsStarted());
    await tester.pumpWidget(
      KyloraApp(
        authBloc: authBloc,
        liveBloc: LiveBloc(repo),
        vodBloc: VodBloc(repo),
        seriesBloc: SeriesBloc(repo),
        epgBloc: EpgBloc(repo),
        favoritesBloc: FavoritesBloc(repo),
        historyBloc: HistoryBloc(repo),
        settingsBloc: settingsBloc,
        repository: repo,
        playbackController: PlaybackController(),
      ),
    );
    await tester.pumpAndSettle();
    if (find.byType(SettingsScreen).evaluate().isEmpty) {
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
    }
    return repo;
  }

  /// Scrollable del ListView de ajustes (evita los Scrollable subyacentes).
  Finder settingsScrollable() => find.descendant(
    of: find.byType(SettingsScreen),
    matching: find.byType(Scrollable),
  );

  testWidgets('Ajustes muestra los datos de cuenta Xtream y cierra sesión', (
    WidgetTester tester,
  ) async {
    await pumpSettings(
      tester,
      account: const UserAccount(
        serverUrl: 'http://server:8080',
        username: 'user',
        password: 'pass',
        status: 'Active',
        maxConnections: 2,
        activeConnections: 1,
      ),
    );

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('http://server:8080'), findsOneWidget);
    expect(find.text('user'), findsOneWidget);
    expect(find.text('Account status'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Ajustes muestra datos M3U', (WidgetTester tester) async {
    await pumpSettings(
      tester,
      account: const UserAccount(
        serverUrl: 'http://server:8080/playlist.m3u',
        username: 'Mi Lista',
        password: '',
        status: 'Active',
        sourceType: IptvSourceType.m3u,
        xmltvUrl: 'http://server:8080/epg.xml',
      ),
    );

    expect(find.text('M3U/XMLTV'), findsOneWidget);
    expect(find.text('http://server:8080/playlist.m3u'), findsNothing);
  });

  testWidgets('Actualizar catálogo refresca el repositorio', (
    WidgetTester tester,
  ) async {
    final _FakeRepo repo = await pumpSettings(
      tester,
      account: const UserAccount(
        serverUrl: 'http://server:8080',
        username: 'user',
        password: 'pass',
        status: 'Active',
      ),
    );

    await tester.tap(find.text('Refresh catalog'));
    await tester.pumpAndSettle();

    expect(repo.refreshCount, 1);
    expect(find.text('Catalog updated successfully'), findsOneWidget);
  });

  testWidgets('Actualizar catálogo con fallo muestra error', (
    WidgetTester tester,
  ) async {
    final _FakeRepo repo = await pumpSettings(
      tester,
      account: const UserAccount(
        serverUrl: 'http://server:8080',
        username: 'user',
        password: 'pass',
        status: 'Active',
      ),
    );
    repo.failRefresh = true;

    await tester.tap(find.text('Refresh catalog'));
    await tester.pumpAndSettle();

    expect(find.text('Could not update the catalog. Check your connection.'),
        findsOneWidget);
  });

  testWidgets('Borrar caché confirma y limpia el repositorio', (
    WidgetTester tester,
  ) async {
    final _FakeRepo repo = await pumpSettings(
      tester,
      account: const UserAccount(
        serverUrl: 'http://server:8080',
        username: 'user',
        password: 'pass',
        status: 'Active',
      ),
    );

await tester.ensureVisible(find.text('Clear cache'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear cache'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear cache'));
    await tester.pumpAndSettle();

    expect(repo.clearCacheCount, 1);
  });

  testWidgets('Cambiar idioma dispara SettingsLocaleChanged', (
    WidgetTester tester,
  ) async {
    final _MemSettingsStore store = _MemSettingsStore();
    await pumpSettings(
      tester,
      account: const UserAccount(
        serverUrl: 'http://server:8080',
        username: 'user',
        password: 'pass',
        status: 'Active',
      ),
      store: store,
    );

await tester.drag(settingsScrollable(), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(
        of: find.text('Spanish'),
        matching: find.byType(RadioListTile<String?>),
      ),
    );
    await tester.pumpAndSettle();

    expect(store.values['locale'], 'es');
  });

  testWidgets('Cambiar tema dispara SettingsThemeChanged', (
    WidgetTester tester,
  ) async {
    final _MemSettingsStore store = _MemSettingsStore();
    await pumpSettings(
      tester,
      account: const UserAccount(
        serverUrl: 'http://server:8080',
        username: 'user',
        password: 'pass',
        status: 'Active',
      ),
      store: store,
    );

await tester.drag(settingsScrollable(), const Offset(0, -1400));
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(
        of: find.text('Canvas'),
        matching: find.byType(RadioListTile<String>),
      ),
    );
    await tester.pumpAndSettle();

    expect(store.values['theme_id'], 'canvas');
  });
}
