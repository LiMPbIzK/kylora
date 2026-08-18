import '../../domain/entities/user_account.dart';
import '../../domain/repositories/iptv_repository.dart';
import '../datasources/local/auth_store.dart';
import '../datasources/remote/xtream_api_client.dart';
import '../models/xtream_user_info_dto.dart';

/// Implementación Xtream del contrato [IptvRepository].
class XtreamRepository implements IptvRepository {
  XtreamRepository(this._apiClient, this._authStore);

  final XtreamApiClient _apiClient;
  final AuthStore _authStore;

  @override
  Future<UserAccount> login({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    final XtreamAuthResponse response = await _apiClient.authenticate(
      serverUrl: serverUrl,
      username: username,
      password: password,
    );
    final XtreamUserInfoDto info = response.userInfo;
    final UserAccount account = UserAccount(
      serverUrl: serverUrl,
      username: username,
      password: password,
      status: info.status,
      expiresAt: info.expiresAt,
      maxConnections: info.maxConnections,
      activeConnections: info.activeConnections,
    );
    await _authStore.write(
      StoredCredentials(serverUrl: serverUrl, username: username, password: password),
    );
    return account;
  }

  @override
  Future<UserAccount?> restoreSession() async {
    final StoredCredentials? credentials = await _authStore.read();
    if (credentials == null) return null;
    try {
      final XtreamAuthResponse response = await _apiClient.authenticate(
        serverUrl: credentials.serverUrl,
        username: credentials.username,
        password: credentials.password,
      );
      final XtreamUserInfoDto info = response.userInfo;
      return UserAccount(
        serverUrl: credentials.serverUrl,
        username: credentials.username,
        password: credentials.password,
        status: info.status,
        expiresAt: info.expiresAt,
        maxConnections: info.maxConnections,
        activeConnections: info.activeConnections,
      );
    } on XtreamAuthException {
      await _authStore.clear();
      return null;
    }
  }

  @override
  Future<void> logout() => _authStore.clear();
}
