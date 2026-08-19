import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/epg.dart';
import '../../../domain/repositories/iptv_repository.dart';
import 'epg_event.dart';
import 'epg_state.dart';

/// Bloc de la guía electrónica de programación (EPG).
///
/// Gestiona dos cargas bajo demanda por canal:
/// * [EpgNowNextRequested]: EPG corto (ahora/siguiente) para mostrar en la
///   lista de canales en directo.
/// * [EpgGuideRequested]: programación completa para la vista de guía.
class EpgBloc extends Bloc<EpgEvent, EpgState> {
  EpgBloc(this._repository) : super(const EpgIdle()) {
    on<EpgNowNextRequested>(_onNowNext);
    on<EpgGuideRequested>(_onGuide);
  }

  final IptvRepository _repository;

  /// Caché de EPG corto por canal para no repetir peticiones.
  final Map<int, EpgNowNextLoaded> _nowNextCache = <int, EpgNowNextLoaded>{};

  /// Caché de programación completa por canal.
  final Map<int, EpgGuideLoaded> _guideCache = <int, EpgGuideLoaded>{};

  Future<void> _onNowNext(
    EpgNowNextRequested event,
    Emitter<EpgState> emit,
  ) async {
    final EpgNowNextLoaded? cached = _nowNextCache[event.streamId];
    if (cached != null && _isFresh(cached)) {
      emit(cached);
      return;
    }
    if (state is EpgLoading && (state as EpgLoading).streamId == event.streamId) {
      return;
    }
    emit(EpgLoading(event.streamId));
    try {
      final List<EpgEntry> entries = await _repository.fetchShortEpg(
        event.streamId,
      );
      final DateTime now = DateTime.now();
      EpgEntry? onAir;
      EpgEntry? next;
      for (final EpgEntry entry in entries) {
        if (entry.isOnAir(now)) {
          onAir = entry;
        } else if (entry.start.isAfter(now) && next == null) {
          next = entry;
        }
      }
      final EpgNowNextLoaded loaded = EpgNowNextLoaded(
        streamId: event.streamId,
        now: onAir,
        next: next,
        loadedAt: now,
      );
      _nowNextCache[event.streamId] = loaded;
      emit(loaded);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EpgBloc nowNext error (${event.streamId}): $e');
      }
      emit(EpgFailure(event.streamId));
    }
  }

  Future<void> _onGuide(
    EpgGuideRequested event,
    Emitter<EpgState> emit,
  ) async {
    final EpgGuideLoaded? cached = _guideCache[event.streamId];
    if (cached != null) {
      emit(cached);
      return;
    }
    emit(EpgLoading(event.streamId));
    try {
      final List<EpgEntry> entries = await _repository.fetchFullEpg(
        event.streamId,
      );
      if (entries.isEmpty) {
        emit(EpgEmpty(event.streamId));
        return;
      }
      final EpgGuideLoaded loaded = EpgGuideLoaded(
        streamId: event.streamId,
        channelName: event.channelName,
        entries: entries,
      );
      _guideCache[event.streamId] = loaded;
      emit(loaded);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EpgBloc guide error (${event.streamId}): $e');
      }
      emit(EpgFailure(event.streamId));
    }
  }

  bool _isFresh(EpgNowNextLoaded loaded) {
    final DateTime? loadedAt = loaded.loadedAt;
    if (loadedAt == null) return true;
    return DateTime.now().difference(loadedAt) < _nowNextCacheTtl;
  }

  /// Tiempo de validez del EPG corto en caché (5 minutos).
  static const Duration _nowNextCacheTtl = Duration(minutes: 5);
}
