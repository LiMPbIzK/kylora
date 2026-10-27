import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/radio.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/repositories/iptv_repository.dart';
import 'live_event.dart';
import 'live_state.dart';

/// Bloc del catálogo de canales en directo: carga y filtrado por categoría.
class LiveBloc extends Bloc<LiveEvent, LiveState> {
  LiveBloc(this._repository) : super(const LiveLoading()) {
    on<LiveStarted>(_onStarted);
    on<LiveCategorySelected>(_onCategorySelected);
    on<LiveSearchChanged>(_onSearchChanged);
    on<LiveRefreshRequested>(_onRefreshRequested);
  }

  final IptvRepository _repository;

  /// Categoría inicial tras cargar: la primera disponible (ya no existe "Todas").
  int? get _initialCategoryId =>
      _categories.isNotEmpty ? _categories.first.id : null;

  List<Category> _categories = <Category>[];
  List<Channel> _allChannels = <Channel>[];
  String _query = '';

  /// `true` cuando el catálogo es la sección Radio: solo muestra las
  /// categorías/canales de radio (streams de audio) y excluye la TV.
  bool _radio = false;

  Future<void> _onRefreshRequested(
    LiveRefreshRequested event,
    Emitter<LiveState> emit,
  ) async {
    emit(const LiveLoading());
    try {
      final List<Category> categories = await _repository.fetchLiveCategories();
      final List<Channel> channels = await _repository.fetchLiveChannels();
      _categories = categories;
      _allChannels = channels;
      _query = '';
      emit(_buildLoaded(selectedCategoryId: _initialCategoryId));
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('LiveBloc refresh error: ${e.runtimeType}: $e');
        debugPrint('$stack');
      }
      emit(const LiveFailure('liveLoadError'));
    }
  }

  Future<void> _onStarted(LiveStarted event, Emitter<LiveState> emit) async {
    _radio = event.radio;
    emit(const LiveLoading());
    try {
      final List<Category> categories = await _repository.fetchLiveCategories();
      final List<Channel> channels = await _repository.fetchLiveChannels();
      _categories = categories;
      _allChannels = channels;
      _query = '';
      emit(_buildLoaded(selectedCategoryId: _initialCategoryId));
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('LiveBloc error: ${e.runtimeType}: $e');
        debugPrint('$stack');
      }
      emit(const LiveFailure('liveLoadError'));
    }
  }

  Future<void> _onCategorySelected(
    LiveCategorySelected event,
    Emitter<LiveState> emit,
  ) async {
    if (state is! LiveLoaded) return;
    final LiveLoaded current = state as LiveLoaded;
    if (current.selectedCategoryId == event.categoryId) return;
    emit(_buildLoaded(selectedCategoryId: event.categoryId));
  }

  Future<void> _onSearchChanged(
    LiveSearchChanged event,
    Emitter<LiveState> emit,
  ) async {
    if (state is! LiveLoaded) return;
    _query = event.query;
    final LiveLoaded current = state as LiveLoaded;
    emit(_buildLoaded(selectedCategoryId: current.selectedCategoryId));
  }

  /// Construye el estado cargado combinando sección (TV/radio), categoría y
  /// búsqueda.
  LiveLoaded _buildLoaded({required int? selectedCategoryId}) {
    final Set<int> radioCategoryIds = _categories
        .where((Category category) => isRadioCategory(category.name))
        .map((Category category) => category.id)
        .toSet();
    final List<Category> categories = _categories
        .where((Category category) => isRadioCategory(category.name) == _radio)
        .toList();
    // Si la categoría seleccionada no pertenece a esta sección (p. ej. al
    // cambiar de TV a Radio), arranca en la primera disponible.
    int? effectiveCategoryId = selectedCategoryId;
    if (effectiveCategoryId != null &&
        !categories.any(
          (Category category) => category.id == effectiveCategoryId,
        )) {
      effectiveCategoryId = categories.isNotEmpty ? categories.first.id : null;
    }

    final String term = _query.trim().toLowerCase();
    final List<Channel> channels = _allChannels.where((Channel channel) {
      // Separa TV y radio según la categoría a la que pertenece el canal.
      final bool isRadioChannel = radioCategoryIds.contains(channel.categoryId);
      if (isRadioChannel != _radio) return false;
      final bool matchCategory =
          effectiveCategoryId == null ||
          term.isNotEmpty ||
          channel.categoryId == effectiveCategoryId;
      final bool matchQuery =
          term.isEmpty || channel.name.toLowerCase().contains(term);
      return matchCategory && matchQuery;
    }).toList();

    return LiveLoaded(
      categories: categories,
      selectedCategoryId: effectiveCategoryId,
      channels: channels,
      query: _query,
    );
  }
}
