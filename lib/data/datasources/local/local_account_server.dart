import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../../domain/entities/iptv_auth_config.dart';
import '../../../domain/entities/iptv_source_type.dart';
import '../../../domain/entities/user_account.dart';
import '../../../domain/repositories/iptv_repository.dart';
import 'auth_store.dart';

/// Servidor HTTP local y efímero para importar y gestionar cuentas desde el
/// móvil en la misma red Wi-Fi.
///
/// No se abre a Internet: se enlaza mientras la pantalla de importación está
/// visible y se cierra al salir. El token de sesión va en la URL/QR.
class LocalAccountServer {
  LocalAccountServer({
    required this.repository,
    required this.accountStore,
    required this.onAccountsChanged,
    this.onAuthenticated,
  });

  final IptvRepository repository;
  final AccountStore accountStore;
  final void Function() onAccountsChanged;

  /// Se invoca cuando una cuenta se autentica correctamente desde la web.
  /// Es el puente para que `AuthBloc` actualice la sesión del TV.
  final void Function(UserAccount account)? onAuthenticated;

  HttpServer? _server;
  String? _token;
  String? _url;

  String? get url => _url;

  bool get isRunning => _server != null;

  Future<String> start() async {
    if (_url != null) return _url!;

    final HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    final String? ip = await _localIp();
    if (ip == null) {
      await server.close(force: true);
      throw StateError('No hay una dirección IPv4 local disponible');
    }

    final Random random = Random.secure();
    _token = base64UrlEncode(List<int>.generate(24, (_) => random.nextInt(256)))
        .replaceAll('=', '');
    _server = server;
    _url = 'http://$ip:${server.port}/?token=$_token';

    server.listen(
      _handleRequest,
      onError: (Object error) {
        // El servidor se cierra al salir de la pantalla; un error de socket
        // aislado no debe tumbar la app.
      },
      cancelOnError: false,
    );
    return _url!;
  }

  Future<void> stop() async {
    final HttpServer? server = _server;
    _server = null;
    _url = null;
    _token = null;
    await server?.close(force: true);
  }

  Future<String?> _localIp() async {
    try {
      final List<NetworkInterface> interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      InternetAddress? fallback;
      for (final NetworkInterface interface in interfaces) {
        for (final InternetAddress address in interface.addresses) {
          if (address.isLoopback) continue;
          if (address.address.startsWith('169.254.')) continue;
          fallback ??= address;
          final String name = interface.name.toLowerCase();
          if (name.contains('wlan') ||
              name.contains('wifi') ||
              name.contains('eth') ||
              name.contains('en')) {
            return address.address;
          }
        }
      }
      return fallback?.address;
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      if (request.uri.queryParameters['token'] != _token) {
        await _write(
          request,
          status: HttpStatus.forbidden,
          html: _messagePage(
            'Acceso no autorizado',
            'Abre la dirección que muestra la TV.',
          ),
        );
        return;
      }

      if (request.method == 'GET' && request.uri.path == '/') {
        await _write(
          request,
          html: await _renderPage(editId: request.uri.queryParameters['edit']),
        );
        return;
      }
      if (request.method == 'POST' && request.uri.path == '/add') {
        await _handleAdd(request);
        return;
      }
      if (request.method == 'POST' && request.uri.path == '/update') {
        await _handleUpdate(request);
        return;
      }
      if (request.method == 'POST' && request.uri.path == '/login') {
        await _handleLogin(request);
        return;
      }
      if (request.method == 'POST' && request.uri.path == '/rename') {
        await _handleRename(request);
        return;
      }
      if (request.method == 'POST' && request.uri.path == '/delete') {
        await _handleDelete(request);
        return;
      }

      await _write(
        request,
        status: HttpStatus.notFound,
        html: _messagePage('No encontrado', 'Vuelve a la página principal.'),
      );
    } catch (error) {
      await _write(
        request,
        status: HttpStatus.internalServerError,
        html: _messagePage(
          'Error inesperado',
          'No se pudo completar la operación.',
        ),
      );
    }
  }

