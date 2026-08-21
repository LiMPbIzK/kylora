import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/remote/m3u_downloader.dart';
import '../../../data/datasources/remote/xtream_api_client.dart';
import '../../../domain/entities/user_account.dart';
import '../../../domain/repositories/iptv_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc de autenticación: login, auto-login y logout.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthChecking()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final IptvRepository _repository;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthChecking());
    try {
      final UserAccount? account = await _repository.restoreSession();
      if (account == null) {
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthAuthenticated(account: account));
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthChecking());
    try {
      final UserAccount account = await _repository.login(event.config);
      emit(AuthAuthenticated(account: account));
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

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }
}
