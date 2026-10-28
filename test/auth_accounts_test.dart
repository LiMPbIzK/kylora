import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/data/datasources/local/auth_store.dart';
import 'package:kylora/data/datasources/local/local_account_server.dart';
import 'package:kylora/domain/entities/iptv_auth_config.dart';
import 'package:kylora/domain/entities/iptv_source_type.dart';
import 'package:kylora/domain/entities/user_account.dart';
import 'package:kylora/domain/repositories/iptv_repository.dart';
import 'package:kylora/presentation/blocs/auth/auth_bloc.dart';
import 'package:kylora/presentation/blocs/auth/auth_event.dart';
import 'package:kylora/presentation/blocs/auth/auth_state.dart';

class _MemorySecureStorage extends FlutterSecureStorage {
  final Map<String, String> data = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => data[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      data.remove(key);
    } else {
      data[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    data.remove(key);
  }
}

class _MemAccountStore implements AccountStore {
  final List<StoredAccount> accounts = <StoredAccount>[];
  String? activeId;

  @override
  Future<StoredCredentials?> read() async {
    if (activeId == null) return null;
    for (final StoredAccount account in accounts) {
      if (account.id == activeId) return account.credentials;
    }
    return null;
  }

  @override
  Future<void> write(
    StoredCredentials credentials, {
    String? label,
    bool activate = true,
  }) async {
    final StoredAccount account = StoredAccount(
      credentials: credentials,
      label: label ?? credentials.username,
    );
    final int index = accounts.indexWhere(
      (StoredAccount item) => item.id == account.id,
    );
    if (index >= 0) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }
    if (activate) activeId = account.id;
  }

  @override
  Future<void> clear() async {
    activeId = null;
  }

  @override
  Future<List<StoredAccount>> readAll() async =>
      List<StoredAccount>.unmodifiable(accounts);

  @override
  Future<String?> readActiveId() async => activeId;

  @override
  Future<void> setActive(String id) async {
    activeId = id;
  }

  @override
  Future<void> rename(String id, String label) async {
    final int index = accounts.indexWhere(
      (StoredAccount account) => account.id == id,
    );
    if (index < 0) return;
    accounts[index] = StoredAccount(
      credentials: accounts[index].credentials,
      label: label,
    );
  }

  @override
  Future<void> remove(String id) async {
    accounts.removeWhere((StoredAccount account) => account.id == id);
    if (activeId == id) {
      activeId = accounts.isEmpty ? null : accounts.first.id;
    }
  }
}

class _SwitchRepository implements IptvRepository {
  _SwitchRepository(this.store);

  final _MemAccountStore store;

  @override
  Future<UserAccount?> restoreSession() async {
    final StoredCredentials? credentials = await store.read();
    if (credentials == null) return null;
    return UserAccount(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
      status: 'Active',
      sourceType: credentials.sourceType,
    );
  }

  @override
  Future<UserAccount> login(
    IptvAuthConfig config, {
    bool activate = true,
  }) async {
    final StoredCredentials credentials = switch (config) {
      XtreamAuthConfig() => StoredCredentials(
        serverUrl: config.serverUrl,
        username: config.username,
        password: config.password,
        sourceType: IptvSourceType.xtream,
      ),
      M3uAuthConfig() => StoredCredentials(
        serverUrl: config.m3uUrl,
        username: '',
        password: '',
        sourceType: IptvSourceType.m3u,
        m3uUrl: config.m3uUrl,
        xmltvUrl: config.xmltvUrl,
      ),
    };
    await store.write(
      credentials,
      label: config is M3uAuthConfig ? config.displayName : null,
      activate: activate,
    );
    return UserAccount(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
      status: 'Active',
      sourceType: credentials.sourceType,
    );
  }

