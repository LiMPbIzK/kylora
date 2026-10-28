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
  bool _wasPlaying = false;

  /// Nodo que tenía el foco antes de empezar a reproducir (botón Reproducir,
  /// tarjeta de canal/episodio…). Se restaura al cerrar el reproductor para que
  /// el D-Pad siga funcionando sin tener que volver atrás.
  FocusNode? _focusBeforePlayback;

  @override
  void initState() {
    super.initState();
    _wasPlaying = widget.controller.isPlaying;
    widget.controller.addListener(_onPlaybackChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPlaybackChanged);
    super.dispose();
  }

  void _onPlaybackChanged() {
    final bool playing = widget.controller.isPlaying;
    if (playing == _wasPlaying) return;
    _wasPlaying = playing;
    if (playing) {
      _focusBeforePlayback = FocusManager.instance.primaryFocus;
      return;
    }
    final FocusNode? previous = _focusBeforePlayback;
    _focusBeforePlayback = null;
    if (previous == null) return;
    // Se espera al siguiente frame: para entonces el reproductor ya está
    // oculto y el foco de la app de debajo vuelve a estar habilitado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (previous.context != null && previous.canRequestFocus) {
        previous.requestFocus();
      }
      // Segundo intento por si el cierre visual del overlay aún lo pisó.
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        if (!mounted || previous.context == null) return;
        if (previous.canRequestFocus && !previous.hasFocus) {
          previous.requestFocus();
        }
      });
    });
  }

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
            // Con el reproductor visible, la app de debajo (catálogo, menús…)
            // no debe recibir el foco del mando: evita que el D-Pad navegue por
            // elementos ocultos detrás del vídeo.
            ExcludeFocus(
              excluding: widget.controller.isPlaying,
              child: widget.child,
            ),
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