  Future<Map<String, String>> _readForm(HttpRequest request) async {
    final String body = await utf8.decoder.bind(request).join();
    return Uri.splitQueryString(body);
  }

  Future<void> _handleAdd(HttpRequest request) async {
    final Map<String, String> form = await _readForm(request);
    final bool isM3u = form['source'] == 'm3u';
    final String label = (form['label'] ?? '').trim();
    final bool activate = form['activate'] == 'on';

    final IptvAuthConfig? config = _configFromForm(form, isM3u: isM3u);
    if (config == null) {
      await _write(
        request,
        html: await _renderPage(
          error: isM3u
              ? 'La URL de la lista M3U no es válida.'
              : 'Completa el host, el usuario y la contraseña.',
        ),
      );
      return;
    }

    final String id = _fingerprintFor(config);
    final List<StoredAccount> existing = await accountStore.readAll();
    if (existing.any((StoredAccount account) => account.id == id)) {
      await _write(
        request,
        html: await _renderPage(
          error: 'Ya existe una cuenta con ese host y usuario. Edítala desde la lista para cambiar la contraseña.',
        ),
      );
      return;
    }

    // Guardar primero permite conservar cuentas caducadas o no verificables.
    await accountStore.write(
      _credentialsFromConfig(config),
      label: label.isEmpty ? null : label,
      activate: false,
    );
    onAccountsChanged();

    if (activate) {
      await _authenticate(request, config, savedMessage: 'Cuenta guardada. ');
      return;
    }

    await _write(
      request,
      html: await _renderPage(
        message: 'Cuenta guardada. La cuenta actual sigue activa.',
      ),
    );
  }

  Future<void> _handleUpdate(HttpRequest request) async {
    final Map<String, String> form = await _readForm(request);
    final String id = (form['id'] ?? '').trim();
    final List<StoredAccount> accounts = await accountStore.readAll();
    StoredAccount? previous;
    for (final StoredAccount account in accounts) {
      if (account.id == id) {
        previous = account;
        break;
      }
    }
    if (previous == null) {
      await _write(
        request,
        html: await _renderPage(error: 'La cuenta ya no existe.'),
      );
      return;
    }

    final bool isM3u = form['source'] == 'm3u';
    final String password = (form['password'] ?? '').trim();
    final IptvAuthConfig? config = _configFromForm(
      form,
      isM3u: isM3u,
      fallbackPassword: password.isEmpty ? previous.credentials.password : null,
    );
    if (config == null) {
      await _write(
        request,
        html: await _renderPage(error: 'Revisa los datos de conexión.'),
      );
      return;
    }

    final String label = (form['label'] ?? '').trim();
    await accountStore.replace(
      id,
      _credentialsFromConfig(config),
      label: label.isEmpty ? null : label,
    );
    onAccountsChanged();

    if (form['activate'] == 'on') {
      await _authenticate(
        request,
        config,
        savedMessage: 'Cuenta actualizada. ',
      );
      return;
    }

    await _write(
      request,
      html: await _renderPage(message: 'Cuenta actualizada.'),
    );
  }

  Future<void> _handleLogin(HttpRequest request) async {
    final Map<String, String> form = await _readForm(request);
    final String id = (form['id'] ?? '').trim();
    final List<StoredAccount> accounts = await accountStore.readAll();
    StoredAccount? account;
    for (final StoredAccount candidate in accounts) {
      if (candidate.id == id) {
        account = candidate;
        break;
      }
    }
    if (account == null) {
      await _write(
        request,
        html: await _renderPage(error: 'La cuenta ya no existe.'),
      );
      return;
    }
    await _authenticate(
      request,
      _configFromStored(account.credentials, account.label),
    );
  }

