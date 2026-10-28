import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/content_type.dart';
import '../../../domain/entities/favorite_channel_group.dart';
import '../../../domain/entities/favorite_item.dart';
import '../../../domain/repositories/iptv_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

/// Bloc de favoritos: carga, toggle y persistencia.
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc(this._repository) : super(const FavoritesLoading()) {
    on<FavoritesStarted>(_onStarted);
    on<FavoritesToggled>(_onToggled);
    on<FavoriteGroupToggled>(_onGroupToggled);
  }

  final IptvRepository _repository;

  Future<void> _onStarted(
    FavoritesStarted event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());
    try {
      final List<FavoriteItem> items = await _repository.getFavorites();
      final List<FavoriteChannelGroup> groups = await _repository
          .getFavoriteGroups();
      emit(FavoritesLoaded(items, groups: groups));
    } catch (e) {
      if (kDebugMode) debugPrint('FavoritesBloc error: $e');
      emit(const FavoritesFailure('favoritesLoadError'));
    }
  }

  Future<void> _onToggled(
    FavoritesToggled event,
    Emitter<FavoritesState> emit,
  ) async {
    final ContentType type = _parseType(event.contentType);
    final bool isFav = await _repository.isFavorite(event.contentId, type);
    if (isFav) {
      await _repository.removeFromFavorite(event.contentId, type);
    } else {
      await _repository.addToFavorite(
        FavoriteItem(
          contentId: event.contentId,
          contentType: type,
          name: event.name,
          logo: event.logo,
        ),
      );
    }
    await _reload(emit);
  }

  Future<void> _onGroupToggled(
    FavoriteGroupToggled event,
    Emitter<FavoritesState> emit,
  ) async {
    final bool isFav = await _repository.isFavoriteGroup(
      event.group.categoryId,
    );
    if (isFav) {
      await _repository.removeFavoriteGroup(event.group.categoryId);
    } else {
      await _repository.addFavoriteGroup(event.group);
    }
    await _reload(emit);
  }

  Future<void> _reload(Emitter<FavoritesState> emit) async {
    final List<FavoriteItem> items = await _repository.getFavorites();
    final List<FavoriteChannelGroup> groups = await _repository
        .getFavoriteGroups();
    emit(FavoritesLoaded(items, groups: groups));
  }

  ContentType _parseType(String value) {
    return switch (value) {
      'live' => ContentType.live,
      'vod' => ContentType.vod,
      'series' => ContentType.series,
      _ => ContentType.live,
    };
  }
}
