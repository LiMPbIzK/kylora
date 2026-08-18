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
    on<SeriesDetailRequested>(_onDetailRequested);
    on<SeriesDetailClosed>(_onDetailClosed);
  }

  final IptvRepository _repository;

  List<Category> _categories = <Category>[];
  List<Series> _allSeries = <Series>[];

  Future<void> _onStarted(SeriesStarted event, Emitter<SeriesState> emit) async {
    emit(const SeriesLoading());
    try {
      final List<Category> categories =
          await _repository.fetchSeriesCategories();
      final List<Series> seriesList = await _repository.fetchSeries();
      _categories = categories;
      _allSeries = seriesList;
      emit(
        SeriesLoaded(
          categories: categories,
          selectedCategoryId: null,
          seriesList: seriesList,
        ),
      );
    } catch (_) {
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

    final List<Series> seriesList = event.categoryId == null
        ? _allSeries
        : _allSeries
              .where((Series series) => series.categoryId == event.categoryId)
              .toList();

    emit(
      SeriesLoaded(
        categories: _categories,
        selectedCategoryId: event.categoryId,
        seriesList: seriesList,
      ),
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
    } catch (_) {
      emit(SeriesDetailFailure(event.series, 'seriesDetailLoadError'));
    }
  }

  Future<void> _onDetailClosed(
    SeriesDetailClosed event,
    Emitter<SeriesState> emit,
  ) async {
    emit(const SeriesLoading());
    try {
      emit(
        SeriesLoaded(
          categories: _categories,
          selectedCategoryId: null,
          seriesList: _allSeries,
        ),
      );
    } catch (_) {
      emit(const SeriesFailure('seriesLoadError'));
    }
  }
}