  Future<void> _authenticate(
    HttpRequest request,
    IptvAuthConfig config, {
    String savedMessage = '',
  }) async {
    try {
      final UserAccount account = await repository.login(
        config,
        activate: true,
      );
      await _rememberStatus(account);
      onAccountsChanged();
      if (account.isActive && !account.isExpired) {
        onAuthenticated?.call(account);
        await _write(
          request,
          html: await _renderPage(
            message: '${savedMessage}Sesión iniciada correctamente.',
          ),
        );
        return;
      }
      await _write(
        request,
        html: await _renderPage(
          error:
              '${savedMessage}La cuenta está guardada, pero no está activa o ha caducado.',
        ),
      );
    } on Exception catch (error) {
      await _write(
        request,
        html: await _renderPage(
          error:
              '${savedMessage}La cuenta está guardada, pero no se pudo iniciar sesión: ${_errorMessage(error)}',
        ),
      );
    }
  }

  IptvAuthConfig? _configFromForm(
    Map<String, String> form, {
    required bool isM3u,
    String? fallbackPassword,
  }) {
    if (isM3u) {
      final String m3uUrl = (form['m3uUrl'] ?? '').trim();
      final String xmltvUrl = (form['xmltvUrl'] ?? '').trim();
      if (!_validUrl(m3uUrl)) return null;
      return M3uAuthConfig(
        m3uUrl: m3uUrl,
        xmltvUrl: xmltvUrl.isEmpty ? null : xmltvUrl,
        displayName: (form['label'] ?? '').trim().isEmpty
            ? null
            : (form['label'] ?? '').trim(),
      );
    }
    final String serverUrl = (form['serverUrl'] ?? '').trim();
    final String username = (form['username'] ?? '').trim();
    final String password = fallbackPassword ?? (form['password'] ?? '');
    if (!_validUrl(serverUrl) || username.isEmpty || password.isEmpty) {
      return null;
    }
    return XtreamAuthConfig(
      serverUrl: serverUrl,
      username: username,
      password: password,
    );
  }

  IptvAuthConfig _configFromStored(
    StoredCredentials credentials,
    String label,
  ) {
    if (credentials.sourceType == IptvSourceType.m3u) {
      return M3uAuthConfig(
        m3uUrl: credentials.m3uUrl ?? credentials.serverUrl,
        xmltvUrl: credentials.xmltvUrl,
        displayName: label,
      );
    }
    return XtreamAuthConfig(
      serverUrl: credentials.serverUrl,
      username: credentials.username,
      password: credentials.password,
    );
  }

  StoredCredentials _credentialsFromConfig(IptvAuthConfig config) {
    if (config is M3uAuthConfig) {
      return StoredCredentials(
        serverUrl: config.m3uUrl,
        username: '',
        password: '',
        sourceType: IptvSourceType.m3u,
        m3uUrl: config.m3uUrl,
        xmltvUrl: config.xmltvUrl,
      );
    }
    final XtreamAuthConfig xtream = config as XtreamAuthConfig;
    return StoredCredentials(
      serverUrl: xtream.serverUrl,
      username: xtream.username,
      password: xtream.password,
      sourceType: IptvSourceType.xtream,
    );
  }

  Future<void> _rememberStatus(UserAccount account) async {
    try {
      final List<StoredAccount> accounts = await accountStore.readAll();
      for (final StoredAccount candidate in accounts) {
        final StoredCredentials credentials = candidate.credentials;
        final bool sameSource =
            credentials.sourceUrl == account.serverUrl ||
            credentials.serverUrl == account.serverUrl;
        final bool sameUser =
            credentials.sourceType == IptvSourceType.m3u ||
            credentials.username == account.username;
        if (credentials.sourceType == account.sourceType &&
            sameSource &&
            sameUser) {
          await accountStore.updateMetadata(
            candidate.id,
            lastStatus: account.status,
            expiresAt: account.expiresAt,
            lastCheckedAt: DateTime.now(),
          );
          return;
        }
      }
    } catch (_) {
      // No bloquear el alta por no poder guardar metadatos.
    }
  }

