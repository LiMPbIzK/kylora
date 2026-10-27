import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/xtream_date.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/iptv_repository.dart';
import 'vod_event.dart';
import 'vod_state.dart';

/// Bloc del catálogo de películas (VOD): carga, filtrado por categoría y búsqueda.
class VodBloc extends Bloc<VodEvent, VodState> {
  VodBloc(this._repository) : super(const VodLoading()) {
    on<VodStarted>(_onStarted);
    on<VodCategorySelected>(_onCategorySelected);
    on<VodSearchChanged>(_onSearchChanged);
    on<VodRefreshRequested>(_onRefreshRequested);
    on<VodRecentToggled>(_onRecentToggled);
    on<VodResumeToggled>(_onResumeToggled);
  }

  final IptvRepository _repository;

  /// Categoría inicial tras cargar: la primera disponible (ya no existe "Todas").
  int? get _initialCategoryId =>
      _categories.isNotEmpty ? _categories.first.id : null;

  Future<void> _onResumeToggled(
    VodResumeToggled event,
    Emitter<VodState> emit,
  ) async {
    if (state is! VodLoaded) return;
    final VodLoaded current = state as VodLoaded;
    emit(
      _buildLoaded(
        selectedCategoryId: current.selectedCategoryId,
        resumeMode: event.enabled,
      ),
    );
  }

  List<Category> _categories = <Category>[];
  List<Movie> _allMovies = <Movie>[];
  String _query = '';
  bool _recentOnly = false;

  Future<void> _onRecentToggled(
    VodRecentToggled event,
    Emitter<VodState> emit,
  ) async {
    if (state is! VodLoaded) return;
    _recentOnly = event.enabled;
    final VodLoaded current = state as VodLoaded;
    emit(_buildLoaded(selectedCategoryId: current.selectedCategoryId));
  }

  Future<void> _onRefreshRequested(
    VodRefreshRequested event,
    Emitter<VodState> emit,
  ) async {
    emit(const VodLoading());
    try {
      final List<Category> categories = await _repository.fetchVodCategories();
      final List<Movie> movies = await _repository.fetchVodStreams();
      _categories = categories;
      _allMovies = movies;
      _query = '';
      emit(_buildLoaded(selectedCategoryId: _initialCategoryId));
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('VodBloc refresh error: ${e.runtimeType}: $e');
        debugPrint('$stack');
      }
      emit(const VodFailure('vodLoadError'));
    }
  }

  Future<void> _onStarted(VodStarted event, Emitter<VodState> emit) async {
    emit(const VodLoading());
    try {
      final List<Category> categories = await _repository.fetchVodCategories();
      final List<Movie> movies = await _repository.fetchVodStreams();
      _categories = categories;
      _allMovies = movies;
      _query = '';
      emit(
        _buildLoaded(selectedCategoryId: _initialCategoryId),
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('VodBloc error: ${e.runtimeType}: $e');
        debugPrint('$stack');
      }
      emit(const VodFailure('vodLoadError'));
    }
  }

  Future<void> _onCategorySelected(
    VodCategorySelected event,
    Emitter<VodState> emit,
  ) async {
    if (state is! VodLoaded) return;
    final VodLoaded current = state as VodLoaded;
    if (current.selectedCategoryId == event.categoryId) return;
    emit(_buildLoaded(selectedCategoryId: event.categoryId));
  }

  Future<void> _onSearchChanged(
    VodSearchChanged event,
    Emitter<VodState> emit,
  ) async {
    if (state is! VodLoaded) return;
    _query = event.query;
    final VodLoaded current = state as VodLoaded;
    emit(
      _buildLoaded(selectedCategoryId: current.selectedCategoryId),
    );
  }

  /// Construye el estado cargado combinando categoría, búsqueda y recientes.
  VodLoaded _buildLoaded({required int? selectedCategoryId, bool resumeMode = false}) {
    final String term = _query.trim().toLowerCase();
    final DateTime cutoff = DateTime.now().subtract(const Duration(days: 7));
    final List<Movie> movies = _allMovies.where((Movie movie) {
      final bool matchCategory =
          selectedCategoryId == null ||
          term.isNotEmpty ||
          movie.categoryId == selectedCategoryId;
      final bool matchQuery =
          term.isEmpty || movie.name.toLowerCase().contains(term);
      final bool matchRecent =
          !_recentOnly || _isWithin(movie.added, cutoff);
      return matchCategory && matchQuery && matchRecent;
    }).toList();

    return VodLoaded(
      categories: _categories,
      selectedCategoryId: selectedCategoryId,
      query: _query,
      movies: movies,
      recentOnly: _recentOnly,
      resumeMode: resumeMode,
    );
  }

  /// Comprueba si una fecha (formato libre de la fuente) está dentro de [cutoff].
  static bool _isWithin(String? added, DateTime cutoff) {
    final DateTime? date = parseXtreamDate(added);
    return date != null && date.isAfter(cutoff);
  }
}
