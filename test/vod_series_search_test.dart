import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/domain/entities/category.dart';
import 'package:kylora/domain/entities/channel.dart';
import 'package:kylora/domain/entities/epg.dart';
import 'package:kylora/domain/entities/episode.dart';
import 'package:kylora/domain/entities/movie.dart';
import 'package:kylora/domain/entities/series.dart';
import 'package:kylora/domain/entities/series_info.dart';
import 'package:kylora/domain/entities/user_account.dart';
import 'package:kylora/domain/repositories/iptv_repository.dart';
import 'package:kylora/presentation/blocs/vod/vod_bloc.dart';
import 'package:kylora/presentation/blocs/vod/vod_event.dart';
import 'package:kylora/presentation/blocs/vod/vod_state.dart';
import 'package:kylora/presentation/blocs/series/series_bloc.dart';
import 'package:kylora/presentation/blocs/series/series_event.dart';
import 'package:kylora/presentation/blocs/series/series_state.dart';

class _FakeRepo implements IptvRepository {
  @override
  Future<List<Category>> fetchVodCategories() async => const <Category>[
    Category(id: 1, name: 'Acción'),
  ];

  @override
  Future<List<Movie>> fetchVodStreams({int? categoryId}) async =>
      const <Movie>[
        Movie(id: 1, name: 'Matrix', categoryId: 1),
        Movie(id: 2, name: 'Titanic', categoryId: 1),
        Movie(id: 3, name: 'Inception', categoryId: 1),
      ];

  @override
  Future<List<Category>> fetchSeriesCategories() async => const <Category>[
    Category(id: 1, name: 'Drama'),
  ];

  @override
  Future<List<Series>> fetchSeries({int? categoryId}) async =>
      const <Series>[
        Series(id: 1, name: 'Breaking Bad', categoryId: 1),
        Series(id: 2, name: 'Better Call Saul', categoryId: 1),
        Series(id: 3, name: 'The Office', categoryId: 1),
      ];

  @override
  Future<UserAccount> login({
    required String serverUrl,
    required String username,
    required String password,
  }) async =>
      throw UnimplementedError();

  @override
  Future<UserAccount?> restoreSession() async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<List<Category>> fetchLiveCategories() async => const <Category>[];

  @override
  Future<List<Channel>> fetchLiveChannels({int? categoryId}) async =>
      const <Channel>[];

  @override
  Future<String> buildStreamUrl(Channel channel) async =>
      throw UnimplementedError();

  @override
  Future<String> buildVodStreamUrl(Movie movie) async =>
      throw UnimplementedError();

  @override
  Future<SeriesInfo> fetchSeriesInfo(int seriesId) async =>
      throw UnimplementedError();

  @override
  Future<String> buildEpisodeStreamUrl(Episode episode) async =>
      throw UnimplementedError();

  @override
  Future<List<EpgEntry>> fetchShortEpg(int streamId) async =>
      throw UnimplementedError();

  @override
  Future<List<EpgEntry>> fetchFullEpg(int streamId) async =>
      throw UnimplementedError();
}

/// Procesa los microtasks del bloc hasta que el estado sea un `VodLoaded`
/// cuya lista de películas tenga la longitud esperada.
Future<VodLoaded> vodLoaded(VodBloc bloc, {int? count}) async {
  while (true) {
    if (bloc.state is VodLoaded) {
      final VodLoaded s = bloc.state as VodLoaded;
      if (count == null || s.movies.length == count) return s;
    }
    await Future<void>.delayed(const Duration(milliseconds: 4));
  }
}

/// Procesa los microtasks del bloc hasta que el estado sea un `SeriesLoaded`
/// cuya lista de series tenga la longitud esperada.
Future<SeriesLoaded> seriesLoaded(SeriesBloc bloc, {int? count}) async {
  while (true) {
    if (bloc.state is SeriesLoaded) {
      final SeriesLoaded s = bloc.state as SeriesLoaded;
      if (count == null || s.seriesList.length == count) return s;
    }
    await Future<void>.delayed(const Duration(milliseconds: 4));
  }
}

void main() {
  test('VodBloc filtra películas por búsqueda en memoria', () async {
    final VodBloc bloc = VodBloc(_FakeRepo());
    bloc.add(const VodStarted());
    VodLoaded loaded = await vodLoaded(bloc, count: 3);
    expect(loaded.movies, hasLength(3));

    bloc.add(const VodSearchChanged('tri'));
    loaded = await vodLoaded(bloc, count: 1);
    expect(loaded.movies.first.name, 'Matrix');

    bloc.add(const VodSearchChanged(''));
    loaded = await vodLoaded(bloc, count: 3);
    expect(loaded.movies, hasLength(3));

    await bloc.close();
  });

  test('SeriesBloc filtra series por búsqueda en memoria', () async {
    final SeriesBloc bloc = SeriesBloc(_FakeRepo());
    bloc.add(const SeriesStarted());
    SeriesLoaded loaded = await seriesLoaded(bloc, count: 3);
    expect(loaded.seriesList, hasLength(3));

    bloc.add(const SeriesSearchChanged('call'));
    loaded = await seriesLoaded(bloc, count: 1);
    expect(loaded.seriesList.first.name, 'Better Call Saul');

    await bloc.close();
  });
}
