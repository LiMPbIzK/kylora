import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/app.dart';
import 'package:kylora/core/media/playback_controller.dart';
import 'package:kylora/data/datasources/remote/xtream_api_client.dart';
import 'package:kylora/domain/entities/category.dart';
import 'package:kylora/domain/entities/channel.dart';
import 'package:kylora/domain/entities/epg.dart';
import 'package:kylora/domain/entities/episode.dart';
import 'package:kylora/domain/entities/movie.dart';
import 'package:kylora/domain/entities/season.dart';
import 'package:kylora/domain/entities/series.dart';
import 'package:kylora/domain/entities/series_info.dart';
import 'package:kylora/domain/entities/user_account.dart';
import 'package:kylora/domain/repositories/iptv_repository.dart';
import 'package:kylora/presentation/blocs/auth/auth_bloc.dart';
import 'package:kylora/presentation/blocs/auth/auth_event.dart';
import 'package:kylora/presentation/blocs/auth/auth_state.dart';
import 'package:kylora/presentation/blocs/epg/epg_bloc.dart';
import 'package:kylora/presentation/blocs/live/live_bloc.dart';
import 'package:kylora/presentation/blocs/series/series_bloc.dart';
import 'package:kylora/presentation/blocs/vod/vod_bloc.dart';
import 'package:kylora/presentation/screens/auth/login_screen.dart';
import 'package:kylora/presentation/screens/dashboard/home_shell_screen.dart';
import 'package:kylora/presentation/screens/live/live_screen.dart';
import 'package:kylora/presentation/screens/series/series_screen.dart';
import 'package:kylora/presentation/screens/vod/vod_screen.dart';

/// Repositorio falso con cuenta de prueba.
class _FakeRepository implements IptvRepository {
  UserAccount? storedAccount;

