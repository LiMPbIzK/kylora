import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/episode.dart';
import '../../../domain/entities/season.dart';
import '../../../domain/entities/series.dart';
import '../../../domain/entities/series_info.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/series/series_bloc.dart';
import '../../blocs/series/series_event.dart';
import '../../blocs/series/series_state.dart';
import '../../shared_widgets/media_poster.dart';
import '../player/playback_scope.dart';

/// Detalle de una serie con sus temporadas y episodios reproducibles.
///
/// Usa el [SeriesBloc] compartido del catálogo (no crea uno propio), de modo
/// que al navegar a otra ruta y volver el estado `SeriesDetailLoaded` se
/// conserva y no se pierden los episodios ya cargados.
class SeriesDetailScreen extends StatefulWidget {
  const SeriesDetailScreen({super.key, required this.series});

  final Series series;

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  int _selectedSeason = 0;
  late final SeriesBloc _bloc;

  SeriesBloc get bloc => _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SeriesBloc>();
    // Solo recarga si el bloc no tiene aún cargada esta serie, para no
    // volver a vaciar la lista al regresar de reproducir un capítulo.
    final SeriesState state = _bloc.state;
    if (state is! SeriesDetailLoaded || state.series.id != widget.series.id) {
      _bloc.add(SeriesDetailRequested(widget.series));
    } else if (_selectedSeason == 0) {
      _selectedSeason = state.info.seasons.isNotEmpty
          ? state.info.seasons.first.number
          : 0;
    }
  }

  @override
  void dispose() {
    // Al salir del detalle, devolvemos el bloc al catálogo para que la rejilla
    // del tab vuelva a mostrarse (sin cerrar el bloc compartido).
    _bloc.add(const SeriesDetailClosed());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.series.name)),
      body: BlocBuilder<SeriesBloc, SeriesState>(
        bloc: _bloc,
        builder: (context, state) {
          return switch (state) {
            SeriesDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            SeriesDetailFailure() => _ErrorView(
              series: widget.series,
              message: AppLocalizations.of(context)!.seriesDetailLoadError,
              bloc: _bloc,
            ),
            SeriesDetailLoaded() =>
              _buildDetail(context, state.info),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, SeriesInfo info) {
    final List<Season> seasons = info.seasons;
    int effective = _selectedSeason;
    if (seasons.isNotEmpty &&
        !seasons.any((Season s) => s.number == _selectedSeason)) {
      // Selecciona la primera temporada por defecto para mostrar sus épocas.
      effective = seasons.first.number;
    }
    return _DetailContent(
      series: widget.series,
      info: info,
      selectedSeason: effective,
      onSeasonSelected: (int value) => setState(() => _selectedSeason = value),
    );
  }
}

/// Contenido del detalle: cabecera de la serie y episodios por temporada.
class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.series,
    required this.info,
    required this.selectedSeason,
    required this.onSeasonSelected,
  });

  final Series series;
  final SeriesInfo info;
  final int selectedSeason;
  final ValueChanged<int> onSeasonSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<Season> seasons = info.seasons;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 110,
              height: 165,
              child: MediaPoster(url: series.cover, fallbackIcon: Icons.theaters),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    series.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if ((series.rating ?? '').isNotEmpty) ...<Widget>[
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.star, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text('${l10n.rating}: ${series.rating}'),
                      ],
                    ),
                  ],
                  if (info.plot != null && info.plot!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(info.plot!, maxLines: 6, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (seasons.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (final Season season in seasons)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${l10n.season} ${season.number}'),
                      selected: selectedSeason == season.number,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: selectedSeason == season.number
                            ? AppColors.onPrimary
                            : AppColors.onSurface,
                      ),
                      onSelected: (_) => onSeasonSelected(season.number),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 24),
          for (final Episode episode
              in _seasonEpisodes(seasons, selectedSeason))
            _EpisodeTile(series: series, episode: episode),
        ],
      ],
    );
  }

  List<Episode> _seasonEpisodes(List<Season> seasons, int number) {
    for (final Season season in seasons) {
      if (season.number == number) {
        final List<Episode> episodes = season.episodes;
        episodes.sort(
          (Episode a, Episode b) => a.episodeNumber.compareTo(b.episodeNumber),
        );
        return episodes;
      }
    }
    return const <Episode>[];
  }
}

/// Fila de episodio con número, título y reproducción.
class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({required this.series, required this.episode});

  final Series series;
  final Episode episode;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _EpisodeNumber(number: episode.episodeNumber),
      title: Text(
        episode.name.isEmpty
            ? '${series.name} E${episode.episodeNumber}'
            : episode.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.play_circle_outline, color: AppColors.primary),
      onTap: () {
        final IptvRepository repository = context.read<IptvRepository>();
        final String episodeTitle = episode.name.isEmpty
            ? 'E${episode.episodeNumber}'
            : episode.name;
        PlaybackScope.of(context).play(
          PlaybackRequest(
            title: '${series.name} — $episodeTitle',
            urlBuilder: () => repository.buildEpisodeStreamUrl(episode),
          ),
        );
      },
    );
  }
}

/// Número de episodio en un recuadro.
class _EpisodeNumber extends StatelessWidget {
  const _EpisodeNumber({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$number',
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }
}

/// Vista de error del detalle con reintento.
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.series,
    required this.message,
    required this.bloc,
  });

  final Series series;
  final String message;
  final SeriesBloc bloc;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 56, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => bloc.add(SeriesDetailRequested(series)),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
