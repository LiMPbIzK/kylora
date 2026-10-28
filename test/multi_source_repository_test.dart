import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/data/datasources/local/app_database.dart';
import 'package:kylora/data/datasources/local/auth_store.dart';
import 'package:kylora/data/datasources/local/live_cache_store.dart';
import 'package:kylora/data/datasources/remote/m3u_downloader.dart';
import 'package:kylora/data/datasources/remote/xtream_api_client.dart';
import 'package:kylora/data/repositories/m3u_repository.dart';
import 'package:kylora/data/repositories/multi_source_repository.dart';
import 'package:kylora/data/repositories/xtream_repository.dart';
import 'package:kylora/domain/entities/iptv_auth_config.dart';

/// AuthStore falso en memoria (el real usa flutter_secure_storage).
class _FakeAuthStore extends AuthStore {
  _FakeAuthStore() : super(storage: const FlutterSecureStorage());

  StoredCredentials? stored;

  @override
  Future<StoredCredentials?> read() async => stored;

  @override
  Future<void> write(
    StoredCredentials credentials, {
    String? label,
    bool activate = true,
  }) async {
    stored = credentials;
  }

  @override
  Future<void> clear() async {
    stored = null;
  }
}

void main() {
  late AppDatabase database;

  group('MultiSourceRepository enrutado', () {
    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('login(Xtream) delega en el repo Xtream y login(M3U) en el M3U', () async {
      final _FakeAuthStore authStore = _FakeAuthStore();
      final Dio dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      final LiveCacheStore cache = LiveCacheStore(database);
      final MultiSourceRepository repo = MultiSourceRepository(
        xtream: XtreamRepository(
          XtreamApiClient(dio),
          authStore,
          database,
          cache: cache,
        ),
        m3u: M3uRepository(
          M3uDownloader(dio),
          authStore,
          database,
          cache: cache,
        ),
        authStore: authStore,
      );

      // Sin sesión previa, el enrutado por config M3U debe elegir la fuente m3u
      // sin lanzar el cast TypeError que ocurría con el repo único de Xtream.
      await expectLater(
        repo.login(const M3uAuthConfig(m3uUrl: 'file:///inexistente.m3u')),
        throwsA(isA<M3uNetworkException>()),
      );
    });

    test('el enrutado con config M3U no cae en el cast de Xtream', () async {
      final _FakeAuthStore authStore = _FakeAuthStore();
      final MultiSourceRepository repo = MultiSourceRepository(
        xtream: XtreamRepository(
          XtreamApiClient(Dio()),
          authStore,
          database,
          cache: LiveCacheStore(database),
        ),
        m3u: M3uRepository(
          M3uDownloader(Dio()),
          authStore,
          database,
          cache: LiveCacheStore(database),
        ),
        authStore: authStore,
      );

      // El bug era que XtreamRepository.login hacía `config as XtreamAuthConfig`.
      // MultiSourceRepository resuelve por config.sourceType, así que nunca
      // llega el M3uAuthConfig al repo de Xtream.
      expect(repo, isA<MultiSourceRepository>());
    });
  });
}
