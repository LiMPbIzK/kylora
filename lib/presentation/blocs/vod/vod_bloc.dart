import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/iptv_repository.dart';
import 'vod_event.dart';
import 'vod_state.dart';

/// Bloc del catálogo de películas (VOD): carga y filtrado por categoría.
class VodBloc extends Bloc<VodEvent, VodState> {
  VodBloc(this._repository) : super(const VodLoading()) {
    on<VodStarted>(_onStarted);
    on<VodCategorySelected>(_onCategorySelected);
  }

  final IptvRepository _repository;

  List<Category> _categories = <Category>[];
  List<Movie> _allMovies = <Movie>[];

  Future<void> _onStarted(VodStarted event, Emitter<VodState> emit) async {
    emit(const VodLoading());
    try {
      final List<Category> categories = await _repository.fetchVodCategories();
      final List<Movie> movies = await _repository.fetchVodStreams();
      _categories = categories;
      _allMovies = movies;
      emit(
        VodLoaded(
          categories: categories,
          selectedCategoryId: null,
          movies: movies,
        ),
      );
    } catch (_) {
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

    final List<Movie> movies = event.categoryId == null
        ? _allMovies
        : _allMovies
              .where((Movie movie) => movie.categoryId == event.categoryId)
              .toList();

    emit(
      VodLoaded(
        categories: _categories,
        selectedCategoryId: event.categoryId,
        movies: movies,
      ),
    );
  }
}
