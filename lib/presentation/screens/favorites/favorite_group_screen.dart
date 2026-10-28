import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/media/playback_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/entities/favorite_channel_group.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared_widgets/tv_focusable.dart';
import '../player/playback_scope.dart';

/// Canales de un grupo/categoría guardado como favorito.
class FavoriteGroupScreen extends StatefulWidget {
  const FavoriteGroupScreen({super.key, required this.group});

  final FavoriteChannelGroup group;

  @override
  State<FavoriteGroupScreen> createState() => _FavoriteGroupScreenState();
}

class _FavoriteGroupScreenState extends State<FavoriteGroupScreen> {
  late Future<List<Channel>> _channels;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _channels = context.read<IptvRepository>().fetchLiveChannels(
      categoryId: widget.group.categoryId,
    );
  }

  Future<void> _play(Channel channel) async {
    final IptvRepository repository = context.read<IptvRepository>();
    final String url = await repository.buildStreamUrl(channel);
    if (!mounted) return;
    PlaybackScope.of(context).play(
      PlaybackRequest(
        title: channel.name,
        urlBuilder: () async => url,
        contentType: 'live',
        contentId: channel.id,
        logo: channel.logo,
        hasArchive: channel.hasArchive,
        archiveDurationDays: channel.archiveDurationDays,
        channelTitle: channel.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      body: FutureBuilder<List<Channel>>(
        future: _channels,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(l10n.liveLoadError),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(_load),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }
          final List<Channel> channels = snapshot.data ?? <Channel>[];
          if (channels.isEmpty) {
            return Center(child: Text(l10n.noChannels));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final Channel channel = channels[index];
              return TvFocusable(
                autofocus: index == 0,
                borderRadius: BorderRadius.circular(8),
                onPressed: () => _play(channel),
                child: ListTile(
                  leading: _ChannelLogo(logo: channel.logo),
                  title: Text(
                    channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    widget.group.isRadio ? l10n.radio : l10n.liveTv,
                  ),
                  onTap: () => _play(channel),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ChannelLogo extends StatelessWidget {
  const _ChannelLogo({this.logo});

  final String? logo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: logo == null || logo!.isEmpty
          ? Icon(Icons.live_tv, color: context.colors.primary)
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: logo!,
                fit: BoxFit.contain,
                errorWidget: (_, _, _) =>
                    Icon(Icons.live_tv, color: context.colors.primary),
              ),
            ),
    );
  }
}
