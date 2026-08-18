import 'package:flutter/material.dart';

import '../../../core/media/playback_controller.dart';
import 'player_screen.dart';

/// Overlay persistente que muestra el reproductor encima del contenido.
///
/// El [PlayerScreen] se monta en la **primera** reproducción dentro de un
/// widget [Overlay] propio y se mantiene siempre en el árbol (oculto con
/// [Offstage] cuando no hay reproducción). Así su `Video` / superficie gráfica
/// nunca se desmonta al navegar, evitando el crash de media_kit/ANGLE en
/// Windows. El `Overlay` aporta además el ancestro que requieren los `Tooltip`s.
class PlaybackOverlay extends StatefulWidget {
  const PlaybackOverlay({
    super.key,
    required this.controller,
    required this.child,
  });

  final PlaybackController controller;
  final Widget child;

  @override
  State<PlaybackOverlay> createState() => _PlaybackOverlayState();
}

class _PlaybackOverlayState extends State<PlaybackOverlay> {
  OverlayEntry? _entry;
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (widget.controller.isPlaying) {
          _started = true;
        }
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            widget.child,
            if (_started)
              Overlay(
                initialEntries: <OverlayEntry>[
                  // Se crea una única vez: incluye el reproductor persistente.
                  _entry ??= _buildEntry(widget.controller),
                ],
              ),
          ],
        );
      },
    );
  }

  OverlayEntry _buildEntry(PlaybackController controller) {
    return OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final bool playing = controller.isPlaying;
          return IgnorePointer(
            ignoring: !playing,
            child: Offstage(
              offstage: !playing,
              child: PlayerScreen(controller: controller),
            ),
          );
        },
      ),
    );
  }
}