  @override
  Future<UserAccount> login({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    return UserAccount(
      serverUrl: serverUrl,
      username: username,
      password: password,
      status: 'Active',
    );
  }

  @override
  Future<UserAccount?> restoreSession() async => storedAccount;

  @override
  Future<void> logout() async {
    storedAccount = null;
  }

  @override
  Future<List<Category>> fetchLiveCategories() async => const <Category>[
    Category(id: 1, name: 'Deportes'),
    Category(id: 2, name: 'Noticias'),
  ];

  @override
  Future<List<Channel>> fetchLiveChannels({int? categoryId}) async {
    const List<Channel> all = <Channel>[
      Channel(
        id: 101,
        name: 'Sports 1',
        categoryId: 1,
        logo: 'http://x/logo1.png',
      ),
      Channel(
        id: 102,
        name: 'News 24',
        categoryId: 2,
        logo: 'http://x/logo2.png',
      ),
    ];
    if (categoryId == null) return all;
    return all
        .where((Channel channel) => channel.categoryId == categoryId)
        .toList();
  }

  @override
  Future<String> buildStreamUrl(Channel channel) async {
    return 'http://server:8080/live/user/pass/${channel.id}.ts';
  }

  @override
  Future<List<Category>> fetchVodCategories() async => const <Category>[
    Category(id: 1, name: 'Acción'),
    Category(id: 2, name: 'Drama'),
  ];

  @override
  Future<List<Movie>> fetchVodStreams({int? categoryId}) async {
    const List<Movie> all = <Movie>[
      Movie(
        id: 201,
        name: 'Matrix',
        categoryId: 1,
        streamIcon: 'http://x/matrix.png',
        rating: '8.7',
      ),
      Movie(
        id: 202,
        name: 'Titanic',
        categoryId: 2,
        streamIcon: 'http://x/titanic.png',
      ),
    ];
    if (categoryId == null) return all;
    return all
        .where((Movie movie) => movie.categoryId == categoryId)
        .toList();
  }

  @override
  Future<String> buildVodStreamUrl(Movie movie) async {
    return 'http://server:8080/movie/user/pass/${movie.id}.mp4';
  }

  @override
  Future<List<Category>> fetchSeriesCategories() async => const <Category>[
    Category(id: 1, name: 'Drama'),
  ];

  @override
  Future<List<Series>> fetchSeries({int? categoryId}) async {
    const List<Series> all = <Series>[
      Series(id: 301, name: 'Breaking Bad', categoryId: 1, cover: 'http://x/bb.png'),
    ];
    if (categoryId == null) return all;
    return all
        .where((Series series) => series.categoryId == categoryId)
        .toList();
  }

  @override
  Future<SeriesInfo> fetchSeriesInfo(int seriesId) async {
    return SeriesInfo(
      seriesId: seriesId,
      seasons: const <Season>[
        Season(
          number: 1,
          episodes: <Episode>[
            Episode(id: 401, name: 'Pilot', episodeNumber: 1),
            Episode(id: 402, name: 'Cat\'s in the Bag', episodeNumber: 2),
          ],
        ),
      ],
    );
  }

  @override
  Future<String> buildEpisodeStreamUrl(Episode episode) async {
    return 'http://server:8080/series/user/pass/${episode.id}.mp4';
  }

  @override
  Future<List<EpgEntry>> fetchShortEpg(int streamId) async {
    return <EpgEntry>[];
  }

  @override
  Future<List<EpgEntry>> fetchFullEpg(int streamId) async {
    return <EpgEntry>[];
  }
}

void main() {
  Future<AuthBloc> pumpApp(
    WidgetTester tester, {
    UserAccount? stored,
    List<AuthEvent>? seed,
  }) async {
    final _FakeRepository repository = _FakeRepository()
      ..storedAccount = stored;
    final AuthBloc bloc = AuthBloc(repository)..add(const AuthStarted());
    await tester.pumpWidget(
      KyloraApp(
        authBloc: bloc,
        liveBloc: LiveBloc(repository),
        vodBloc: VodBloc(repository),
        seriesBloc: SeriesBloc(repository),
        epgBloc: EpgBloc(repository),
        repository: repository,
        playbackController: PlaybackController(),
      ),
    );
    if (seed != null) {
      for (final AuthEvent event in seed) {
        bloc.add(event);
      }
    }
    await tester.pumpAndSettle();
    return bloc;
  }

  testWidgets('Sin sesión guardada se muestra el login', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Connect to IPTV'), findsOneWidget);
  });

