import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../../domain/entities/iptv_auth_config.dart';
import '../../../domain/entities/iptv_source_type.dart';
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
  });

  final IptvRepository repository;
  final AccountStore accountStore;
  final void Function() onAccountsChanged;

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
        await _write(request, html: await _renderPage());
        return;
      }
      if (request.method == 'POST' && request.uri.path == '/add') {
        await _handleAdd(request);
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

    final IptvAuthConfig config;
    if (isM3u) {
      final String m3uUrl = (form['m3uUrl'] ?? '').trim();
      final String xmltvUrl = (form['xmltvUrl'] ?? '').trim();
      if (!_validUrl(m3uUrl)) {
        await _write(
          request,
          html: await _renderPage(
            error: 'La URL de la lista M3U no es válida.',
          ),
        );
        return;
      }
      config = M3uAuthConfig(
        m3uUrl: m3uUrl,
        xmltvUrl: xmltvUrl.isEmpty ? null : xmltvUrl,
        displayName: label.isEmpty ? null : label,
      );
    } else {
      final String serverUrl = (form['serverUrl'] ?? '').trim();
      final String username = (form['username'] ?? '').trim();
      final String password = form['password'] ?? '';
      if (!_validUrl(serverUrl) || username.isEmpty || password.isEmpty) {
        await _write(
          request,
          html: await _renderPage(
            error: 'Completa el host, el usuario y la contraseña.',
          ),
        );
        return;
      }
      config = XtreamAuthConfig(
        serverUrl: serverUrl,
        username: username,
        password: password,
      );
    }

    final String id = _fingerprintFor(config);
    final List<StoredAccount> existing = await accountStore.readAll();
    if (existing.any((StoredAccount account) => account.id == id)) {
      await _write(
        request,
        html: await _renderPage(
          error: 'Ya existe una cuenta con ese host y usuario. Cambia solo la etiqueta desde la lista.',
        ),
      );
      return;
    }

    try {
      await repository.login(config, activate: activate);
      if (label.isNotEmpty) {
        await accountStore.rename(id, label);
      }
      onAccountsChanged();
      await _write(
        request,
        html: await _renderPage(
          message: activate
              ? 'Cuenta guardada y activada.'
              : 'Cuenta guardada. La cuenta actual sigue activa.',
        ),
      );
    } on Exception catch (error) {
      await _write(
        request,
        html: await _renderPage(error: _errorMessage(error)),
      );
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

  Future<String> _renderPage({String? message, String? error}) async {
    final List<StoredAccount> accounts = await accountStore.readAll();
    final String? activeId = await accountStore.readActiveId();
    final StringBuffer rows = StringBuffer();
    for (final StoredAccount account in accounts) {
      final bool active = account.id == activeId;
      rows
        ..write('<tr>')
        ..write(
          '<td>${_escape(account.label)}${active ? ' <span class="badge">activa</span>' : ''}</td>',
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
          '<td><form method="post" action="/rename?token=$_token" class="inline">'
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
button { margin-top: 8px; padding: 9px 13px; border: 0; border-radius: 8px; background: #5546d6; color: white; font: inherit; font-weight: 600; cursor: pointer; }
button:hover { background: #4639bd; }
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
<p>Solo funciona en la red local. Los datos de conexión no se pueden modificar; solo la etiqueta o borrar la cuenta.</p>
$notice
<div class="card">
<h2>Añadir cuenta</h2>
<form method="post" action="/add?token=$_token">
<label for="label">Etiqueta</label>
<input id="label" name="label" maxlength="60" placeholder="Ej. Cuenta principal">
<label for="source">Tipo de fuente</label>
<select id="source" name="source" onchange="toggleSource()">
<option value="xtream">Xtream</option>
<option value="m3u">M3U / XMLTV</option>
</select>
<div id="xtreamFields">
<label for="serverUrl">Host / URL</label>
<input id="serverUrl" name="serverUrl" placeholder="http://servidor:8080" inputmode="url">
<label for="username">Usuario</label>
<input id="username" name="username" autocomplete="username">
<label for="password">Contraseña</label>
<input id="password" name="password" type="password" autocomplete="current-password">
</div>
<div id="m3uFields" style="display:none">
<label for="m3uUrl">URL de la lista M3U</label>
<input id="m3uUrl" name="m3uUrl" inputmode="url">
<label for="xmltvUrl">URL XMLTV (opcional)</label>
<input id="xmltvUrl" name="xmltvUrl" inputmode="url">
</div>
<label class="check"><input type="checkbox" name="activate" style="width:auto"> Activar al guardar</label>
<button type="submit">Guardar cuenta</button>
</form>
<p class="hint">Por defecto la cuenta se guarda sin activar; podrás elegirla en Ajustes → Cambiar cuenta.</p>
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
