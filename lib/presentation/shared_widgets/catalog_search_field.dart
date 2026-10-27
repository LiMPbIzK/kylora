import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de búsqueda de un catálogo, pensado para Android TV/mando.
///
/// - Al mostrarse, recibe el foco automáticamente (puedes escribir sin navegar).
/// - **Arriba**: enfoca la primera sección (categoría) — [upFocus].
/// - **Abajo** o **confirmar**: oculta el cuadro (sin borrar la búsqueda) y
///   enfoca el primer resultado — [downFocus]/[onDismiss].
/// - **X**: cierra el buscador (limpia y oculta) — [onClose].
class CatalogSearchField extends StatefulWidget {
  const CatalogSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClose,
    required this.upFocus,
    required this.downFocus,
    this.onDismiss,
    this.onSearchSubmitted,
    this.trailing,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  /// Cierra el cuadro de búsqueda limpiando el texto (botón X).
  final VoidCallback onClose;

  /// Oculta el cuadro de búsqueda **sin** borrar la búsqueda (al bajar a los
  /// resultados). El botón de la lupa vuelve a mostrarlo.
  final VoidCallback? onDismiss;

  /// FocusNode que recibe el foco al pulsar `ArrowUp` (primera categoría).
  final FocusNode? upFocus;

  /// FocusNode que recibe el foco al pulsar `ArrowDown` o confirmar.
  final FocusNode? downFocus;

  /// Acción al confirmar la búsqueda (además de enfocar [downFocus]).
  final VoidCallback? onSearchSubmitted;

  /// Widget extra a la derecha (por ejemplo el filtro "Añadido recientemente").
  final Widget? trailing;

  @override
  State<CatalogSearchField> createState() => _CatalogSearchFieldState();
}

class _CatalogSearchFieldState extends State<CatalogSearchField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // Al abrirse el buscador, el foco va al propio campo (sin navegar con el
    // mando hacia abajo).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Focus(
              onKeyEvent: (FocusNode node, KeyEvent event) {
                if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
                  return KeyEventResult.ignored;
                }
                if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  widget.upFocus?.requestFocus();
                  return KeyEventResult.handled;
                }
                if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  // Baja a los resultados: oculta el buscador y enfoca el
                  // primer resultado.
                  widget.onDismiss?.call();
                  widget.downFocus?.requestFocus();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) {
                  widget.onDismiss?.call();
                  widget.downFocus?.requestFocus();
                  widget.onSearchSubmitted?.call();
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.trailing != null) ...<Widget>[
            const SizedBox(width: 8),
            widget.trailing!,
          ],
        ],
      ),
    );
  }
}