  testWidgets('Con sesión guardada se muestra el dashboard', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      stored: const UserAccount(
        serverUrl: 'http://server:8080',
        username: 'user',
        password: 'pass',
        status: 'Active',
      ),
    );
    expect(find.byType(HomeShellScreen), findsOneWidget);
    expect(find.text('Kylora'), findsOneWidget);
  });

  testWidgets('Login válido navega al dashboard', (WidgetTester tester) async {
    final AuthBloc bloc = await pumpApp(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'http://server:8080',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'user');
    await tester.enterText(find.byType(TextFormField).at(2), 'pass');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(bloc.state, isA<AuthAuthenticated>());
    expect(find.byType(HomeShellScreen), findsOneWidget);
  });

  testWidgets('Campos vacíos muestran validación', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('This field is required'), findsNWidgets(3));
  });

  testWidgets('URL inválida muestra mensaje de validación', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'not-a-url');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a valid URL (e.g. http://server:8080)'),
      findsOneWidget,
    );
  });

  testWidgets('Logout vuelve al login', (WidgetTester tester) async {
    final AuthBloc bloc = await pumpApp(
      tester,
      stored: const UserAccount(
        serverUrl: 'http://server:8080',
        username: 'user',
        password: 'pass',
        status: 'Active',
      ),
    );
    expect(find.byType(HomeShellScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(bloc.state, isA<AuthUnauthenticated>());
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Desde el dashboard se abre el catálogo en directo', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      stored: const UserAccount(
        serverUrl: 'http://server:8080',
        username: 'user',
        password: 'pass',
        status: 'Active',
      ),
    );
    expect(find.byType(HomeShellScreen), findsOneWidget);

    await tester.tap(find.text('Live TV'));
    await tester.pumpAndSettle();

    expect(find.byType(LiveScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Sports 1'), findsOneWidget);
    expect(find.text('News 24'), findsOneWidget);
    expect(find.text('Deportes'), findsOneWidget);
  });

  testWidgets('Desde el dashboard se abre el catálogo de películas', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      stored: const UserAccount(
        serverUrl: 'http://server:8080',
        username: 'user',
        password: 'pass',
        status: 'Active',
      ),
    );
    expect(find.byType(HomeShellScreen), findsOneWidget);

    await tester.tap(find.text('Movies'));
    await tester.pumpAndSettle();

    expect(find.byType(VodScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Matrix'), findsOneWidget);
    expect(find.text('Titanic'), findsOneWidget);
    expect(find.text('Acción'), findsOneWidget);
  });

  testWidgets('Desde el dashboard se abre el catálogo de series', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      stored: const UserAccount(
        serverUrl: 'http://server:8080',
        username: 'user',
        password: 'pass',
        status: 'Active',
      ),
    );
    expect(find.byType(HomeShellScreen), findsOneWidget);

    await tester.tap(find.text('Series'));
    await tester.pumpAndSettle();

    expect(find.byType(SeriesScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Breaking Bad'), findsOneWidget);
  });

  _testAuthBloc();
}

/// Repositorio falso para probar errores del bloc.
class _FailingRepository implements IptvRepository {
  const _FailingRepository();

  @override
  Future<UserAccount> login({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    throw const XtreamAuthException('invalid');
  }

  @override
  Future<UserAccount?> restoreSession() async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<List<Category>> fetchLiveCategories() async =>
      throw UnimplementedError();

  @override
  Future<List<Channel>> fetchLiveChannels({int? categoryId}) async =>
      throw UnimplementedError();

  @override
  Future<String> buildStreamUrl(Channel channel) async =>
      throw UnimplementedError();

  @override
  Future<List<Category>> fetchVodCategories() async =>
      throw UnimplementedError();

  @override
  Future<List<Movie>> fetchVodStreams({int? categoryId}) async =>
      throw UnimplementedError();

  @override
  Future<String> buildVodStreamUrl(Movie movie) async =>
      throw UnimplementedError();

  @override
  Future<List<Category>> fetchSeriesCategories() async =>
      throw UnimplementedError();

  @override
  Future<List<Series>> fetchSeries({int? categoryId}) async =>
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

void _testAuthBloc() {
  test('AuthBloc: credenciales inválidas emite AuthFailure', () async {
    final AuthBloc bloc = AuthBloc(const _FailingRepository());
    bloc.add(
      const AuthLoginRequested(
        serverUrl: 'http://server:8080',
        username: 'user',
        password: 'wrong',
      ),
    );
    await expectLater(
      bloc.stream,
      emitsInOrder(<dynamic>[isA<AuthChecking>(), isA<AuthFailure>()]),
    );
    await bloc.close();
  });

  test('AuthBloc: login válido emite AuthAuthenticated y logout AuthUnauthenticated', () async {
    final _FakeRepository repository = _FakeRepository();
    final AuthBloc bloc = AuthBloc(repository)..add(const AuthStarted());
    await expectLater(
      bloc.stream,
      emitsInOrder(<dynamic>[isA<AuthChecking>(), isA<AuthUnauthenticated>()]),
    );
    bloc.add(
      const AuthLoginRequested(
        serverUrl: 'http://server:8080',
        username: 'user',
        password: 'pass',
      ),
    );
    await expectLater(
      bloc.stream,
      emitsInOrder(<dynamic>[isA<AuthChecking>(), isA<AuthAuthenticated>()]),
    );
    bloc.add(const AuthLogoutRequested());
    await expectLater(
      bloc.stream,
      emitsInOrder(<dynamic>[isA<AuthUnauthenticated>()]),
    );
    await bloc.close();
  });
}