  Future<void> _handleRename(HttpRequest request) async {
    final Map<String, String> form = await _readForm(request);
    final String id = (form['id'] ?? '').trim();
    final String label = (form['label'] ?? '').trim();
    if (id.isEmpty || label.isEmpty) {
      await _write(
        request,
        html: await _renderPage(error: 'La etiqueta no puede estar vacía.'),
      );
      return;
    }
    await accountStore.rename(id, label);
    onAccountsChanged();
    await _write(
      request,
      html: await _renderPage(message: 'Etiqueta actualizada.'),
    );
  }

  Future<void> _handleDelete(HttpRequest request) async {
    final Map<String, String> form = await _readForm(request);
    final String id = (form['id'] ?? '').trim();
    final String? activeId = await accountStore.readActiveId();
    if (id.isEmpty) {
      await _write(
        request,
        html: await _renderPage(error: 'Cuenta no válida.'),
      );
      return;
    }
    if (id == activeId) {
      await _write(
        request,
        html: await _renderPage(
          error:
              'No se puede borrar la cuenta activa. Cambia de cuenta primero.',
        ),
      );
      return;
    }
    await accountStore.remove(id);
    onAccountsChanged();
    await _write(
      request,
      html: await _renderPage(message: 'Cuenta eliminada.'),
    );
  }

