import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_bloc/flutter_bloc.dart';

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
  }

  final IptvRepository _repository;

  List<Category> _categories = <Category>[];
  List<Movie> _allMovies = <Movie>[];
  String _query = '';

  Future<void> _onStarted(VodStarted event, Emitter<VodState> emit) async {
    emit(const VodLoading());
    try {
      final List<Category> categories = await _repository.fetchVodCategories();
      final List<Movie> movies = await _repository.fetchVodStreams();
      _categories = categories;
      _allMovies = movies;
      _query = '';
      emit(
        _buildLoaded(selectedCategoryId: null),
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

  /// Construye el estado cargado combinando categoría y búsqueda.
  VodLoaded _buildLoaded({required int? selectedCategoryId}) {
    final String term = _query.trim().toLowerCase();
    final List<Movie> movies = _allMovies.where((Movie movie) {
      final bool matchCategory =
          selectedCategoryId == null || movie.categoryId == selectedCategoryId;
      final bool matchQuery =
          term.isEmpty || movie.name.toLowerCase().contains(term);
      return matchCategory && matchQuery;
    }).toList();

    return VodLoaded(
      categories: _categories,
      selectedCategoryId: selectedCategoryId,
      query: _query,
      movies: movies,
    );
  }
}
