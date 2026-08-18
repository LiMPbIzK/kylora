import '../entities/category.dart';
import '../entities/channel.dart';
import '../entities/user_account.dart';

/// Contrato de repositorio agnóstico de fuente IPTV.
/// Tanto Xtream como M3U deben implementarlo.
abstract interface class IptvRepository {
  /// Autentica contra el proveedor y persiste las credenciales.
  Future<UserAccount> login({
    required String serverUrl,
    required String username,
    required String password,
  });

  /// Restaura la sesión guardada sin requerir credenciales.
  Future<UserAccount?> restoreSession();

  /// Cierra sesión y borra credenciales almacenadas.
  Future<void> logout();

  /// Categorías de canales en directo.
  Future<List<Category>> fetchLiveCategories();

  /// Canales en directo. Si [categoryId] es nulo, devuelve todos los canales.
  Future<List<Channel>> fetchLiveChannels({int? categoryId});
}
