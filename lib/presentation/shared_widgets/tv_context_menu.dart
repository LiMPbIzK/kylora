import 'package:flutter/material.dart';

/// Entrada de un menú contextual para TV.
class TvContextMenuEntry<T> {
  const TvContextMenuEntry({
    required this.value,
    required this.icon,
    required this.label,
    this.iconColor,
  });

  final T value;
  final IconData icon;
  final String label;
  final Color? iconColor;
}

/// Muestra un menú contextual centrado, pensado para el mando.
///
/// A diferencia de `showMenu` (cuyos `PopupMenuItem` no exponen autofocus), aquí
/// la **primera opción recibe el foco** al abrirse, de modo que se puede elegir
/// directamente con OK.
Future<T?> showTvContextMenu<T>({
  required BuildContext context,
  required List<TvContextMenuEntry<T>> entries,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black54,
    builder: (BuildContext dialogContext) =>
        _TvContextMenu<T>(entries: entries),
  );
}

class _TvContextMenu<T> extends StatefulWidget {
  const _TvContextMenu({required this.entries});

  final List<TvContextMenuEntry<T>> entries;

  @override
  State<_TvContextMenu<T>> createState() => _TvContextMenuState<T>();
}

class _TvContextMenuState<T> extends State<_TvContextMenu<T>> {
  final FocusNode _firstFocusNode = FocusNode(debugLabel: 'tv-context-menu');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _firstFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _firstFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < widget.entries.length; i++)
              ListTile(
                autofocus: i == 0,
                focusNode: i == 0 ? _firstFocusNode : null,
                leading: Icon(
                  widget.entries[i].icon,
                  color: widget.entries[i].iconColor ?? scheme.onSurfaceVariant,
                ),
                title: Text(widget.entries[i].label),
                onTap: () => Navigator.of(context).pop(widget.entries[i].value),
              ),
          ],
        ),
      ),
    );
  }
}
