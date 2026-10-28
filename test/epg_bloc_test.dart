import 'package:flutter_test/flutter_test.dart';
import 'package:kylora/domain/entities/epg.dart';
import 'package:kylora/domain/entities/favorite_channel_group.dart';
import 'package:kylora/domain/entities/favorite_item.dart';
import 'package:kylora/domain/entities/history_item.dart';
import 'package:kylora/domain/entities/iptv_auth_config.dart';
import 'package:kylora/domain/entities/user_account.dart';
import 'package:kylora/domain/repositories/iptv_repository.dart';
import 'package:kylora/domain/entities/category.dart';
import 'package:kylora/domain/entities/channel.dart';
import 'package:kylora/domain/entities/content_type.dart' as domain;
import 'package:kylora/domain/entities/episode.dart';
import 'package:kylora/domain/entities/movie.dart';
import 'package:kylora/domain/entities/series.dart';
import 'package:kylora/domain/entities/series_info.dart';
import 'package:kylora/presentation/blocs/epg/epg_bloc.dart';
import 'package:kylora/presentation/blocs/epg/epg_event.dart';
import 'package:kylora/presentation/blocs/epg/epg_state.dart';

void main() {
  group('EpgBloc hasGuide', () {
    test('lista vacía → hasGuide false', () async {
      final _FakeRepo repo = _FakeRepo()..short = <EpgEntry>[];
      final EpgBloc bloc = EpgBloc(repo);

      bloc.add(const EpgNowNextRequested(1));
      await Future<void>.delayed(Duration.zero);

      final EpgState state = bloc.state;
      expect(state, isA<EpgNowNextLoaded>());
      final EpgNowNextLoaded loaded = state as EpgNowNextLoaded;
      expect(loaded.hasGuide, isFalse);
      expect(loaded.now, isNull);
      await bloc.close();
    });

    test('con entradas → hasGuide true', () async {
      final DateTime now = DateTime.now();
      final _FakeRepo repo = _FakeRepo()
        ..short = <EpgEntry>[
          EpgEntry(
            title: 'Informativos',
            start: now.subtract(const Duration(minutes: 30)),
            end: now.add(const Duration(minutes: 30)),
          ),
          EpgEntry(
            title: 'Película',
            start: now.add(const Duration(minutes: 30)),
            end: now.add(const Duration(hours: 2)),
          ),
        ];
      final EpgBloc bloc = EpgBloc(repo);

      bloc.add(const EpgNowNextRequested(1));
      await Future<void>.delayed(Duration.zero);

      final EpgState state = bloc.state;
      expect(state, isA<EpgNowNextLoaded>());
      final EpgNowNextLoaded loaded = state as EpgNowNextLoaded;
      expect(loaded.hasGuide, isTrue);
      expect(loaded.now!.title, 'Informativos');
      expect(loaded.next!.title, 'Película');
      await bloc.close();
    });
  });
}

class _FakeRepo implements IptvRepository {
  List<EpgEntry> short = <EpgEntry>[];

  @override
  Future<UserAccount> login(
    IptvAuthConfig config, {
    bool activate = true,
  }) async => throw UnimplementedError();

  @override
  Future<UserAccount?> restoreSession() async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<List<Category>> fetchLiveCategories() async => <Category>[];

  @override
  Future<List<Channel>> fetchLiveChannels({int? categoryId}) async =>
      <Channel>[];

  @override
  Future<String> buildStreamUrl(Channel channel) async => '';

  @override
  Future<String?> buildCatchupUrl({
    required int streamId,
    required bool hasArchive,
    int? archiveDurationDays,
    required EpgEntry program,
  }) async => null;

  @override
  Future<List<Category>> fetchVodCategories() async => <Category>[];

  @override
  Future<List<Movie>> fetchVodStreams({int? categoryId}) async => <Movie>[];

  @override
  Future<String> buildVodStreamUrl(Movie movie) async => '';

  @override
  Future<List<Category>> fetchSeriesCategories() async => <Category>[];

  @override
  Future<List<Series>> fetchSeries({int? categoryId}) async => <Series>[];

  @override
  Future<SeriesInfo> fetchSeriesInfo(int seriesId) async =>
      throw UnimplementedError();

  @override
  Future<String> buildEpisodeStreamUrl(Episode episode) async => '';

  @override
  Future<List<EpgEntry>> fetchShortEpg(int streamId) async => short;

  @override
  Future<List<EpgEntry>> fetchFullEpg(int streamId) async => short;

  @override
  Future<void> addToFavorite(FavoriteItem item) async {}

  @override
  Future<void> addFavoriteGroup(FavoriteChannelGroup group) async {}

  @override
  Future<void> removeFavoriteGroup(int categoryId) async {}

  @override
  Future<List<FavoriteChannelGroup>> getFavoriteGroups() async =>
      const <FavoriteChannelGroup>[];

  @override
  Future<bool> isFavoriteGroup(int categoryId) async => false;

  @override
  Future<void> removeFromFavorite(
    int contentId,
    domain.ContentType type,
  ) async {}

  @override
  Future<bool> isFavorite(int contentId, domain.ContentType type) async =>
      false;

  @override
  Future<List<FavoriteItem>> getFavorites() async => <FavoriteItem>[];

  @override
  Future<void> addToHistory(HistoryItem item) async {}

  @override
  Future<List<HistoryItem>> getHistory() async => <HistoryItem>[];

  @override
  Future<void> clearHistory() async {}

  @override
  Future<void> removeFromHistory(
    int contentId,
    domain.ContentType type,
  ) async {}

  @override
  Future<void> refreshCatalog() async {}

  @override
  Future<void> clearCatalogCache() async {}
}
