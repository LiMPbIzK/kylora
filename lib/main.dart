import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/media/playback_controller.dart';
import 'data/datasources/local/app_database.dart';
import 'data/datasources/local/auth_store.dart';
import 'data/datasources/local/live_cache_store.dart';
import 'data/datasources/remote/m3u_downloader.dart';
import 'data/datasources/remote/xtream_api_client.dart';
import 'data/repositories/m3u_repository.dart';
import 'data/repositories/xtream_repository.dart';
import 'domain/entities/iptv_source_type.dart';
import 'domain/repositories/iptv_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/epg/epg_bloc.dart';
import 'presentation/blocs/favorites/favorites_bloc.dart';
import 'presentation/blocs/history/history_bloc.dart';
import 'presentation/blocs/live/live_bloc.dart';
import 'presentation/blocs/series/series_bloc.dart';
import 'presentation/blocs/vod/vod_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  Bloc.observer = const _KyloraBlocObserver();

  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: AppTimeouts.connect,
      receiveTimeout: AppTimeouts.receive,
      headers: <String, dynamic>{'User-Agent': AppConstants.userAgent},
    ),
  );

  final AppDatabase database = AppDatabase();
  final AuthStore authStore = AuthStore();
  final IptvRepository repository = await _buildRepository(dio, authStore, database);

  final AuthBloc authBloc = AuthBloc(repository)..add(const AuthStarted());
  final LiveBloc liveBloc = LiveBloc(repository);
  final VodBloc vodBloc = VodBloc(repository);
  final SeriesBloc seriesBloc = SeriesBloc(repository);
  final EpgBloc epgBloc = EpgBloc(repository);
  final FavoritesBloc favoritesBloc = FavoritesBloc(repository);
  final HistoryBloc historyBloc = HistoryBloc(repository);

  runApp(
    KyloraApp(
      authBloc: authBloc,
      liveBloc: liveBloc,
      vodBloc: vodBloc,
      seriesBloc: seriesBloc,
      epgBloc: epgBloc,
      favoritesBloc: favoritesBloc,
      historyBloc: historyBloc,
      repository: repository,
      playbackController: PlaybackController(),
    ),
  );
}

/// Construye el repositorio adecuado según la fuente de la sesión guardada.
Future<IptvRepository> _buildRepository(
  Dio dio,
  AuthStore authStore,
  AppDatabase database,
) async {
  final StoredCredentials? stored = await authStore.read();
  final LiveCacheStore cache = LiveCacheStore(database);
  if (stored?.sourceType == IptvSourceType.m3u) {
    return M3uRepository(M3uDownloader(dio), authStore, database, cache: cache);
  }
  return XtreamRepository(XtreamApiClient(dio), authStore, database, cache: cache);
}

/// Observador global de Bloc para trazabilidad de eventos en desarrollo.
class _KyloraBlocObserver extends BlocObserver {
  const _KyloraBlocObserver();

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint('${bloc.runtimeType}: ${transition.event.runtimeType}');
    }
  }
}