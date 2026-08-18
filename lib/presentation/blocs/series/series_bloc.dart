import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_bloc/flutter_bloc.dart';

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
  }

  final IptvRepository _repository;

  List<Category> _categories = <Category>[];
  List<Series> _allSeries = <Series>[];
  String _query = '';

  Future<void> _onStarted(SeriesStarted event, Emitter<SeriesState> emit) async {
    emit(const SeriesLoading());
    try {
      final List<Category> categories =
          await _repository.fetchSeriesCategories();
      final List<Series> seriesList = await _repository.fetchSeries();
      _categories = categories;
      _allSeries = seriesList;
      _query = '';
      emit(_buildLoaded(selectedCategoryId: null));
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

  /// Construye el estado cargado combinando categoría y búsqueda.
  SeriesLoaded _buildLoaded({required int? selectedCategoryId}) {
    final String term = _query.trim().toLowerCase();
    final List<Series> seriesList = _allSeries.where((Series series) {
      final bool matchCategory =
          selectedCategoryId == null || series.categoryId == selectedCategoryId;
      final bool matchQuery =
          term.isEmpty || series.name.toLowerCase().contains(term);
      return matchCategory && matchQuery;
    }).toList();

    return SeriesLoaded(
      categories: _categories,
      selectedCategoryId: selectedCategoryId,
      query: _query,
      seriesList: seriesList,
    );
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
      emit(_buildLoaded(selectedCategoryId: null));
    } catch (_) {
      emit(const SeriesFailure('seriesLoadError'));
    }
  }
}
