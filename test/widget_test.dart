import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/app.dart';
import 'package:kylora/data/datasources/remote/xtream_api_client.dart';
import 'package:kylora/domain/entities/category.dart';
import 'package:kylora/domain/entities/channel.dart';
import 'package:kylora/domain/entities/user_account.dart';
import 'package:kylora/domain/repositories/iptv_repository.dart';
import 'package:kylora/presentation/blocs/auth/auth_bloc.dart';
import 'package:kylora/presentation/blocs/auth/auth_event.dart';
import 'package:kylora/presentation/blocs/auth/auth_state.dart';
import 'package:kylora/presentation/blocs/live/live_bloc.dart';
import 'package:kylora/presentation/screens/auth/login_screen.dart';
import 'package:kylora/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:kylora/presentation/screens/live/live_screen.dart';

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
        repository: repository,
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
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('user'), findsOneWidget);
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
    expect(find.byType(DashboardScreen), findsOneWidget);
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
    expect(find.byType(DashboardScreen), findsOneWidget);

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
    expect(find.byType(DashboardScreen), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Live TV'));
    await tester.pumpAndSettle();

    expect(find.byType(LiveScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Sports 1'), findsOneWidget);
    expect(find.text('News 24'), findsOneWidget);
    expect(find.text('Deportes'), findsOneWidget);
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