  Future<String> _renderPage({
    String? message,
    String? error,
    String? editId,
  }) async {
    final List<StoredAccount> accounts = await accountStore.readAll();
    final String? activeId = await accountStore.readActiveId();
    StoredAccount? editing;
    if (editId != null) {
      for (final StoredAccount account in accounts) {
        if (account.id == editId) {
          editing = account;
          break;
        }
      }
    }
    final StringBuffer rows = StringBuffer();
    for (final StoredAccount account in accounts) {
      final bool active = account.id == activeId;
      final String status = account.lastStatus == null
          ? 'Sin validar'
          : account.lastStatus!;
      rows
        ..write('<tr>')
        ..write(
          '<td>${_escape(account.label)}${active ? ' <span class="badge">activa</span>' : ''}'
          '<div class="hint">${_escape(status)}</div></td>',
        )
        ..write(
          '<td>${account.credentials.sourceType == IptvSourceType.xtream ? 'Xtream' : 'M3U'}</td>',
        )
        ..write(
          '<td class="mono">${_escape(account.credentials.sourceUrl)}</td>',
        )
        ..write(
          '<td class="mono">${_escape(account.credentials.username.isEmpty ? '—' : account.credentials.username)}</td>',
        )
        ..write(
          '<td><form method="post" action="/login?token=$_token" class="inline">'
          '<input type="hidden" name="id" value="${_escape(account.id)}">'
          '<button type="submit">Entrar</button>'
          '</form>'
          '<a class="button secondary" href="/?token=$_token&edit=${Uri.encodeQueryComponent(account.id)}">Editar</a>'
          '<form method="post" action="/rename?token=$_token" class="inline">'
          '<input type="hidden" name="id" value="${_escape(account.id)}">'
          '<input name="label" value="${_escape(account.label)}" maxlength="60" required>'
          '<button type="submit">Guardar etiqueta</button>'
          '</form>'
          '<form method="post" action="/delete?token=$_token" class="inline" '
          'onsubmit="return confirm(\'¿Eliminar esta cuenta?\')">'
          '<input type="hidden" name="id" value="${_escape(account.id)}">'
          '<button type="submit" class="danger" ${active ? 'disabled' : ''}>Eliminar</button>'
          '</form></td>',
        )
        ..write('</tr>');
    }
    if (accounts.isEmpty) {
      rows.write(
        '<tr><td colspan="5" class="empty">No hay cuentas guardadas.</td></tr>',
      );
    }

    final String notice = message != null
        ? '<div class="notice">${_escape(message)}</div>'
        : error != null
        ? '<div class="notice error">${_escape(error)}</div>'
        : '';

    final bool isEditing = editing != null;
    final StoredCredentials? current = editing?.credentials;
    final bool editingM3u = current?.sourceType == IptvSourceType.m3u;
    final String formTitle = isEditing ? 'Editar cuenta' : 'Añadir cuenta';
    final String formAction = isEditing ? '/update' : '/add';
    final String labelValue = isEditing ? _escape(editing.label) : '';
    final String serverValue = isEditing && !editingM3u
        ? _escape(current!.serverUrl)
        : '';
    final String usernameValue = isEditing && !editingM3u
        ? _escape(current!.username)
        : '';
    final String m3uValue = isEditing && editingM3u
        ? _escape(current!.m3uUrl ?? current.serverUrl)
        : '';
    final String xmltvValue = isEditing && editingM3u
        ? _escape(current!.xmltvUrl ?? '')
        : '';

    return '''<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Kylora · Cuentas</title>
<style>
:root { color-scheme: light; }
* { box-sizing: border-box; }
body { margin: 0; padding: 24px; font: 15px/1.45 system-ui, sans-serif; background: #f2f4f8; color: #172033; }
main { max-width: 980px; margin: 0 auto; }
h1 { margin: 0 0 6px; font-size: 26px; }
h2 { margin: 28px 0 10px; font-size: 18px; }
p { margin: 6px 0 16px; color: #526079; }
.card { background: white; border-radius: 14px; padding: 18px; box-shadow: 0 4px 18px #17203312; margin-bottom: 18px; }
label { display: block; margin: 10px 0 4px; font-weight: 600; }
input, select { width: 100%; padding: 10px 11px; border: 1px solid #cbd3e1; border-radius: 8px; font: inherit; }
button, .button { display: inline-block; margin: 8px 4px 0 0; padding: 9px 13px; border: 0; border-radius: 8px; background: #5546d6; color: white; font: inherit; font-weight: 600; cursor: pointer; text-decoration: none; }
button:hover, .button:hover { background: #4639bd; }
.button.secondary { background: #e7e4ff; color: #3f34a8; }
.button.secondary:hover { background: #d8d3ff; }
button.danger { background: #d83b4e; }
button.danger:hover { background: #b92d3e; }
button:disabled { background: #aeb6c5; cursor: not-allowed; }
table { width: 100%; border-collapse: collapse; }
th, td { padding: 10px 8px; border-bottom: 1px solid #e7ebf2; text-align: left; vertical-align: middle; }
th { color: #526079; font-size: 12px; text-transform: uppercase; letter-spacing: .04em; }
.mono { font-family: ui-monospace, SFMono-Regular, Consolas, monospace; font-size: 12px; word-break: break-all; }
.notice { padding: 11px 13px; border-radius: 9px; background: #e5f7eb; color: #176b36; margin: 12px 0; }
.notice.error { background: #ffe8eb; color: #a51f32; }
.badge { font-size: 11px; background: #e4e0ff; color: #4a3fc0; border-radius: 99px; padding: 2px 7px; }
.inline { display: inline-flex; gap: 4px; align-items: center; margin: 2px 4px 2px 0; }
.inline input { width: 150px; }
.inline button { margin: 0; padding: 7px 9px; font-size: 12px; }
.empty { color: #7a8497; text-align: center; padding: 20px; }
.hint { font-size: 12px; color: #7a8497; }
@media (max-width: 720px) {
  body { padding: 12px; }
  table, thead, tbody, tr, th, td { display: block; }
  thead { display: none; }
  tr { padding: 10px 0; border-bottom: 1px solid #e7ebf2; }
  td { border: 0; padding: 4px 0; }
  .inline { display: flex; }
  .inline input { flex: 1; width: auto; }
}
</style>
</head>
<body>
<main>
<h1>Kylora · Cuentas</h1>
<p>Solo funciona en la red local. Puedes guardar una cuenta aunque esté caducada o el proveedor no responda; la contraseña nunca se muestra en esta página.</p>
$notice
<div class="card">
<h2>$formTitle</h2>
<form method="post" action="$formAction?token=$_token">
${isEditing ? '<input type="hidden" name="id" value="${_escape(editing.id)}">' : ''}
<label for="label">Etiqueta</label>
<input id="label" name="label" value="$labelValue" maxlength="60" placeholder="Ej. Cuenta principal">
<label for="source">Tipo de fuente</label>
<select id="source" name="source" onchange="toggleSource()">
<option value="xtream" ${!editingM3u ? 'selected' : ''}>Xtream</option>
<option value="m3u" ${editingM3u ? 'selected' : ''}>M3U / XMLTV</option>
</select>
<div id="xtreamFields" style="display:${editingM3u ? 'none' : 'block'}">
<label for="serverUrl">Host / URL</label>
<input id="serverUrl" name="serverUrl" value="$serverValue" placeholder="http://servidor:8080" inputmode="url">
<label for="username">Usuario</label>
<input id="username" name="username" value="$usernameValue" autocomplete="username">
<label for="password">Contraseña</label>
<input id="password" name="password" type="password" autocomplete="current-password" placeholder="${isEditing ? 'Dejar vacío para conservar la actual' : ''}">
</div>
<div id="m3uFields" style="display:${editingM3u ? 'block' : 'none'}">
<label for="m3uUrl">URL de la lista M3U</label>
<input id="m3uUrl" name="m3uUrl" value="$m3uValue" inputmode="url">
<label for="xmltvUrl">URL XMLTV (opcional)</label>
<input id="xmltvUrl" name="xmltvUrl" value="$xmltvValue" inputmode="url">
</div>
<label class="check"><input type="checkbox" name="activate" style="width:auto"> Guardar y entrar</label>
<button type="submit">Guardar cuenta</button>
${isEditing ? '<a class="button secondary" href="/?token=$_token">Cancelar</a>' : ''}
</form>
<p class="hint">Sin marcar “Guardar y entrar”, la cuenta se guarda sin validar y podrás intentar entrar más tarde.</p>
</div>
<div class="card">
<h2>Cuentas guardadas</h2>
<table>
<thead><tr><th>Etiqueta</th><th>Tipo</th><th>Servidor</th><th>Usuario</th><th>Acciones</th></tr></thead>
<tbody>$rows</tbody>
</table>
</div>
</main>
<script>
function toggleSource() {
  const m3u = document.getElementById('source').value === 'm3u';
  document.getElementById('xtreamFields').style.display = m3u ? 'none' : 'block';
  document.getElementById('m3uFields').style.display = m3u ? 'block' : 'none';
}
</script>
</body>
</html>''';
  }

