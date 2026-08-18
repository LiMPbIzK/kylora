import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/app.dart';
import 'package:kylora/data/datasources/remote/xtream_api_client.dart';
import 'package:kylora/domain/entities/user_account.dart';
import 'package:kylora/domain/repositories/iptv_repository.dart';
import 'package:kylora/presentation/blocs/auth/auth_bloc.dart';
import 'package:kylora/presentation/blocs/auth/auth_event.dart';
import 'package:kylora/presentation/blocs/auth/auth_state.dart';
import 'package:kylora/presentation/screens/auth/login_screen.dart';
import 'package:kylora/presentation/screens/dashboard/dashboard_screen.dart';

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
}

void main() {
  Future<AuthBloc> pumpApp(
    WidgetTester tester, {
    UserAccount? stored,
    List<AuthEvent>? seed,
  }) async {
    final _FakeRepository repository = _FakeRepository()..storedAccount = stored;
    final AuthBloc bloc = AuthBloc(repository)..add(const AuthStarted());
    await tester.pumpWidget(KyloraApp(authBloc: bloc));
    if (seed != null) {
      for (final AuthEvent event in seed) {
        bloc.add(event);
      }
    }
    await tester.pumpAndSettle();
    return bloc;
  }

  testWidgets('Sin sesión guardada se muestra el login', (WidgetTester tester) async {
    await pumpApp(tester);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Connect to IPTV'), findsOneWidget);
  });

  testWidgets('Con sesión guardada se muestra el dashboard', (WidgetTester tester) async {
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

    await tester.enterText(find.byType(TextFormField).at(0), 'http://server:8080');
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

  testWidgets('URL inválida muestra mensaje de validación', (WidgetTester tester) async {
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
      emitsInOrder(<dynamic>[
        isA<AuthChecking>(),
        isA<AuthFailure>(),
      ]),
    );
    await bloc.close();
  });

  test('AuthBloc: login válido emite AuthAuthenticated y logout AuthUnauthenticated', () async {
    final _FakeRepository repository = _FakeRepository();
    final AuthBloc bloc = AuthBloc(repository)..add(const AuthStarted());
    await expectLater(
      bloc.stream,
      emitsInOrder(<dynamic>[
        isA<AuthChecking>(),
        isA<AuthUnauthenticated>(),
      ]),
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
      emitsInOrder(<dynamic>[
        isA<AuthChecking>(),
        isA<AuthAuthenticated>(),
      ]),
    );
    bloc.add(const AuthLogoutRequested());
    await expectLater(
      bloc.stream,
      emitsInOrder(<dynamic>[
        isA<AuthUnauthenticated>(),
      ]),
    );
    await bloc.close();
  });
}
