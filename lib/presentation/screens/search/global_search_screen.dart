import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/media/playback_request.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/entities/series.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared_widgets/tv_focusable.dart';
import '../player/playback_scope.dart';

/// Búsqueda global en TV, películas y series.
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(debugLabel: 'global-search');
  Timer? _debounce;
  bool _loading = true;
  String? _error;
  List<Channel> _channels = <Channel>[];
  List<Movie> _movies = <Movie>[];
  List<Series> _series = <Series>[];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final IptvRepository repository = context.read<IptvRepository>();
    try {
      final List<Object> result = await Future.wait<Object>(<Future<Object>>[
        repository.fetchLiveChannels(),
        repository.fetchVodStreams(),
        repository.fetchSeries(),
      ]);
      if (!mounted) return;
      setState(() {
        _channels = result[0] as List<Channel>;
        _movies = result[1] as List<Movie>;
        _series = result[2] as List<Series>;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context)!.searchLoadError;
      });
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _query = value.trim().toLowerCase());
    });
  }

  Future<void> _playChannel(Channel channel) async {
    final IptvRepository repository = context.read<IptvRepository>();
    final String url = await repository.buildStreamUrl(channel);
    if (!mounted) return;
    PlaybackScope.of(context).play(
      PlaybackRequest(
        title: channel.name,
        urlBuilder: () async => url,
        contentType: 'live',
        contentId: channel.id,
        hasArchive: channel.hasArchive,
        archiveDurationDays: channel.archiveDurationDays,
        channelTitle: channel.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool hasQuery = _query.isNotEmpty;
    final List<Channel> channels = hasQuery
        ? _channels
              .where((Channel c) => c.name.toLowerCase().contains(_query))
              .take(40)
              .toList()
        : const <Channel>[];
    final List<Movie> movies = hasQuery
        ? _movies
              .where((Movie m) => m.name.toLowerCase().contains(_query))
              .take(40)
              .toList()
        : const <Movie>[];
    final List<Series> series = hasQuery
        ? _series
              .where((Series s) => s.name.toLowerCase().contains(_query))
              .take(40)
              .toList()
        : const <Series>[];
    final bool noResults =
        !_loading &&
        _error == null &&
        hasQuery &&
        channels.isEmpty &&
        movies.isEmpty &&
        series.isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchPlaceholder)),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              focusNode: _searchFocusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: (String value) {
                _onChanged(value);
                _searchFocusNode.unfocus();
              },
              decoration: InputDecoration(
                hintText: l10n.searchPlaceholder,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: l10n.clearSearch,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    _onChanged('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(_error!),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _load, child: Text(l10n.retry)),
                  ],
                ),
              ),
            )
          else if (!hasQuery)
            Expanded(
              child: Center(
                child: Text(
                  l10n.searchPlaceholder,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else if (noResults)
            Expanded(child: Center(child: Text(l10n.searchNoResults)))
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: <Widget>[
                  if (channels.isNotEmpty) ...<Widget>[
                    _sectionHeader(context, l10n.liveTv),
                    for (final Channel channel in channels)
                      _ResultTile(
                        icon: Icons.live_tv,
                        title: channel.name,
                        subtitle: l10n.liveTv,
                        onPressed: () => _playChannel(channel),
                      ),
                  ],
                  if (movies.isNotEmpty) ...<Widget>[
                    _sectionHeader(context, l10n.movies),
                    for (final Movie movie in movies)
                      _ResultTile(
                        icon: Icons.movie_outlined,
                        title: movie.name,
                        subtitle: l10n.movies,
                        onPressed: () =>
                            context.push(Routes.movieDetail, extra: movie),
                      ),
                  ],
                  if (series.isNotEmpty) ...<Widget>[
                    _sectionHeader(context, l10n.series),
                    for (final Series item in series)
                      _ResultTile(
                        icon: Icons.theaters_outlined,
                        title: item.name,
                        subtitle: l10n.series,
                        onPressed: () =>
                            context.push(Routes.seriesDetail, extra: item),
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      borderRadius: BorderRadius.circular(8),
      onPressed: onPressed,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle),
        onTap: onPressed,
      ),
    );
  }
}