  Future<void> _write(
    HttpRequest request, {
    required String html,
    int status = HttpStatus.ok,
  }) async {
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.html
      ..headers.set(HttpHeaders.cacheControlHeader, 'no-store')
      ..write(html);
    await request.response.close();
  }

  String _messagePage(String title, String message) {
    return '''<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>$title</title></head>
<body style="font:16px system-ui;background:#f2f4f8;color:#172033;padding:32px">
<h1>$title</h1><p>$message</p></body></html>''';
  }

  String _errorMessage(Object error) {
    final String name = error.runtimeType.toString();
    if (name.contains('Auth')) return 'Credenciales incorrectas.';
    if (name.contains('Network')) {
      return 'No se pudo conectar con el proveedor. Revisa la conexión.';
    }
    if (name.contains('M3u')) return 'La lista M3U no es válida.';
    return 'No se pudo validar la cuenta.';
  }

  bool _validUrl(String value) {
    final Uri? uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'file');
  }

  String _fingerprintFor(IptvAuthConfig config) {
    if (config is XtreamAuthConfig) {
      return 'xtream|${config.serverUrl}|${config.username}';
    }
    final M3uAuthConfig m3u = config as M3uAuthConfig;
    return 'm3u|${m3u.m3uUrl}';
  }

  String _escape(Object? value) => const HtmlEscape().convert('${value ?? ''}');
}
