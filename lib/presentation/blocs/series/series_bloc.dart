import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/xtream_date.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/series.dart';
import '../../../domain/entities/series_info.dart';
import '../../../domain/repositories/iptv_repository.dart';
import 'series_event.dart';
import 'series_state.dart';

/// Bloc del catálogo y detalle de series.
class SeriesBloc extends Bloc<SeriesEvent, SeriesState> {
  SeriesBloc(this._repository) : super(const SeriesLoading()) {
    on<SeriesStarted>(_onStarted);
    on<SeriesCategorySelected>(_onCategorySelected);
    on<SeriesSearchChanged>(_onSearchChanged);
    on<SeriesDetailRequested>(_onDetailRequested);
    on<SeriesDetailClosed>(_onDetailClosed);
    on<SeriesRefreshRequested>(_onRefreshRequested);
    on<SeriesRecentToggled>(_onRecentToggled);
  }

  final IptvRepository _repository;

  /// Categoría inicial tras cargar: la primera disponible (ya no existe "Todas").
  int? get _initialCategoryId =>
      _categories.isNotEmpty ? _categories.first.id : null;

  List<Category> _categories = <Category>[];
  List<Series> _allSeries = <Series>[];
  String _query = '';
  bool _recentOnly = false;

  Future<void> _onRecentToggled(
    SeriesRecentToggled event,
    Emitter<SeriesState> emit,
  ) async {
    if (state is! SeriesLoaded) return;
    _recentOnly = event.enabled;
    final SeriesLoaded current = state as SeriesLoaded;
    emit(_buildLoaded(selectedCategoryId: current.selectedCategoryId));
  }

  Future<void> _onRefreshRequested(
    SeriesRefreshRequested event,
    Emitter<SeriesState> emit,
  ) async {
    emit(const SeriesLoading());
    try {
      final List<Category> categories =
          await _repository.fetchSeriesCategories();
      final List<Series> seriesList = await _repository.fetchSeries();
      _categories = categories;
      _allSeries = seriesList;
      _query = '';
      emit(_buildLoaded(selectedCategoryId: _initialCategoryId));
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('SeriesBloc refresh error: ${e.runtimeType}: $e');
        debugPrint('$stack');
      }
      emit(const SeriesFailure('seriesLoadError'));
    }
  }

  Future<void> _onStarted(SeriesStarted event, Emitter<SeriesState> emit) async {
    emit(const SeriesLoading());
    try {
      final List<Category> categories =
          await _repository.fetchSeriesCategories();
      final List<Series> seriesList = await _repository.fetchSeries();
      _categories = categories;
      _allSeries = seriesList;
      _query = '';
      emit(_buildLoaded(selectedCategoryId: _initialCategoryId));
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('SeriesBloc error: ${e.runtimeType}: $e');
        debugPrint('$stack');
      }
      emit(const SeriesFailure('seriesLoadError'));
    }
  }

  Future<void> _onCategorySelected(
    SeriesCategorySelected event,
    Emitter<SeriesState> emit,
  ) async {
    if (state is! SeriesLoaded) return;
    final SeriesLoaded current = state as SeriesLoaded;
    if (current.selectedCategoryId == event.categoryId) return;
    emit(_buildLoaded(selectedCategoryId: event.categoryId));
  }

  Future<void> _onSearchChanged(
    SeriesSearchChanged event,
    Emitter<SeriesState> emit,
  ) async {
    if (state is! SeriesLoaded) return;
    _query = event.query;
    final SeriesLoaded current = state as SeriesLoaded;
    emit(_buildLoaded(selectedCategoryId: current.selectedCategoryId));
  }

  /// Construye el estado cargado combinando categoría, búsqueda y recientes.
  SeriesLoaded _buildLoaded({required int? selectedCategoryId}) {
    final String term = _query.trim().toLowerCase();
    final DateTime cutoff = DateTime.now().subtract(const Duration(days: 7));
    final List<Series> seriesList = _allSeries.where((Series series) {
      final bool matchCategory =
          selectedCategoryId == null || series.categoryId == selectedCategoryId;
      final bool matchQuery =
          term.isEmpty || series.name.toLowerCase().contains(term);
      final bool matchRecent =
          !_recentOnly || _isWithin(series.lastModified, cutoff);
      return matchCategory && matchQuery && matchRecent;
    }).toList();

    return SeriesLoaded(
      categories: _categories,
      selectedCategoryId: selectedCategoryId,
      query: _query,
      seriesList: seriesList,
      recentOnly: _recentOnly,
    );
  }

  static bool _isWithin(String? lastModified, DateTime cutoff) {
    final DateTime? date = parseXtreamDate(lastModified);
    return date != null && date.isAfter(cutoff);
  }

  Future<void> _onDetailRequested(
    SeriesDetailRequested event,
    Emitter<SeriesState> emit,
  ) async {
    emit(SeriesDetailLoading(event.series));
    try {
      final SeriesInfo info = await _repository.fetchSeriesInfo(
        event.series.id,
      );
      emit(SeriesDetailLoaded(series: event.series, info: info));
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('SeriesBloc detail error: ${e.runtimeType}: $e');
        debugPrint('$stack');
      }
      emit(SeriesDetailFailure(event.series, 'seriesDetailLoadError'));
    }
  }

  Future<void> _onDetailClosed(
    SeriesDetailClosed event,
    Emitter<SeriesState> emit,
  ) async {
    emit(const SeriesLoading());
    try {
      emit(_buildLoaded(selectedCategoryId: _initialCategoryId));
    } catch (_) {
      emit(const SeriesFailure('seriesLoadError'));
    }
  }
}
