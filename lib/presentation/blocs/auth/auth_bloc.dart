import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/local/auth_store.dart';
import '../../../data/datasources/local/pin_service.dart';
import '../../../data/datasources/remote/m3u_downloader.dart';
import '../../../data/datasources/remote/xtream_api_client.dart';
import '../../../domain/entities/iptv_source_type.dart';
import '../../../domain/entities/saved_account.dart';
import '../../../domain/entities/user_account.dart';
import '../../../domain/repositories/iptv_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc de autenticación: login, auto-login, cambio de cuenta y logout.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository, {this.accountStore})
    : super(const AuthChecking()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthAccountSwitchRequested>(_onAccountSwitchRequested);
    on<AuthAccountsReloadRequested>(_onAccountsReloadRequested);
    on<AuthExternalLoginSucceeded>(_onExternalLoginSucceeded);
  }

  final IptvRepository _repository;

  /// Almacén de cuentas. Es opcional para no romper los tests que solo
  /// ejercitan login/logout; en producción se inyecta `AuthStore`.
  final AccountStore? accountStore;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthChecking());
    try {
      final UserAccount? account = await _repository.restoreSession();
      if (account == null) {
        emit(const AuthUnauthenticated());
      } else {
        await _rememberStatus(account);
        if (!_isUsable(account)) {
          emit(const AuthFailure(message: 'accountExpired'));
          return;
        }
        emit(await _authenticatedState(account));
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final AuthState previous = state;
    emit(const AuthChecking());
    try {
      final UserAccount account = await _repository.login(
        event.config,
        activate: event.activate,
      );
      await _rememberStatus(account);
      if (!_isUsable(account) &&
          (event.activate || previous is! AuthAuthenticated)) {
        emit(const AuthFailure(message: 'accountExpired'));
        return;
      }
      final AuthAuthenticated loaded = await _authenticatedState(account);
      if (!event.activate && previous is AuthAuthenticated) {
        // Alta de una cuenta sin activar: se conserva la cuenta que ya estaba
        // en uso y solo se actualiza la lista de cuentas.
        emit(
          AuthAuthenticated(
            account: previous.account,
            accounts: loaded.accounts,
            activeAccountId: loaded.activeAccountId ?? previous.activeAccountId,
          ),
        );
      } else {
        emit(loaded);
      }
    } on XtreamAuthException {
      emit(const AuthFailure(message: 'invalidCredentials'));
    } on XtreamNetworkException {
      emit(const AuthFailure(message: 'networkError'));
    } on M3uNetworkException {
      emit(const AuthFailure(message: 'networkError'));
    } on M3uParseException {
      emit(const AuthFailure(message: 'm3uParseError'));
    } catch (_) {
      emit(const AuthFailure(message: 'unknownError'));
    }
  }

  /// Cambia la cuenta activa y recarga la sesión del proveedor.
  ///
  /// Se conserva la cuenta anterior si el nuevo proveedor no responde, para no
  /// dejar al usuario sin sesión al cambiar de cuenta.
  Future<void> _onAccountSwitchRequested(
    AuthAccountSwitchRequested event,
    Emitter<AuthState> emit,
  ) async {
    final AccountStore? store = accountStore;
    if (store == null) return;

    final AuthState previous = state;
    if (previous is AuthAuthenticated &&
        previous.activeAccountId == event.accountId) {
      return;
    }

    final List<StoredAccount> accounts = await store.readAll();
    final StoredAccount? target = _findAccount(accounts, event.accountId);
    if (target == null) return;

    final String? previousId = previous is AuthAuthenticated
        ? previous.activeAccountId
        : await store.readActiveId();

    await store.setActive(target.id);
    try {
      final UserAccount? account = await _repository.restoreSession();
      if (account == null) {
        throw StateError('No se pudo restaurar la cuenta');
      }
      await _rememberStatus(account);
      if (!_isUsable(account)) {
        if (previousId != null) {
          await store.setActive(previousId);
        }
        emit(const AuthFailure(message: 'accountExpired'));
        return;
      }
      emit(await _authenticatedState(account));
    } catch (_) {
      if (previousId != null) {
        await store.setActive(previousId);
      }
      emit(
        previous is AuthAuthenticated ? previous : const AuthUnauthenticated(),
      );
    }
  }

  Future<void> _onExternalLoginSucceeded(
    AuthExternalLoginSucceeded event,
    Emitter<AuthState> emit,
  ) async {
    await _rememberStatus(event.account);
    if (!_isUsable(event.account)) {
      emit(const AuthFailure(message: 'accountExpired'));
      return;
    }
    emit(await _authenticatedState(event.account));
  }

  Future<void> _onAccountsReloadRequested(
    AuthAccountsReloadRequested event,
    Emitter<AuthState> emit,
  ) async {
    final AuthState current = state;
    if (current is! AuthAuthenticated) return;

    final String? activeId = await _activeAccountId();
    // La web puede añadir una cuenta con "Activar al guardar": en ese caso el
    // almacén ya tiene otra activa y hay que recargar también la sesión.
    if (activeId != null && activeId != current.activeAccountId) {
      try {
        final UserAccount? account = await _repository.restoreSession();
        if (account != null) {
          emit(await _authenticatedState(account));
          return;
        }
      } catch (_) {
        // Se mantiene el estado anterior; la cuenta nueva sigue guardada.
      }
    }

    emit(
      AuthAuthenticated(
        account: current.account,
        accounts: await _savedAccounts(),
        activeAccountId: activeId ?? current.activeAccountId,
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    PinService.clearSession();
    emit(const AuthUnauthenticated());
  }

  Future<AuthAuthenticated> _authenticatedState(UserAccount account) async {
    final List<SavedAccount> savedAccounts = await _savedAccounts();
    final String? activeId = await _activeAccountId();
    return AuthAuthenticated(
      account: account,
      accounts: savedAccounts,
      activeAccountId: activeId,
    );
  }

  Future<List<SavedAccount>> _savedAccounts() async {
    final AccountStore? store = accountStore;
    if (store == null) return const <SavedAccount>[];
    try {
      final List<StoredAccount> accounts = await store.readAll();
      return accounts
          .map((StoredAccount account) => account.toSavedAccount())
          .toList();
    } catch (_) {
      return const <SavedAccount>[];
    }
  }

  Future<String?> _activeAccountId() async {
    try {
      return await accountStore?.readActiveId();
    } catch (_) {
      return null;
    }
  }

  StoredAccount? _findAccount(List<StoredAccount> accounts, String id) {
    for (final StoredAccount account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  bool _isUsable(UserAccount account) => account.isActive && !account.isExpired;

  Future<void> _rememberStatus(UserAccount account) async {
    final AccountStore? store = accountStore;
    if (store == null) return;
    try {
      final List<StoredAccount> accounts = await store.readAll();
      StoredAccount? match;
      for (final StoredAccount candidate in accounts) {
        final StoredCredentials credentials = candidate.credentials;
        if (credentials.sourceType != account.sourceType) continue;
        final bool sameSource =
            credentials.sourceUrl == account.serverUrl ||
            credentials.serverUrl == account.serverUrl;
        final bool sameUser =
            credentials.sourceType == IptvSourceType.m3u ||
            credentials.username == account.username;
        if (sameSource && sameUser) {
          match = candidate;
          break;
        }
      }
      if (match == null) return;
      await store.updateMetadata(
        match.id,
        lastStatus: account.status,
        expiresAt: account.expiresAt,
        lastCheckedAt: DateTime.now(),
      );
    } catch (_) {
      // La sesión no debe fallar porque no se puedan guardar metadatos.
    }
  }
}
