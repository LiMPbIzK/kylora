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
  }

  final IptvRepository _repository;

  List<Category> _categories = <Category>[];
  List<Channel> _allChannels = <Channel>[];

  Future<void> _onStarted(LiveStarted event, Emitter<LiveState> emit) async {
    emit(const LiveLoading());
    try {
      final List<Category> categories = await _repository.fetchLiveCategories();
      final List<Channel> channels = await _repository.fetchLiveChannels();
      _categories = categories;
      _allChannels = channels;
      emit(
        LiveLoaded(
          categories: categories,
          selectedCategoryId: null,
          channels: channels,
        ),
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

    final List<Channel> channels = event.categoryId == null
        ? _allChannels
        : _allChannels
              .where(
                (Channel channel) => channel.categoryId == event.categoryId,
              )
              .toList();

    emit(
      LiveLoaded(
        categories: _categories,
        selectedCategoryId: event.categoryId,
        channels: channels,
      ),
    );
  }
}
