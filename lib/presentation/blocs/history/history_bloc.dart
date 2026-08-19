import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/history_item.dart';
import '../../../domain/repositories/iptv_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

/// Bloc del historial de reproducción.
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc(this._repository) : super(const HistoryLoading()) {
    on<HistoryStarted>(_onStarted);
  }

  final IptvRepository _repository;

  Future<void> _onStarted(
    HistoryStarted event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    try {
      final List<HistoryItem> items = await _repository.getHistory();
      emit(HistoryLoaded(items));
    } catch (e) {
      if (kDebugMode) debugPrint('HistoryBloc error: $e');
      emit(const HistoryFailure('historyLoadError'));
    }
  }
}
