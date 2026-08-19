import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_bloc/flutter_bloc.dart';

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
  }

  final IptvRepository _repository;

  List<Category> _categories = <Category>[];
  List<Channel> _allChannels = <Channel>[];
  String _query = '';

  Future<void> _onStarted(LiveStarted event, Emitter<LiveState> emit) async {
    emit(const LiveLoading());
    try {
      final List<Category> categories = await _repository.fetchLiveCategories();
      final List<Channel> channels = await _repository.fetchLiveChannels();
      _categories = categories;
      _allChannels = channels;
      _query = '';
      emit(
        _buildLoaded(selectedCategoryId: null),
      );
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

  /// Construye el estado cargado combinando categoría y búsqueda.
  LiveLoaded _buildLoaded({required int? selectedCategoryId}) {
    final String term = _query.trim().toLowerCase();
    final List<Channel> channels = _allChannels.where((Channel channel) {
      final bool matchCategory =
          selectedCategoryId == null || channel.categoryId == selectedCategoryId;
      final bool matchQuery =
          term.isEmpty || channel.name.toLowerCase().contains(term);
      return matchCategory && matchQuery;
    }).toList();

    return LiveLoaded(
      categories: _categories,
      selectedCategoryId: selectedCategoryId,
      channels: channels,
      query: _query,
    );
  }
}