  @override
  Future<void> logout() async {
    store.activeId = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

StoredAccount _account(String id, String label) => StoredAccount(
  credentials: StoredCredentials(
    serverUrl: 'http://$id.example:8080',
    username: id,
    password: 'pass-$id',
    sourceType: IptvSourceType.xtream,
  ),
  label: label,
);

void main() {
  test('AuthStore migra la sesión antigua y conserva varias cuentas', () async {
    final _MemorySecureStorage storage = _MemorySecureStorage();
    storage.data.addAll(<String, String>{
      'xtream_server_url': 'http://old.example:8080',
      'xtream_username': 'old-user',
      'xtream_password': 'old-pass',
      'iptv_source_type': 'xtream',
    });
    final AuthStore store = AuthStore(storage: storage);

    final StoredCredentials? migrated = await store.read();
    expect(migrated?.username, 'old-user');
    expect(await store.readAll(), hasLength(1));
    expect(storage.data.containsKey('xtream_server_url'), isFalse);

    await store.write(
      const StoredCredentials(
        serverUrl: 'http://new.example:8080',
        username: 'new-user',
        password: 'new-pass',
        sourceType: IptvSourceType.xtream,
      ),
      label: 'Cuenta nueva',
    );
    expect(await store.readAll(), hasLength(2));
    expect((await store.read())?.username, 'new-user');

    await store.clear();
    expect(await store.read(), isNull);
    expect(await store.readAll(), hasLength(2));

    await store.setActive((await store.readAll()).first.id);
    expect((await store.read())?.username, 'old-user');
  });

  test('AuthStore guarda sin activar y permite renombrar y borrar', () async {
    final AuthStore store = AuthStore(storage: _MemorySecureStorage());
    const StoredCredentials first = StoredCredentials(
      serverUrl: 'http://uno.example:8080',
      username: 'uno',
      password: 'pass',
      sourceType: IptvSourceType.xtream,
    );
    const StoredCredentials second = StoredCredentials(
      serverUrl: 'http://dos.example:8080',
      username: 'dos',
      password: 'pass',
      sourceType: IptvSourceType.xtream,
    );
    await store.write(first, label: 'Uno');
    await store.write(second, label: 'Dos', activate: false);

    expect((await store.read())?.username, 'uno');
    expect(await store.readAll(), hasLength(2));

    await store.rename(second.fingerprint, 'Dos renombrada');
    expect(
      (await store.readAll())
          .firstWhere(
            (StoredAccount account) => account.id == second.fingerprint,
          )
          .label,
      'Dos renombrada',
    );

    await store.remove(second.fingerprint);
    expect(await store.readAll(), hasLength(1));
    expect((await store.read())?.username, 'uno');
  });

  test('StoredAccount serializa etiqueta y credenciales', () {
    final StoredAccount original = _account('tres', 'Cuenta tres');
    final StoredAccount restored = StoredAccount.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.label, 'Cuenta tres');
    expect(restored.credentials.serverUrl, original.credentials.serverUrl);
    expect(restored.credentials.username, original.credentials.username);
    expect(restored.credentials.password, original.credentials.password);
    expect(restored.credentials.sourceType, IptvSourceType.xtream);
  });

  test('el servidor local sirve la página y guarda sin activar', () async {
    final _MemAccountStore store = _MemAccountStore();
    final StoredAccount first = _account('uno', 'Cuenta uno');
    store.accounts.add(first);
    store.activeId = first.id;
    final LocalAccountServer server = LocalAccountServer(
      repository: _SwitchRepository(store),
      accountStore: store,
      onAccountsChanged: () {},
    );
    final HttpClient client = HttpClient();
    try {
      final String url = await server.start();
      final Uri base = Uri.parse(url);

      final HttpClientResponse page = await (await client.getUrl(base)).close();
      expect(page.statusCode, HttpStatus.ok);
      final String html = await utf8.decoder.bind(page).join();
      expect(html, contains('Cuentas guardadas'));

      final String body = Uri(
        queryParameters: <String, String>{
          'label': 'Cuenta web',
          'source': 'xtream',
          'serverUrl': 'http://web.example:8080',
          'username': 'web',
          'password': 'webpass',
        },
      ).query;
      final HttpClientRequest add = await client.postUrl(
        base.replace(path: '/add'),
      );
      add.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      add.write(body);
      final HttpClientResponse added = await add.close();
      expect(added.statusCode, HttpStatus.ok);
      final String addedHtml = await utf8.decoder.bind(added).join();
      expect(addedHtml, contains('Cuenta guardada'));

      expect(store.accounts.length, 2);
      expect(store.activeId, first.id);

      final StoredAccount addedAccount = store.accounts.last;
      final HttpClientRequest rename = await client.postUrl(
        base.replace(path: '/rename'),
      );
      rename.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      rename.write(
        Uri(
          queryParameters: <String, String>{
            'id': addedAccount.id,
            'label': 'Renombrada',
          },
        ).query,
      );
      final HttpClientResponse renamed = await rename.close();
      await utf8.decoder.bind(renamed).join();
      expect(store.accounts.last.label, 'Renombrada');

      final HttpClientRequest delete = await client.postUrl(
        base.replace(path: '/delete'),
      );
      delete.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      delete.write(
        Uri(queryParameters: <String, String>{'id': addedAccount.id}).query,
      );
      final HttpClientResponse deleted = await delete.close();
      await utf8.decoder.bind(deleted).join();
      expect(store.accounts.length, 1);
      expect(store.activeId, first.id);
    } finally {
      await server.stop();
      client.close(force: true);
    }
  });

  test('AuthBloc guarda una cuenta nueva sin cambiar la activa', () async {
    final _MemAccountStore store = _MemAccountStore();
    final StoredAccount first = _account('uno', 'Cuenta uno');
    store.accounts.add(first);
    store.activeId = first.id;

    final AuthBloc bloc = AuthBloc(
      _SwitchRepository(store),
      accountStore: store,
    );
    bloc.add(const AuthStarted());
    await bloc.stream.firstWhere(
      (AuthState state) =>
          state is AuthAuthenticated && state.activeAccountId == first.id,
    );

    final Future<AuthState> added = bloc.stream.firstWhere(
      (AuthState state) =>
          state is AuthAuthenticated && state.accounts.length == 2,
    );
    bloc.add(
      const AuthLoginRequested(
        XtreamAuthConfig(
          serverUrl: 'http://nueva.example:8080',
          username: 'nueva',
          password: 'pass',
        ),
        activate: false,
      ),
    );
    final AuthAuthenticated state = await added as AuthAuthenticated;

    expect(state.account.username, 'uno');
    expect(state.activeAccountId, first.id);
    expect(store.activeId, first.id);
    expect(store.accounts, hasLength(2));
    await bloc.close();
  });

  test('AuthBloc cambia de cuenta sin borrar las demás', () async {
    final _MemAccountStore store = _MemAccountStore();
    final StoredAccount first = _account('uno', 'Cuenta uno');
    final StoredAccount second = _account('dos', 'Cuenta dos');
    store.accounts.addAll(<StoredAccount>[first, second]);
    store.activeId = first.id;

    final AuthBloc bloc = AuthBloc(
      _SwitchRepository(store),
      accountStore: store,
    );
    bloc.add(const AuthStarted());
    final AuthState initial = await bloc.stream.firstWhere(
      (AuthState state) =>
          state is AuthAuthenticated && state.activeAccountId == first.id,
    );
    expect(initial, isA<AuthAuthenticated>());
    expect((initial as AuthAuthenticated).accounts.length, 2);

    final Future<AuthState> switched = bloc.stream.firstWhere(
      (AuthState state) =>
          state is AuthAuthenticated && state.activeAccountId == second.id,
    );
    bloc.add(AuthAccountSwitchRequested(second.id));
    final AuthState switchedState = await switched;

    expect(store.activeId, second.id);
    expect(store.accounts.length, 2);
    expect((switchedState as AuthAuthenticated).account.username, 'dos');

    final Future<AuthState> loggedOut = bloc.stream.firstWhere(
      (AuthState state) => state is AuthUnauthenticated,
    );
    bloc.add(const AuthLogoutRequested());
    await loggedOut;
    expect(store.accounts.length, 2, reason: 'Cerrar sesión no borra cuentas');
    expect(store.activeId, isNull);

    await bloc.close();
  });
}
