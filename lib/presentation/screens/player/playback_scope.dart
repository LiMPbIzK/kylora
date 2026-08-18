import 'package:flutter/material.dart';

import '../../../core/media/playback_controller.dart';

/// Expone el [PlaybackController] compartido a los widgets de la app.
class PlaybackScope extends InheritedNotifier<PlaybackController> {
  const PlaybackScope({
    super.key,
    required PlaybackController controller,
    required super.child,
  }) : super(notifier: controller);

  static PlaybackController of(BuildContext context) {
    final PlaybackScope? scope =
        context.dependOnInheritedWidgetOfExactType<PlaybackScope>();
    assert(scope != null, 'No PlaybackScope en el árbol');
    return scope!.notifier!;
  }
}
